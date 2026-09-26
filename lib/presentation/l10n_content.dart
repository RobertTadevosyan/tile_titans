import 'package:flutter_2048/content/trials.dart';
import 'package:flutter_2048/domain/engine/objective.dart';
import 'package:flutter_2048/domain/progress/achievements.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';

/// Renders authored content in the player's language.
///
/// Trials, chapters and ranks are defined as data with English identifiers.
/// Translating them by storing a translated string per trial would mean 18
/// summaries in every language and a new set for every daily. Describing the
/// *objective* instead means all 18 trials, and every future Daily Trial,
/// localise from five sentences.
class ContentStrings {
  const ContentStrings._();

  /// A one-line description of what a trial asks for.
  static String objective(AppLocalizations l10n, Objective objective) {
    switch (objective.kind) {
      case ObjectiveKind.reachTile:
        return l10n.objReachTile(objective.target);
      case ObjectiveKind.reachScore:
        return l10n.objReachScore(objective.target);
      case ObjectiveKind.createTiles:
        return l10n.objCreateTiles(objective.count, objective.target);
      case ObjectiveKind.survive:
        return l10n.objSurvive(objective.target);
      case ObjectiveKind.clearBoard:
        return l10n.objClearBoard(objective.count);
    }
  }

  /// Chapter titles. Keyed on the stable chapter id, never on its English name.
  static String chapter(AppLocalizations l10n, String chapterId) {
    switch (chapterId) {
      case 'forge':
        return l10n.chapterForge;
      case 'proving':
        return l10n.chapterProving;
      case 'summit':
        return l10n.chapterSummit;
      default:
        return chapterId;
    }
  }

  static String chapterTheme(AppLocalizations l10n, String chapterId) {
    switch (chapterId) {
      case 'forge':
        return l10n.chapterForgeTheme;
      case 'proving':
        return l10n.chapterProvingTheme;
      case 'summit':
        return l10n.chapterSummitTheme;
      default:
        return '';
    }
  }

  /// Rank names on the Path of the Titans.
  static String rank(AppLocalizations l10n, Rank rank) {
    switch (rank.name) {
      case 'Novice':
        return l10n.rankNovice;
      case 'Warrior':
        return l10n.rankWarrior;
      case 'Champion':
        return l10n.rankChampion;
      case 'Titan':
        return l10n.rankTitan;
      case 'Legend':
        return l10n.rankLegend;
      default:
        return rank.name;
    }
  }

  /// Trial names stay as written — "Trial VII" is a Roman numeral and reads
  /// the same in every language the app ships.
  static String trialName(TrialChapter _, String name) => name;
}
