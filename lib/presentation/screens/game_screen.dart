import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_2048/config/ads_config.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  late final Future<InterstitialAdLoader> _adLoader;
  InterstitialAd? _ad;

  @override
  void initState() {
    super.initState();
    final isLandscape =
        WidgetsBinding.instance.window.physicalSize.aspectRatio > 1;
    if (isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    _adLoader = _createInterstitialAdLoader();
    _loadInterstitialAd();
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
    final adLoader = await _adLoader;
    await adLoader.loadAd(
      adRequestConfiguration: AdRequestConfiguration(
        adUnitId: AdsConfig.getInterstitialID(),
      ),
    ); // for debug you can use 'demo-interstitial-yandex'
  }

  _showIntestitialAd() async {
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

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _checkAdConfigAndLoadAd() async {
    final configRef = FirebaseDatabase.instance.ref().child('config');
    // configRef.keepSynced(true);
    final snapshot = await configRef.get();
    final config = (snapshot.value as Map);
    final adsEnabledConfig = config['game_screen_ads_enabled'];
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
      // adUnitId: '', // or 'demo-banner-yandex'
      adUnitId: AdsConfig.getGameBannerID(),
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
            if (isOver) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showIntestitialAd();
              });
            }
            return child!;
          },
          child: Stack(
            children: [
              // This will stretch to fill space *above the banner*
              Positioned.fill(
                bottom: isMobile() ? bannerHeight.toDouble() : 0,
                child: screenContent(
                  appLocales,
                  controller,
                  context,
                  isTablet,
                  shortestSide,
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child:
                      isBannerAlreadyCreated
                          ? AdWidget(bannerAd: banner)
                          : null,
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
        if (controller.mode != GameMode.hardcore)
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
          onPressed: () {
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
            if (controller.mode != GameMode.hardcore)
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
          onPressed: () {
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
        if (controller.mode != GameMode.hardcore)
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
          onPressed: () {
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
              if (controller.mode != GameMode.zen)
                ScoreBoard(
                  score: controller.score,
                  highestScore: controller.highScore,
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
              SwitchListTile(
                title: Text(
                  appLocales.autoPlay,
                  style: TextStyle(fontSize: 14),
                ),
                value: controller.autoPlay,
                onChanged:
                    (_) => controller.toggleAutoPlay(context, appLocales),
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
                      if (controller.mode != GameMode.zen)
                        ScoreBoard(
                          score: controller.score,
                          highestScore: controller.highScore,
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
                      SwitchListTile(
                        title: Text(
                          appLocales.autoPlay,
                          style: TextStyle(fontSize: 18),
                        ),
                        value: controller.autoPlay,
                        onChanged:
                            (_) =>
                                controller.toggleAutoPlay(context, appLocales),
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
                  if (controller.mode != GameMode.zen)
                    ScoreBoard(
                      isTablet: true,
                      isLandscape: isLandscape,
                      score: controller.score,
                      highestScore: controller.highScore,
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
                  SwitchListTile(
                    title: Text(
                      appLocales.autoPlay,
                      style: TextStyle(fontSize: 24),
                    ),
                    value: controller.autoPlay,
                    onChanged:
                        (_) => controller.toggleAutoPlay(context, appLocales),
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
