import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum AppTheme { Classic, Dark, Ocean, Retro, Neon }

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
  }
}
