// ignore_for_file: constant_identifier_names
//
// These names are persisted, not just written: ThemeProvider saves
// `theme.name` to preferences and matches on it at launch. Renaming them to
// lowerCamelCase would leave every existing player's saved theme unmatched,
// silently resetting them to the default. The lint is correct in general and
// wrong here.
import 'package:flutter_2048/l10n/app_localizations.dart';

enum AppTheme { Classic, Dark, Ocean, Retro, Neon, Forge }

String appThemeToString(AppTheme theme, AppLocalizations appLocales) {
  switch (theme) {
    case AppTheme.Classic:
      return appLocales.appThemeClassic;
    case AppTheme.Dark:
      return appLocales.appThemeDark;
    case AppTheme.Ocean:
      return appLocales.appThemeOcean;
    case AppTheme.Retro:
      return appLocales.appThemeRetro;
    case AppTheme.Neon:
      return appLocales.appThemeNeon;
    case AppTheme.Forge:
      return appLocales.appThemeForge;
  }
}
