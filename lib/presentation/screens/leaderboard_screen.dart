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

  /// The height of the divider between two rows, so the scroll maths matches
  /// what is actually laid out.
  static const double _separatorHeight = 1.0;

  /// The board being shown, fetched once.
  ///
  /// This used to be `future: fetchLeaderboard()` inside build(), so every
  /// rebuild — the ad banner reporting its height, the loading flag, a chip
  /// tap — started a fresh network read and dropped the list back to a
  /// spinner. The read is only 20 KB but takes about half a second, and it was
  /// being paid several times per visit.
  Future<List<LeaderboardEntry>>? _board;
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
    _board = fetchLeaderboard();
  }

  /// Switches boards, fetching the new one once.
  void _selectBoard(String mode) {
    if (mode == boardMode) return;
    setState(() {
      boardMode = mode;
      _board = fetchLeaderboard();
    });
  }

  /// Re-reads the current board on a pull-to-refresh.
  Future<void> _refresh() async {
    final next = fetchLeaderboard();
    setState(() => _board = next);
    await next;
  }

  /// Scrolls to the player's own row, or says why it cannot.
  ///
  /// This silently did nothing in three separate cases, which is why it looked
  /// like it worked only sometimes:
  ///
  ///  * the player has no row on *this* board — likely on Time Attack or
  ///    Hardcore, and on every board after a reinstall, since the anonymous
  ///    id changes and the old row stays behind under the old id. It now says
  ///    so instead of ignoring the tap.
  ///  * the offset assumed a 72px row, but each row is 72px plus a 1px
  ///    divider. By row 120 that is 120px of drift — nearly two rows short.
  ///  * nothing clamped the target, so a row near the end asked to scroll
  ///    past the end.
  void _scrollToUser(AppLocalizations appLocales, bool isTablet) {
    final index = leaderboardEntries.indexWhere(
      (entry) => entry.userId == currentUserUid,
    );
    if (index == -1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(appLocales.findMeNoEntry)));
      return;
    }
    if (!_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;

      // The tablet layout is a DataTable whose rows are not itemHeight tall,
      // so there is no pitch to multiply by; place the row proportionally.
      final target =
          isTablet
              ? (leaderboardEntries.isEmpty
                  ? 0.0
                  : max * (index / leaderboardEntries.length))
              : index * (itemHeight + _separatorHeight);

      _scrollController.animateTo(
        target.clamp(0.0, max),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  /// Turns the banner on only if the remote config says so.
  ///
  /// Both the read and the cast could throw, and this is fired from
  /// didChangeDependencies without an await or a catch, so on a device that
  /// cannot reach the database — offline, or simply slow — opening this screen
  /// raised an unhandled async error. `snapshot.value as Map` threw the same
  /// way whenever the config node was missing. Ads are the least important
  /// thing on the screen: if the config cannot be read, they stay off and the
  /// screen works.
  Future<void> _checkAdConfigAndLoadAd() async {
    if (!adsEnabled()) return;
    try {
      final snapshot =
          await FirebaseDatabase.instance.ref().child('config').get();
      final config = snapshot.value;
      if (config is! Map) return;
      final enabled = config['leaderboard_screen_ads_enabled'];
      if (enabled != true && enabled != 'true') return;
      if (!mounted) return;

      adRequest = const AdRequest(
        contextQuery: 'puzzle, games, mobile apps, games',
      );
      await _loadBanner();
    } catch (_) {
      // No banner, and nothing else changes.
    }
  }

  Future<void> _loadBanner() async {
    if (!adsEnabled()) return;
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
          bottom: adsEnabled() ? bannerHeight.toDouble() : 0,
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
            onPressed: () => _scrollToUser(appLocales, isTablet),
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
                onSelected: (_) => _selectBoard(entry.key),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBoard(AppLocalizations appLocales, bool isTablet) {
    return FutureBuilder<List<LeaderboardEntry>>(
      key: ValueKey(boardMode),
      future: _board,
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
          // Use ListView for phones. The board is fetched once, so pulling
          // down is how a player asks for fresh standings.
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
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
            ),
          );
        }
      },
    );
  }
}
