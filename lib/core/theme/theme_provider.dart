import 'package:flutter/material.dart';
import 'package:flutter_2048/domain/prefs.dart';
import 'app_theme.dart';
import 'themes.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData themeData;
  bool isInitialized = false;
  AppTheme currentTheme = AppTheme.Classic;

  final Prefs prefs = Prefs();

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await prefs.getCurrentTheme(); // Async
    currentTheme = AppTheme.values.firstWhere(
      (theme) => theme.name == saved,
      orElse: () => AppTheme.Classic,
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