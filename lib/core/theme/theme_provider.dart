import 'package:flutter/material.dart';
import 'package:flutter_2048/domain/prefs.dart';
import 'app_theme.dart';
import 'themes.dart';

/// The theme a player gets before they choose one.
///
/// Forge is the app's own palette — cold iron and ember — rather than the
/// green a thousand other merge games open with. It is also the only theme
/// designed for this app rather than inherited from the template it grew out
/// of, so it is what the game should look like by default.
const AppTheme kDefaultTheme = AppTheme.Forge;

class ThemeProvider extends ChangeNotifier {
  late ThemeData themeData;
  bool isInitialized = false;
  AppTheme currentTheme = kDefaultTheme;

  final Prefs prefs = Prefs();

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await prefs.getCurrentTheme(); // Async
    currentTheme = AppTheme.values.firstWhere(
      (theme) => theme.name == saved,
      orElse: () => kDefaultTheme,
    );
    themeData = appThemeData[currentTheme]!;
    isInitialized = true;
    notifyListeners();
  }

  void setTheme(AppTheme theme) {
    currentTheme = theme;
    themeData = appThemeData[theme]!;
    prefs.setCurrentTheme(theme.name); // Save
    notifyListeners();
  }
}