import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/config/ads_config.dart';
import 'package:flutter_2048/core/theme/app_theme.dart';
import 'package:flutter_2048/core/theme/theme_provider.dart';
import 'package:flutter_2048/domain/ai_difficultt.dart';
import 'package:flutter_2048/domain/game_mode.dart';
import 'package:flutter_2048/domain/prefs.dart';
import 'package:flutter_2048/presentation/widgets/language_selector.dart';
import 'package:flutter_2048/utils/helper.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import '../controllers/game_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _selectedSize = 0;
  AppTheme currentTheme = AppTheme.Classic;
  final prefs = Prefs();

  late BannerAd banner;
  var adRequest = const AdRequest(
    contextQuery: 'puzzle, games, mobile apps, games',
  );
  var isLoading = false;
  var isBannerAlreadyCreated = false;
  var bannerHeight = 0;

  Future<void> _checkAdConfigAndLoadAd() async {
    final configRef = FirebaseDatabase.instance.ref().child('config');
    // configRef.keepSynced(true);
    final snapshot = await configRef.get();
    final config = (snapshot.value as Map);
    final adsEnabledConfig = config['settings_screen_ads_enabled'];
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
    init();
    print("CONFIG MAIN_PAGE: didChangeDependencies: $isBannerAlreadyCreated");
    if (!isBannerAlreadyCreated) {
      _checkAdConfigAndLoadAd(); // ✅ Now it's safe to use MediaQuery
    }
  }

  _createBanner(BannerAdSize adSize) {
    return BannerAd(
      adUnitId: AdsConfig.getSettingsBannerID(),
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

  void init() async {
    final size = await prefs.getGameBoardSize();
    final currentThemeName = await prefs.getCurrentTheme();

    final theme = AppTheme.values.firstWhere(
      (th) => th.name == currentThemeName,
      orElse: () {
        print("⚠️ Theme not found: $currentThemeName, using fallback.");
        return AppTheme.Classic;
      },
    );

    setState(() {
      _selectedSize = size;
      currentTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocales = AppLocalizations.of(context);
    if (appLocales == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final controller = Provider.of<GameController>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide > 600;

    return Stack(
      children: [
        // This will stretch to fill space *above the banner*
        Positioned.fill(
          bottom: isMobile() ? bannerHeight.toDouble() : 0,
          child: createContent(appLocales, controller, themeProvider, isTablet),
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

  Widget createContent(
    AppLocalizations appLocales,
    GameController controller,
    ThemeProvider themeProvider,
    bool isTablet,
  ) {
    final settingTextSize = isTablet ? 22.0 : 18.0;
    final valueTextSize = isTablet ? 20.0 : 16.0;
    final content = ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 16,
        vertical: 24,
      ),
      children: [
        ListTile(
          title: Text(
            appLocales.appSettings,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 32 : 16,
            ),
          ),
        ),
        SizedBox(height: isTablet ? 20 : 10),
        Card(
          child: Consumer<GameController>(
            builder: (context, controller, _) {
              return SwitchListTile(
                title: Text(
                  appLocales.soundEffects,
                  style: TextStyle(fontSize: settingTextSize),
                ),
                value: controller.soundEnabled,
                onChanged: (val) => controller.toggleSound(val),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                ),
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            title: Text(
              appLocales.highScoreTitle,
              style: TextStyle(fontSize: settingTextSize),
            ),
            subtitle: Text(
              '${controller.highScore}',
              style: TextStyle(fontSize: valueTextSize),
            ),
            trailing: IconButton(
              icon: Icon(Icons.refresh, size: isTablet ? 24 : 18),
              onPressed: () {
                controller.resetHighScore();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(appLocales.highScoreReset)),
                );
              },
            ),
          ),
        ),

        Card(
          child: Consumer<GameController>(
            builder: (context, controller, _) {
              return ListTile(
                title: Text(
                  appLocales.gameMode,
                  style: TextStyle(fontSize: settingTextSize),
                ),
                trailing: DropdownButton<GameMode>(
                  value: controller.mode,
                  items:
                      GameMode.values.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(
                            gameModeToString(mode, appLocales),
                            style: TextStyle(fontSize: valueTextSize),
                          ),
                        );
                      }).toList(),
                  onChanged: (mode) {
                    if (mode != null) controller.setGameMode(mode);
                  },
                ),
              );
            },
          ),
        ),

        Card(
          child: Consumer<GameController>(
            builder: (context, controller, _) {
              return ListTile(
                title: Text(
                  appLocales.aiDifficulty,
                  style: TextStyle(fontSize: settingTextSize),
                ),
                trailing: DropdownButton<AIDifficulty>(
                  value: controller.aiDifficulty,
                  items:
                      AIDifficulty.values.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(
                            aiDifficultyToString(level, appLocales),
                            style: TextStyle(fontSize: valueTextSize),
                          ),
                        );
                      }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.setAIDifficulty(val);
                  },
                ),
              );
            },
          ),
        ),

        if (_selectedSize <= 0)
          const Center(child: CircularProgressIndicator())
        else
          Card(
            child: ListTile(
              title: Text(
                appLocales.boardSize,
                style: TextStyle(fontSize: settingTextSize),
              ),
              trailing: DropdownButton<int>(
                value: _selectedSize,
                items:
                    [3, 4, 5, 6].map((size) {
                      return DropdownMenuItem(
                        value: size,
                        child: Text(
                          '${size}x$size',
                          style: TextStyle(fontSize: valueTextSize),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.setGridSize(value);
                    setState(() {
                      _selectedSize = value;
                    });
                  }
                },
              ),
            ),
          ),

        Card(
          child: ListTile(
            title: Text(
              appLocales.appTheme,
              style: TextStyle(fontSize: settingTextSize),
            ),
            trailing: DropdownButton<AppTheme>(
              value: currentTheme,
              items:
                  AppTheme.values.map((appTheme) {
                    return DropdownMenuItem(
                      value: appTheme,
                      child: Text(
                        appThemeToString(appTheme, appLocales),
                        style: TextStyle(fontSize: valueTextSize),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setTheme(value);
                  setState(() {
                    currentTheme = value;
                  });
                }
              },
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
              appLocales.language,
              style: TextStyle(fontSize: settingTextSize),
            ),
            trailing: LanguageSelector(isTablet: isTablet),
          ),
        ),
        const SizedBox(height: 16),

        Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 18 : 14,
              ),
              textStyle: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.replay),
            onPressed: () {
              controller.resetGame();
              Navigator.pop(context);
            },
            label: Text(
              appLocales.restartGame,
              style: TextStyle(fontSize: settingTextSize),
            ),
          ),
        ),
      ],
    );

    // ✅ Wrap for max width on tablets
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocales.settings,
          style: TextStyle(fontSize: isTablet ? 28 : 18),
        ),
      ),
      body:
          isTablet
              ? Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isTablet ? 700 : 600),
                  child: content,
                ),
              )
              : content,
    );
  }
}
