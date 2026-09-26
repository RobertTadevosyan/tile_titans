
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_2048/config/ads_config.dart';
import 'package:flutter_2048/config/interstitial_service.dart';
import 'package:flutter_2048/domain/direction.dart';
import 'package:flutter_2048/domain/game_mode.dart';
import 'package:flutter_2048/presentation/screens/leaderboard_screen.dart';
import 'package:flutter_2048/presentation/screens/settings_screen.dart';
import 'package:flutter_2048/utils/helper.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import '../controllers/game_controller.dart';
import '../widgets/score_board.dart';
import '../widgets/game_board.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool isMoving = false;

  late BannerAd banner;
  var adRequest = const AdRequest(
    contextQuery: 'puzzle, games, mobile apps, games',
  );
  var isLoading = false;
  var isBannerAlreadyCreated = false;
  var bannerHeight = 0;
  BannerAd? _banner;


  /// Guards against showing more than one interstitial per game over.
  ///
  /// The game-over listener rebuilds for as long as `isOver` stays true, and
  /// each rebuild scheduled another post-frame callback, so a single loss could
  /// fire several ads back to back.
  ///
  /// It is seeded from the controller in initState rather than starting false.
  /// Entering this screen on a run that is *already* over — which is what
  /// tapping Continue after a loss does — otherwise looked exactly like the
  /// game ending, and fired an ad for a game the player had already finished.
  bool _interstitialShownThisGame = false;


  @override
  void initState() {
    super.initState();
    final isLandscape =
        WidgetsBinding.instance.window.physicalSize.aspectRatio > 1;
    if (isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    // Interstitials are owned by InterstitialService so the cooldown and the
    // ad-free grace period apply across every screen, not per screen.
    //
    // Only a game ending *while this screen is open* should trigger one.
    _interstitialShownThisGame = context.read<GameController>().gameOver.value;
  }




  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final controller = context.read<GameController>();
    controller.cancelTimers(); //
    // Release the native banner view; leaving it attached leaks a platform
    // view every time the board is opened and closed.
    _banner?.destroy();
    super.dispose();
  }



  /// Loads the board banner.
  ///
  /// Mirrors the home screen: the slot is sized from the calculated ad size and
  /// the AdWidget mounting drives the request. Calling loadAd() first throws
  /// MissingPluginException, because this SDK only registers a banner's
  /// platform channel once its widget is in the tree.
  Future<void> _loadGameBanner() async {
    if (!isMobile() || _banner != null) return;

    final width = MediaQuery.sizeOf(context).width.toInt();
    final size = BannerAdSize.sticky(width: width);
    final calculated = await size.getCalculatedBannerAdSize();
    if (!mounted) return;

    final ad = BannerAd(
      adUnitId: AdsConfig.getGameBannerID(),
      adSize: size,
      adRequest: adRequest,
      onAdLoaded: () {},
      onAdFailedToLoad: (_) {
        if (!mounted) return;
        setState(() {
          bannerHeight = 0;
          isBannerAlreadyCreated = false;
        });
      },
      onAdClicked: () {},
      onLeftApplication: () {},
      onReturnedToApplication: () {},
      onImpression: (_) {},
    );

    setState(() {
      _banner = ad;
      bannerHeight = calculated.height;
      isBannerAlreadyCreated = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadGameBanner();
    // No banner is requested here any more. The board carries no ad, so
    // loading one would request inventory that is never rendered — a wasted
    // fill and an impression nobody can see.
  }


  void _handleSwipe(
    Offset delta,
    GameController controller,
    AppLocalizations appLocales,
  ) {
    const threshold = 4.0;

    final dx = delta.dx;
    final dy = delta.dy;

    if (dx.abs() < threshold && dy.abs() < threshold) return;
    if (isMoving) return;

    if (dx.abs() > dy.abs()) {
      dx > 0
          ? controller.moveRight(context, appLocales)
          : controller.moveLeft(context, appLocales);
    } else {
      dy > 0
          ? controller.moveDown(context, appLocales)
          : controller.moveUp(context, appLocales);
    }

    isMoving = true;
    Future.delayed(const Duration(milliseconds: 150), () {
      isMoving = false;
    });
  }

  /// Clear space between the controls and the ad, so a swipe that overshoots
  /// the board does not land on the banner.
  static const double _bannerGap = 12;

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide > 600 && isMobile();
    final appLocales = AppLocalizations.of(context)!;
    return Consumer<GameController>(
      builder: (context, controller, _) {
        if (!controller.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return ValueListenableBuilder<bool>(
          valueListenable: controller.gameOver,
          builder: (context, isOver, child) {
            if (isOver && !_interstitialShownThisGame) {
              _interstitialShownThisGame = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<InterstitialService>().maybeShowAfterGameOver();
              });
            } else if (!isOver) {
              _interstitialShownThisGame = false;
            }
            return child!;
          },
          child: Stack(
            children: [
              // Content is inset by the banner's height plus a gap, so the ad
              // never sits directly beneath the controls. The board is a
              // swiping surface, and an ad flush against it invites mis-taps —
              // the separation is what keeps the placement safe.
              Positioned.fill(
                bottom: isBannerAlreadyCreated
                    ? bannerHeight.toDouble() + _bannerGap
                    : 0,
                child: screenContent(
                  appLocales,
                  controller,
                  context,
                  isTablet,
                  shortestSide,
                ),
              ),
              if (isBannerAlreadyCreated && _banner != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: bannerHeight.toDouble(),
                      child: AdWidget(bannerAd: _banner!),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget screenContent(
    AppLocalizations appLocales,
    GameController controller,
    BuildContext context,
    bool isTablet,
    double shortestSize,
  ) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isTablet) {
      return buildTabletUI(appLocales, controller, context);
    } else if (isLandscape) {
      return buildPhoneLandscapeUI(
        appLocales,
        controller,
        context,
        shortestSize,
      );
    } else {
      return buildPhonePortraitUI(appLocales, controller, context);
    }
  }

  Widget buildActionButtons(
    AppLocalizations appLocales,
    GameController controller,
    BuildContext context, {
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final textSize = isTablet ? 34.0 : 16.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 24,
              vertical: isTablet ? 20 : 16,
            ),
            textStyle: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: controller.resetGame,
          child: Text(appLocales.restart),
        ),
        const SizedBox(width: 16),
        if (controller.undoAllowed)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 20 : 16,
              ),
              textStyle: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: controller.canUndo ? controller.undo : null,
            child: Text(appLocales.undo),
          ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 24,
              vertical: isTablet ? 20 : 16,
            ),
            textStyle: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: !controller.hintsAllowed ? null : () {
            final hint = directionToEmoji(controller.getHint());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(appLocales.hintMessage(hint ?? '🤷🤔🛑 -> 🔄')),
              ),
            );
          },
          child: Text(appLocales.hint),
        ),
      ],
    );
  }

  Widget buildActionButtonsPhoneLandscape(
    AppLocalizations appLocales,
    GameController controller,
    BuildContext context,
  ) {
    if (kIsWeb) {
      return buildWebActionButtons(appLocales, controller, context);
    }
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: controller.resetGame,
              child: Text(appLocales.restart),
            ),
            const SizedBox(width: 16),
            if (controller.undoAllowed)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: controller.canUndo ? controller.undo : null,
                child: Text(appLocales.undo),
              ),
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: !controller.hintsAllowed ? null : () {
            final hint = controller.getHint();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(appLocales.hintMessage(hint ?? ''))),
            );
          },
          child: Text(appLocales.hint),
        ),
      ],
    );
  }

  Widget buildWebActionButtons(
    AppLocalizations appLocales,
    GameController controller,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: controller.resetGame,
          child: Text(appLocales.restart),
        ),
        const SizedBox(width: 16),
        if (controller.undoAllowed)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: controller.canUndo ? controller.undo : null,
            child: Text(appLocales.undo),
          ),
        const SizedBox(width: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: !controller.hintsAllowed ? null : () {
            final hint = controller.getHint();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(appLocales.hintMessage(hint ?? ''))),
            );
          },
          child: Text(appLocales.hint),
        ),
      ],
    );
  }

  Widget buildPhonePortraitUI(
    AppLocalizations appLocales,
    GameController controller,
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tile Titans'),
        actions: buildAppBarActions(appLocales, context, controller, false),
      ),
      body: GestureDetector(
        onPanUpdate:
            (details) => _handleSwipe(details.delta, controller, appLocales),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            children: [
              if (controller.scored)
                ScoreBoard(
                  score: controller.score,
                  highestScore: controller.sessionBestScore,
                  isLandscape: false,
                  isTablet: false,
                ),
              if (controller.mode == GameMode.timed)
                buildTimer(appLocales, controller, context, false),
              const SizedBox(height: 16),
              const GameBoard(
                minSize: 300,
                maxSize: 500,
                isTablet: false,
                isLandscape: false,
              ),
              const SizedBox(height: 16),
              buildActionButtons(
                appLocales,
                controller,
                context,
                isTablet: false,
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: Text(
                    appLocales.autoPlay,
                    style: TextStyle(fontSize: 14),
                  ),
                  value: controller.autoPlay,
                  onChanged:
                      (_) => controller.toggleAutoPlay(context, appLocales),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPhoneLandscapeUI(
    AppLocalizations appLocales,
    GameController controller,
    BuildContext context,
    double shortestSize,
  ) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: null, // Optional
      body: SafeArea(
        // 🛡️ avoids notch/overlay
        child: GestureDetector(
          onPanUpdate:
              (details) => _handleSwipe(details.delta, controller, appLocales),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: buildAppBarActions(
                          appLocales,
                          context,
                          controller,
                          false,
                        ),
                      ),
                      if (kIsWeb) SizedBox(height: 100),
                      if (controller.scored)
                        ScoreBoard(
                          score: controller.score,
                          highestScore: controller.sessionBestScore,
                          isTablet: false,
                          isLandscape: true,
                        ),
                      if (controller.mode == GameMode.timed)
                        buildTimer(appLocales, controller, context, false),
                      const SizedBox(height: 8),
                      buildActionButtonsPhoneLandscape(
                        appLocales,
                        controller,
                        context,
                      ),
                      if (kIsWeb) SizedBox(height: 100),
                      if(!kIsWeb) const SizedBox(height: 6),
                      Card(
                        child: SwitchListTile(
                          title: Text(
                            appLocales.autoPlay,
                            style: TextStyle(fontSize: 14),
                          ),
                          value: controller.autoPlay,
                          onChanged:
                              (_) => controller.toggleAutoPlay(
                                context,
                                appLocales,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: GameBoard(
                    maxSize: shortestSize - 80,
                    minSize: shortestSize - 80,
                    isTablet: false,
                    isLandscape: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildAppBarActions(
    AppLocalizations appLocales,
    BuildContext context,
    GameController controller,
    bool isTablet,
  ) {
    return [
      IconButton(
        icon: const Icon(Icons.auto_graph),
        iconSize: isTablet || kIsWeb ? 40 : 25,
        tooltip: appLocales.statistics,
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showStatisticsDialog(appLocales, context, controller, isTablet);
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.leaderboard),
        iconSize: isTablet || kIsWeb ? 40 : 25,
        tooltip: appLocales.leaderboard,
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
            );
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.settings),
        tooltip: appLocales.settings,
        iconSize: isTablet || kIsWeb ? 40 : 25,
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          });
        },
      ),
    ];
  }

  Widget buildTabletUI(
    AppLocalizations appLocales,
    GameController controller,
    BuildContext context,
  ) {
    final isLandscape =
        WidgetsBinding.instance.window.physicalSize.aspectRatio > 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocales.appTitle, style: TextStyle(fontSize: 28)),
        actions: buildAppBarActions(appLocales, context, controller, true),
      ),
      body: GestureDetector(
        onPanUpdate:
            (details) => _handleSwipe(details.delta, controller, appLocales),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  if (controller.scored)
                    ScoreBoard(
                      isTablet: true,
                      isLandscape: isLandscape,
                      score: controller.score,
                      highestScore: controller.sessionBestScore,
                    ),
                  if (controller.mode == GameMode.timed)
                    buildTimer(appLocales, controller, context, true),
                  const SizedBox(height: 16),
                  GameBoard(
                    maxSize: 600,
                    minSize: 400,
                    isTablet: true,
                    isLandscape: isLandscape,
                  ),
                  const SizedBox(height: 16),
                  buildActionButtons(
                    appLocales,
                    controller,
                    context,
                    isTablet: true,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: SwitchListTile(
                      title: Text(
                        appLocales.autoPlay,
                        style: TextStyle(fontSize: 14),
                      ),
                      value: controller.autoPlay,
                      onChanged:
                          (_) => controller.toggleAutoPlay(context, appLocales),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTimer(
    AppLocalizations appLocales,
    GameController controller,
    BuildContext context,
    bool isTablet,
  ) {
    final percent = controller.timeLeft / 60;
    return Column(
      children: [
        LinearProgressIndicator(
          value: percent,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          '${controller.timeLeft}s',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 28 : 16,
          ),
        ),
      ],
    );
  }

  showStatisticsDialog(
    AppLocalizations appLocales,
    BuildContext context,
    GameController controller,
    bool isTablet,
  ) {
    final textSize = isTablet ? 26.0 : 16.0;
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          backgroundColor: theme.appBarTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            appLocales.statistics,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.appBarTheme.foregroundColor,
              fontSize: isTablet ? 32 : 22,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appLocales.moves(controller.totalMoves),
                style: TextStyle(
                  color: theme.appBarTheme.foregroundColor,
                  fontSize: textSize,
                ),
              ),
              Text(
                appLocales.merges(controller.totalMerges),
                style: TextStyle(
                  color: theme.appBarTheme.foregroundColor,
                  fontSize: textSize,
                ),
              ),
              Text(
                appLocales.avgMerge(
                  controller.totalMerges == 0
                      ? 0
                      : (controller.totalMergeValue ~/ controller.totalMerges),
                ),
                style: TextStyle(
                  color: theme.appBarTheme.foregroundColor,
                  fontSize: textSize,
                ),
              ),
              Text(
                appLocales.mergeEfficiency(
                  controller.totalMoves == 0
                      ? 0
                      : (controller.totalMerges * 100 ~/ controller.totalMoves),
                ),
                style: TextStyle(
                  color: theme.appBarTheme.foregroundColor,
                  fontSize: textSize,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                appLocales.close,
                style: TextStyle(color: theme.appBarTheme.foregroundColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
