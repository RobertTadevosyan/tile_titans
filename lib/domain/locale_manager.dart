import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LocaleManager with ChangeNotifier {
  static const _localeKey = 'app_locale';
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    _locale = locale;
    notifyListeners();
  }
}
