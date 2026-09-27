import 'package:flutter_2048/l10n/app_localizations.dart';

/// How the hint button and auto-play pick their move.
///
/// Named for an AI opponent that does not exist: this tunes the assistance
/// the player asks for, not a rival. The settings label used to promise
/// "AI Difficulty", which is why it needed saying twice.
enum AIDifficulty {
  /// Keeps the board open; the safe suggestion.
  easy,

  /// Weighs open space against merge potential.
  smart,

  /// Chases merges and score over safety.
  aggressive,
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
