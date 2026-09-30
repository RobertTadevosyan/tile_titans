import 'package:flutter_2048/content/trials.dart';
import 'package:flutter_2048/domain/engine/objective.dart';
import 'package:flutter_2048/domain/engine/trial.dart';
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

  /// A trial's display name.
  ///
  /// Trials are authored as data and carry English names — "Trial IV" — which
  /// were shown verbatim on every card and in every trial's app bar, in all
  /// ten languages. The number is the only part that varies, so the name is
  /// built from the trial's position rather than stored eighteen times per
  /// language.
  static String trialName(AppLocalizations l10n, Trial trial) {
    final index = allTrials.indexWhere((t) => t.id == trial.id);
    if (index < 0) return l10n.dailyTrialTitle; // the generated daily
    return l10n.trialName(_roman(index + 1));
  }

  /// Roman numerals for 1..18, which is every trial there is.
  static String _roman(int value) {
    const numerals = <int, String>{10: 'X', 9: 'IX', 5: 'V', 4: 'IV', 1: 'I'};
    final out = StringBuffer();
    var left = value;
    for (final entry in numerals.entries) {
      while (left >= entry.key) {
        out.write(entry.value);
        left -= entry.key;
      }
    }
    return out.toString();
  }

  /// An achievement's title, keyed on its stable id.
  ///
  /// Achievements shipped with English names and descriptions baked into the
  /// data, so a French or Japanese player read "First Blood — Forge a 128
  /// tile" in an otherwise translated app.
  static String achievementName(AppLocalizations l10n, String id) {
    switch (id) {
      case 'tile_128':
        return l10n.achFirstBlood;
      case 'tile_512':
        return l10n.achWarrior;
      case 'tile_1024':
        return l10n.achChampion;
      case 'tile_2048':
        return l10n.achTitanName;
      case 'tile_4096':
        return l10n.achBeyondGods;
      case 'trial_first':
        return l10n.achInitiate;
      case 'trial_six':
        return l10n.achProven;
      case 'trial_all':
        return l10n.achTrialmaster;
      case 'chapter_one':
        return l10n.achForgedName;
      case 'trial_clean':
        return l10n.achPerfectTrial;
      case 'daily_3':
        return l10n.achDedicated;
      case 'daily_7':
        return l10n.achRelentless;
      case 'score_10k':
        return l10n.achHoarder;
      case 'merges_1000':
        return l10n.achIronhand;
      case 'games_50':
        return l10n.achVeteran;
      default:
        return id;
    }
  }

  /// What an achievement asks for, built from its metric and threshold.
  ///
  /// Describing the measurement rather than storing fifteen sentences per
  /// language keeps the whole set localising from eight, and any achievement
  /// added later is translated the moment it picks a metric.
  static String achievementDescription(
    AppLocalizations l10n,
    Achievement achievement,
  ) {
    final n = achievement.threshold;
    switch (achievement.metric) {
      case AchievementMetric.highestTile:
        return l10n.objReachTile(n);
      case AchievementMetric.trialsCompleted:
        // "Every trial" is its own sentence: a count would read as a
        // coincidence rather than the whole set.
        return n >= allTrials.length
            ? l10n.achDescAllTrials
            : l10n.achDescTrials(n);
      case AchievementMetric.chaptersCompleted:
        return l10n.achDescChapter;
      case AchievementMetric.trialsWithoutUndo:
        return l10n.achDescCleanTrials(n);
      case AchievementMetric.dailyStreak:
        return l10n.achDescStreak(n);
      case AchievementMetric.bestScore:
        return l10n.achDescScore(n);
      case AchievementMetric.totalMerges:
        return l10n.achDescMerges(n);
      case AchievementMetric.gamesPlayed:
        return l10n.achDescGames(n);
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
}
