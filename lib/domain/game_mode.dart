import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum GameMode { normal, timed, challenge, evilAI, hardcore, zen }

String gameModeToString(GameMode mode,  AppLocalizations appLocales) {
  switch (mode) {
    case GameMode.normal:
      return appLocales.gameModeNormal;
    case GameMode.timed:
      return appLocales.gameModeTimed;
    case GameMode.challenge:
      return appLocales.gameModeChallenge;
    case GameMode.evilAI:
      return appLocales.gameModeEvilAI;
    case GameMode.hardcore:
      return appLocales.gameModeHardcore;
    case GameMode.zen:
      return appLocales.gameModeZen;
  }
}
