import 'package:flutter_2048/l10n/app_localizations.dart';

/// Legacy mode flag, kept only for the timed clock.
///
/// Modes are described by [RuleSet] now. `challenge` and `evilAI` are gone
/// with the code behind them — neither could be started and neither worked.
enum GameMode { normal, timed, hardcore, zen }

String gameModeToString(GameMode mode,  AppLocalizations appLocales) {
  switch (mode) {
    case GameMode.normal:
      return appLocales.gameModeNormal;
    case GameMode.timed:
      return appLocales.gameModeTimed;
    case GameMode.hardcore:
      return appLocales.gameModeHardcore;
    case GameMode.zen:
      return appLocales.gameModeZen;
  }
}
