import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/config/ads_config.dart';
import 'package:flutter_2048/domain/progress/progress_store.dart';
import 'package:flutter_2048/presentation/models/leaderboard_entry.dart';
import 'package:flutter_2048/utils/helper.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
    currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  void _scrollToUser() {
    if (!_scrollController.hasClients) return;
    final index = leaderboardEntries.indexWhere(
      (entry) => entry.userId == currentUserUid,
    );
    if (index == -1) return;

    // Deliberately no interstitial here. This screen used to show one every
    // time the player asked where they ranked — a full-screen ad on a
    // navigation tap, bypassing the cooldown and the ad-free first sessions
    // that InterstitialService exists to enforce.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        index * itemHeight,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _checkAdConfigAndLoadAd() async {
    final configRef = FirebaseDatabase.instance.ref().child('config');
    // configRef.keepSynced(true);
    final snapshot = await configRef.get();
    final config = (snapshot.value as Map);
    final adsEnabledConfig = config['leaderboard_screen_ads_enabled'];
    final enabled = adsEnabledConfig == true || adsEnabledConfig == 'true';

    if (enabled && isMobile()) {
      adRequest = const AdRequest(
        contextQuery: 'puzzle, games, mobile apps, games',
      );
      _loadBanner(); // Your existing banner loading method
    } else {}
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

  /// Which board is being shown. Scores are ranked per mode.
  String boardMode = ModeKeys.classic;

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    // One read serves every board. Each player's scores live under their own
    // node — Classic at the top level, where hundreds of rows already sit from
    // before boards were split, and the other modes nested beneath it.
    final snapshot = await FirebaseDatabase.instance.ref('leaderboard').get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return [];

    final entries = <LeaderboardEntry>[];
    data.forEach((key, value) {
      if (value is! Map) return;
      final row = leaderboardRowFor(boardMode, value);
      if (row == null) return; // no score on this board
      entries.add(LeaderboardEntry.fromMap(key as String, row));
    });

    leaderboardEntries = entries..sort((a, b) => b.score.compareTo(a.score));
    return leaderboardEntries;
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
      body: Column(
        children: [
          _buildBoardSelector(appLocales),
          Expanded(child: _buildBoard(appLocales, isTablet)),
        ],
      ),
    );
  }

  /// Ranked boards are per mode, so the player picks which ladder to see.
  Widget _buildBoardSelector(AppLocalizations appLocales) {
    // Zen is absent on purpose: it keeps no score, so it has no ranking.
    final boards = <String, String>{
      ModeKeys.classic: appLocales.modeClassic,
      ModeKeys.timeAttack: appLocales.modeTimeAttack,
      ModeKeys.hardcore: appLocales.modeHardcore,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          for (final entry in boards.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: boardMode == entry.key,
                onSelected: (_) => setState(() => boardMode = entry.key),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBoard(AppLocalizations appLocales, bool isTablet) {
    return FutureBuilder<List<LeaderboardEntry>>(
      // Keyed on the board so switching modes refetches.
      key: ValueKey(boardMode),
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
          // A DataTable sizes itself to its widest cell, and this one sat in
          // a vertically-scrolling view only. Device names are arbitrary
          // strings — "Cuttlefish arm64 phone 64-bit only" is a real row —
          // so the table grew past the viewport and overflowed with no way
          // to reach the rest. Long cells are capped below, and the
          // horizontal scroll is the safety net for whatever a future device
          // calls itself.
          return SingleChildScrollView(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 32,
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
                    color: WidgetStateProperty.resolveWith<Color?>((
                      Set<WidgetState> states,
                    ) {
                      return entry.userId == currentUserUid
                          ? Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.2)
                          : null;
                    }),
                    cells: [
                      DataCell(Text('#${index + 1}', style: cellTextStyle)),
                      DataCell(Text('${entry.score}', style: cellTextStyle)),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            entry.platform,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: cellTextStyle,
                          ),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Text(
                            entry.device,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: cellTextStyle,
                          ),
                        ),
                      ),
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
                        ).colorScheme.secondary.withValues(alpha: 0.2)
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
    );
  }
}
