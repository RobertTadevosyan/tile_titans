import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum AIDifficulty {
  easy, // Choose move with most empty tiles
  smart, // Balance empty + merge potential
  aggressive, // Prioritize merges/score
}

String aiDifficultyToString(AIDifficulty diff, AppLocalizations appLocales) {
  switch (diff) {
    case AIDifficulty.easy:
      return appLocales.aiDiffEasy;
    case AIDifficulty.smart:
      return appLocales.aiDiffSmart;
    case AIDifficulty.aggressive:
      return appLocales.aiDiffAggressive;
  }
}
