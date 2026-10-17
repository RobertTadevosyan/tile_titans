import 'package:flutter/material.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_2048/core/theme/app_theme.dart';
import 'package:flutter_2048/core/theme/theme_provider.dart';
import 'package:flutter_2048/domain/ai_difficultt.dart';
import 'package:flutter_2048/domain/prefs.dart';
import 'package:flutter_2048/presentation/widgets/language_selector.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:flutter_2048/presentation/widgets/screen_banner.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _selectedSize = 0;
  AppTheme currentTheme = kDefaultTheme;
  final prefs = Prefs();

  void init() async {
    final size = await prefs.getGameBoardSize();
    final currentThemeName = await prefs.getCurrentTheme();

    final theme = AppTheme.values.firstWhere(
      (th) => th.name == currentThemeName,
      // A saved name that matches no theme — a renamed or removed one — falls
      // back to the app's default, not to Classic. Hardcoding Classic here
      // quietly contradicted kDefaultTheme.
      orElse: () => kDefaultTheme,
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

    return createContent(appLocales, controller, themeProvider, isTablet);
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

        // The Game Mode picker used to live here, listing the old GameMode
        // enum. Modes are now chosen from the home screen, where each card
        // states its rule difference — and the picker could contradict the
        // rule set actually in play, since it set a different field. Removed
        // rather than kept in sync.
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
              backgroundColor: titanButtonFill(context),
              foregroundColor: titanButtonLabel(context),
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
      bottomNavigationBar: const ScreenBanner(),
      appBar: AppBar(
        title: Text(
          appLocales.settings,
          style: TextStyle(fontSize: isTablet ? 28 : 18),
        ),
      ),
      // Capped by width, not by device class: a phone in landscape is ~850dp
      // wide and is not a "tablet", so settings rows used to stretch the whole
      // way across and the labels drifted far from their switches.
      body: TitanPage(child: content),
    );
  }
}
