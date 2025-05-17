import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/config/ads_config.dart';
import 'package:flutter_2048/presentation/models/leaderboard_entry.dart';
import 'package:flutter_2048/utils/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final double itemHeight = 72.0;
  late BannerAd banner;
  var adRequest = const AdRequest(
    contextQuery: 'puzzle, games, mobile apps, games',
  );
  var isLoading = false;
  var isBannerAlreadyCreated = false;
  var bannerHeight = 0;
  var currentUserUid = '';
  List<LeaderboardEntry> leaderboardEntries = [];
  final GlobalKey _itemKey = GlobalKey();

  late final Future<InterstitialAdLoader> _adLoader;
  InterstitialAd? _ad;

  @override
  void initState() {
    super.initState();
    currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (isMobile()) {
      _adLoader = _createInterstitialAdLoader();
      _loadInterstitialAd();
    }
  }

  Future<InterstitialAdLoader> _createInterstitialAdLoader() {
    return InterstitialAdLoader.create(
      onAdLoaded: (InterstitialAd interstitialAd) {
        // The ad was loaded successfully. Now you can show loaded ad
        _ad = interstitialAd;
      },
      onAdFailedToLoad: (error) {
        // Ad failed to load with AdRequestError.
        // Attempting to load a new ad from the onAdFailedToLoad() method is strongly discouraged.
      },
    );
  }

  Future<void> _loadInterstitialAd() async {
    if (!isMobile()) return;
    final adLoader = await _adLoader;
    await adLoader.loadAd(
      adRequestConfiguration: AdRequestConfiguration(
        adUnitId: AdsConfig.getInterstitialID(),
      ),
    ); // for debug you can use 'demo-interstitial-yandex'
  }

  _showIntestitialAd() async {
    if (!isMobile()) return;
    _ad?.setAdEventListener(
      eventListener: InterstitialAdEventListener(
        onAdShown: () {
          // Called when ad is shown.
        },
        onAdFailedToShow: (error) {
          // Called when an InterstitialAd failed to show.
          // Destroy the ad so you don't show the ad a second time.
          _ad?.destroy();
          _ad = null;

          // Now you can preload the next interstitial ad.
          _loadInterstitialAd();
        },
        onAdClicked: () {
          // Called when a click is recorded for an ad.
        },
        onAdDismissed: () {
          // Called when ad is dismissed.
          // Destroy the ad so you don't show the ad a second time.
          _ad?.destroy();
          _ad = null;

          // Now you can preload the next interstitial ad.
          _loadInterstitialAd();
        },
        onAdImpression: (impressionData) {
          // Called when an impression is recorded for an ad.
        },
      ),
    );
    await _ad?.show();
    await _ad?.waitForDismiss();
  }

  void _scrollToUser() {
    print("_scrollToUser");
    if (!_scrollController.hasClients) return;
    print("hasClients");
    final index = leaderboardEntries.indexWhere(
      (entry) => entry.userId == currentUserUid,
    );
    print("index: $index");
    if (index != -1) {
      print("scrolling: $index");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print("addPostFrameCallback: $index");
        _scrollController.animateTo(
          index * itemHeight,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _showIntestitialAd();
      });
    }
  }

  Future<void> _checkAdConfigAndLoadAd() async {
    final configRef = FirebaseDatabase.instance.ref().child('config');
    // configRef.keepSynced(true);
    final snapshot = await configRef.get();
    final config = (snapshot.value as Map);
    final adsEnabledConfig = config['leaderboard_screen_ads_enabled'];
    final enabled = adsEnabledConfig == true || adsEnabledConfig == 'true';

    print("CONFIG: main_page_ads_enabled: $adsEnabledConfig");
    if (enabled && isMobile()) {
      adRequest = const AdRequest(
        contextQuery: 'puzzle, games, mobile apps, games',
      );
      _loadBanner(); // Your existing banner loading method
    } else {
      print("🚫 Ads disabled in remote config.");
    }
  }

  Future<void> _loadBanner() async {
    if (!isMobile()) return;
    final windowSize = MediaQuery.of(context).size;
    setState(() => isLoading = true);
    if (isBannerAlreadyCreated) {
      banner.loadAd(adRequest: adRequest);
    } else {
      final adSize = BannerAdSize.sticky(width: windowSize.width.toInt());
      var calculatedBannerSize = await adSize.getCalculatedBannerAdSize();
      banner = _createBanner(adSize);
      setState(() {
        bannerHeight = calculatedBannerSize.height;
        isBannerAlreadyCreated = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("CONFIG MAIN_PAGE: didChangeDependencies: $isBannerAlreadyCreated");
    if (!isBannerAlreadyCreated) {
      _checkAdConfigAndLoadAd(); // ✅ Now it's safe to use MediaQuery
    }
  }

  _createBanner(BannerAdSize adSize) {
    return BannerAd(
      adUnitId: AdsConfig.getLeaderboardBannerID(),
      adSize: adSize,
      adRequest: adRequest,
      onAdLoaded: () {
        setState(() {
          isLoading = false;
        });
        if (!mounted) {
          banner.destroy();
          return;
        }
      },
      onAdFailedToLoad: (error) {
        setState(() {
          isLoading = false;
        });
      },
      onAdClicked: () {},
      onLeftApplication: () {},
      onReturnedToApplication: () {},
      onImpression: (impressionData) {},
    );
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final snapshot = await FirebaseDatabase.instance.ref('leaderboard').once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (data == null) return [];
    leaderboardEntries =
        data.entries.map((e) {
            return LeaderboardEntry.fromMap(e.key, e.value);
          }).toList()
          ..sort((a, b) => b.score.compareTo(a.score));
    return leaderboardEntries; // sort descending
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide > 600;
    return Stack(
      children: [
        // This will stretch to fill space *above the banner*
        Positioned.fill(
          bottom: isMobile() ? bannerHeight.toDouble() : 0,
          child: createContent(context, isTablet),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: isBannerAlreadyCreated ? AdWidget(bannerAd: banner) : null,
          ),
        ),
      ],
    );
  }

  Widget createContent(BuildContext context, bool isTablet) {
    final appLocales = AppLocalizations.of(context);
    if (appLocales == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocales.leaderboard,
          style: TextStyle(fontSize: isTablet ? 32 : 16),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _scrollToUser(),
            icon: Icon(
              Icons.search,
              color: Colors.white,
              size: isTablet ? 40 : 30,
            ),
            label: Text(
              appLocales.findMe,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 30 : 18,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<LeaderboardEntry>>(
        future: fetchLeaderboard(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                appLocales.noScore,
                style: TextStyle(fontSize: isTablet ? 32 : 16),
              ),
            );
          }

          final entries = snapshot.data!;

          if (isTablet) {
            // Use DataTable for tablets
            final columnTextStyle = TextStyle(fontSize: 22);
            final cellTextStyle = TextStyle(fontSize: 20);
            return SingleChildScrollView(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              child: DataTable(
                columnSpacing: 54,
                columns: [
                  DataColumn(
                    label: Text(appLocales.rank, style: columnTextStyle),
                  ),
                  DataColumn(
                    label: Text(appLocales.scoreTitle, style: columnTextStyle),
                  ),
                  DataColumn(
                    label: Text(appLocales.platform, style: columnTextStyle),
                  ),
                  DataColumn(
                    label: Text(appLocales.device, style: columnTextStyle),
                  ),
                  DataColumn(
                    label: Text(appLocales.user, style: columnTextStyle),
                  ),
                ],
                rows: List.generate(entries.length, (index) {
                  final entry = entries[index];
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>((
                      Set<MaterialState> states,
                    ) {
                      return entry.userId == currentUserUid
                          ? Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.2)
                          : null;
                    }),
                    cells: [
                      DataCell(Text('#${index + 1}', style: cellTextStyle)),
                      DataCell(Text('${entry.score}', style: cellTextStyle)),
                      DataCell(Text(entry.platform, style: cellTextStyle)),
                      DataCell(Text(entry.device, style: cellTextStyle)),
                      DataCell(
                        Text(
                          entry.userId.substring(0, 6),
                          style: cellTextStyle,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            );
          } else {
            // Use ListView for phones
            return ListView.separated(
              controller: _scrollController,
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Container(
                  height: itemHeight,
                  color:
                      entry.userId == currentUserUid
                          ? Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.2)
                          : Colors.transparent,
                  child: ListTile(
                    leading: Text(
                      '#${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Text(appLocales.points(entry.score)),
                    subtitle: Text('${entry.platform} • ${entry.device}'),
                    trailing: Text(entry.userId.substring(0, 6)),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
