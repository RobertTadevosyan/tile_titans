import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_2048/content/trials.dart';
import 'package:flutter_2048/domain/engine/trial.dart';
import 'package:flutter_2048/domain/progress/achievements.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The canonical mode keys used for per-mode records.
///
/// Stable strings rather than an enum so stored statistics survive any future
/// reshuffling of the mode list.
class ModeKeys {
  const ModeKeys._();

  static const String classic = 'classic';
  static const String zen = 'zen';
  static const String timeAttack = 'timeAttack';
  static const String hardcore = 'hardcore';

  /// Free-play modes, in the order the home screen presents them.
  static const List<String> freePlay = [classic, zen, timeAttack, hardcore];
}

/// Statistics for one mode.
///
/// Records are kept per mode because the modes are not comparable: a Hardcore
/// score comes off a 5x5 board flooded with 4s, a Time Attack score comes from
/// ninety seconds, and Zen keeps no score at all. A single pooled "best score"
/// would compare none of them meaningfully.
@immutable
class ModeStats {
  final int gamesPlayed;
  final int bestScore;
  final int highestTile;
  final int totalMerges;
  final int totalMoves;
  final int totalScore;

  /// Longest single run in this mode, in moves.
  final int longestGameMoves;
  final int playTimeSeconds;

  const ModeStats({
    this.gamesPlayed = 0,
    this.bestScore = 0,
    this.highestTile = 0,
    this.totalMerges = 0,
    this.totalMoves = 0,
    this.totalScore = 0,
    this.longestGameMoves = 0,
    this.playTimeSeconds = 0,
  });

  /// Mean score per run in this mode, or 0 before the first one.
  int get averageScore => gamesPlayed == 0 ? 0 : totalScore ~/ gamesPlayed;

  bool get isEmpty => gamesPlayed == 0;

  ModeStats merging({
    required int score,
    required int highestTile,
    required int moves,
    required int merges,
    required int seconds,
  }) {
    return ModeStats(
      gamesPlayed: gamesPlayed + 1,
      bestScore: score > bestScore ? score : bestScore,
      highestTile:
          highestTile > this.highestTile ? highestTile : this.highestTile,
      totalMerges: totalMerges + merges,
      totalMoves: totalMoves + moves,
      totalScore: totalScore + score,
      longestGameMoves: moves > longestGameMoves ? moves : longestGameMoves,
      playTimeSeconds: playTimeSeconds + seconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'gamesPlayed': gamesPlayed,
        'bestScore': bestScore,
        'highestTile': highestTile,
        'totalMerges': totalMerges,
        'totalMoves': totalMoves,
        'totalScore': totalScore,
        'longestGameMoves': longestGameMoves,
        'playTimeSeconds': playTimeSeconds,
      };

  static ModeStats fromJson(Map<String, dynamic> json) => ModeStats(
        gamesPlayed: json['gamesPlayed'] as int? ?? 0,
        bestScore: json['bestScore'] as int? ?? 0,
        highestTile: json['highestTile'] as int? ?? 0,
        totalMerges: json['totalMerges'] as int? ?? 0,
        totalMoves: json['totalMoves'] as int? ?? 0,
        totalScore: json['totalScore'] as int? ?? 0,
        longestGameMoves: json['longestGameMoves'] as int? ?? 0,
        playTimeSeconds: json['playTimeSeconds'] as int? ?? 0,
      );
}

/// Player statistics, held per mode with lifetime figures derived.
///
/// Nothing lifetime is stored: totals are summed and bests are maxed on read,
/// so the per-mode records can never drift out of step with the aggregate.
@immutable
class PlayerStats {
  final Map<String, ModeStats> byMode;

  const PlayerStats({this.byMode = const {}});

  ModeStats forMode(String mode) => byMode[mode] ?? const ModeStats();

  int _sum(int Function(ModeStats) field) =>
      byMode.values.fold<int>(0, (total, stats) => total + field(stats));

  int _max(int Function(ModeStats) field) => byMode.values
      .fold<int>(0, (best, stats) => field(stats) > best ? field(stats) : best);

  int get gamesPlayed => _sum((s) => s.gamesPlayed);
  int get totalMerges => _sum((s) => s.totalMerges);
  int get totalMoves => _sum((s) => s.totalMoves);
  int get totalScore => _sum((s) => s.totalScore);
  int get playTimeSeconds => _sum((s) => s.playTimeSeconds);

  /// The best score achieved in any single mode.
  ///
  /// This is a max across modes rather than a pooled record, so it always names
  /// an actual run rather than an average of incomparable ones.
  int get bestScore => _max((s) => s.bestScore);
  int get highestTile => _max((s) => s.highestTile);
  int get longestGameMoves => _max((s) => s.longestGameMoves);

  int get averageScore => gamesPlayed == 0 ? 0 : totalScore ~/ gamesPlayed;

  /// The mode played most, or null before anything is recorded.
  String? get favouriteMode {
    String? best;
    var mostGames = 0;
    byMode.forEach((mode, stats) {
      if (stats.gamesPlayed > mostGames) {
        mostGames = stats.gamesPlayed;
        best = mode;
      }
    });
    return best;
  }

  PlayerStats recording({
    required String mode,
    required int score,
    required int highestTile,
    required int moves,
    required int merges,
    required int seconds,
  }) {
    final updated = Map<String, ModeStats>.from(byMode);
    updated[mode] = forMode(mode).merging(
      score: score,
      highestTile: highestTile,
      moves: moves,
      merges: merges,
      seconds: seconds,
    );
    return PlayerStats(byMode: updated);
  }

  Map<String, dynamic> toJson() => {
        'version': 2,
        'byMode': byMode.map((mode, stats) => MapEntry(mode, stats.toJson())),
      };

  static PlayerStats fromJson(Map<String, dynamic> json) {
    final modes = json['byMode'];
    if (modes is Map) {
      return PlayerStats(
        byMode: modes.map(
          (mode, stats) => MapEntry(
            mode as String,
            ModeStats.fromJson(Map<String, dynamic>.from(stats as Map)),
          ),
        ),
      );
    }

    // Version 1 kept one pooled record with no mode attribution. Fold it into
    // Classic rather than discarding a player's history.
    final legacy = ModeStats.fromJson(json);
    if (legacy.gamesPlayed == 0) return const PlayerStats();
    return PlayerStats(byMode: {ModeKeys.classic: legacy});
  }
}

/// A player's best result on one trial.
@immutable
class TrialRecord {
  final String trialId;
  final bool completed;

  /// Fewest moves used in a winning attempt.
  final int bestMoves;
  final int bestScore;

  /// True when at least one win used no undo.
  final bool cleanWin;

  const TrialRecord({
    required this.trialId,
    this.completed = false,
    this.bestMoves = 0,
    this.bestScore = 0,
    this.cleanWin = false,
  });

  Map<String, dynamic> toJson() => {
        'completed': completed,
        'bestMoves': bestMoves,
        'bestScore': bestScore,
        'cleanWin': cleanWin,
      };

  static TrialRecord fromJson(String id, Map<String, dynamic> json) =>
      TrialRecord(
        trialId: id,
        completed: json['completed'] as bool? ?? false,
        bestMoves: json['bestMoves'] as int? ?? 0,
        bestScore: json['bestScore'] as int? ?? 0,
        cleanWin: json['cleanWin'] as bool? ?? false,
      );
}

/// Persists statistics, trial records, daily streak and unlocked achievements.
///
/// All keys are new and prefixed `tt_`, so nothing here can collide with the
/// original save data (`high_score`, `saved_board`, …) listed in the parity
/// contract.
class ProgressStore extends ChangeNotifier {
  static const _statsKey = 'tt_stats';
  static const _trialsKey = 'tt_trial_records';
  static const _achievementsKey = 'tt_achievements';
  static const _streakKey = 'tt_daily_streak';
  static const _lastDailyKey = 'tt_last_daily';

  PlayerStats _stats = const PlayerStats();
  Map<String, TrialRecord> _records = {};
  Set<String> _unlocked = {};
  int _dailyStreak = 0;
  String? _lastDailyId;
  bool _loaded = false;

  PlayerStats get stats => _stats;
  Map<String, TrialRecord> get records => Map.unmodifiable(_records);
  Set<String> get unlockedAchievements => Set.unmodifiable(_unlocked);
  int get dailyStreak => _dailyStreak;
  bool get isLoaded => _loaded;

  /// Trials finished, capped at the size of the library so a removed trial
  /// cannot inflate the count.
  int get trialsCompleted =>
      _records.values.where((r) => r.completed && trialById(r.trialId) != null)
          .length;

  int get trialsWonWithoutUndo =>
      _records.values.where((r) => r.completed && r.cleanWin).length;

  /// Chapters where every trial is complete.
  int get chaptersCompleted => trialChapters
      .where((c) => c.trials.every((t) => _records[t.id]?.completed == true))
      .length;

  /// Achievement points earned.
  int get points => achievements
      .where((a) => _unlocked.contains(a.id))
      .fold<int>(0, (sum, a) => sum + a.points);

  Rank get rank => rankForPoints(points);
  Rank? get nextRank => nextRankAfter(points);

  bool hasAchievement(String id) => _unlocked.contains(id);
  TrialRecord? recordFor(String trialId) => _records[trialId];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final statsRaw = prefs.getString(_statsKey);
    if (statsRaw != null) {
      try {
        _stats = PlayerStats.fromJson(
            jsonDecode(statsRaw) as Map<String, dynamic>);
      } catch (_) {
        // Corrupt payload: start clean rather than crash on launch.
        _stats = const PlayerStats();
      }
    }

    final trialsRaw = prefs.getString(_trialsKey);
    if (trialsRaw != null) {
      try {
        final decoded = jsonDecode(trialsRaw) as Map<String, dynamic>;
        _records = decoded.map((id, value) => MapEntry(
            id, TrialRecord.fromJson(id, value as Map<String, dynamic>)));
      } catch (_) {
        _records = {};
      }
    }

    _unlocked = (prefs.getStringList(_achievementsKey) ?? const []).toSet();
    _dailyStreak = prefs.getInt(_streakKey) ?? 0;
    _lastDailyId = prefs.getString(_lastDailyKey);
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(_stats.toJson()));
    await prefs.setString(
      _trialsKey,
      jsonEncode(_records.map((id, r) => MapEntry(id, r.toJson()))),
    );
    await prefs.setStringList(_achievementsKey, _unlocked.toList());
    await prefs.setInt(_streakKey, _dailyStreak);
    if (_lastDailyId != null) {
      await prefs.setString(_lastDailyKey, _lastDailyId!);
    }
  }

  /// Records a finished run. Returns any achievements newly unlocked, so the
  /// UI can celebrate them.
  Future<List<Achievement>> recordGame({
    required String mode,
    required int score,
    required int highestTile,
    required int moves,
    required int merges,
    required int seconds,
  }) async {
    _stats = _stats.recording(
      mode: mode,
      score: score,
      highestTile: highestTile,
      moves: moves,
      merges: merges,
      seconds: seconds,
    );

    final newlyUnlocked = _evaluateAchievements();
    await _persist();
    notifyListeners();
    return newlyUnlocked;
  }

  /// Records a trial attempt, keeping the best result.
  Future<List<Achievement>> recordTrial(TrialResult result,
      {required bool usedUndo}) async {
    final existing = _records[result.trialId];
    final wasCompleted = existing?.completed ?? false;
    final cleanWin =
        (existing?.cleanWin ?? false) || (result.won && !usedUndo);

    _records[result.trialId] = TrialRecord(
      trialId: result.trialId,
      completed: wasCompleted || result.won,
      bestMoves: result.won
          ? (existing == null || existing.bestMoves == 0
              ? result.movesUsed
              : (result.movesUsed < existing.bestMoves
                  ? result.movesUsed
                  : existing.bestMoves))
          : (existing?.bestMoves ?? 0),
      bestScore: result.score > (existing?.bestScore ?? 0)
          ? result.score
          : (existing?.bestScore ?? 0),
      cleanWin: cleanWin,
    );

    final newlyUnlocked = _evaluateAchievements();
    await _persist();
    notifyListeners();
    return newlyUnlocked;
  }

  /// Records a Daily Trial result and maintains the streak.
  ///
  /// The streak advances only on consecutive calendar days; a gap resets it to
  /// 1 rather than 0, because today still counts.
  Future<List<Achievement>> recordDaily({
    required DateTime date,
    required bool won,
  }) async {
    if (!won) return const [];

    final today = dailyTrialFor(date).id;
    if (_lastDailyId == today) return const []; // already counted

    final yesterday = dailyTrialFor(
      DateTime(date.year, date.month, date.day).subtract(
        const Duration(days: 1),
      ),
    ).id;

    _dailyStreak = (_lastDailyId == yesterday) ? _dailyStreak + 1 : 1;
    _lastDailyId = today;

    final newlyUnlocked = _evaluateAchievements();
    await _persist();
    notifyListeners();
    return newlyUnlocked;
  }

  /// Unlocks everything whose threshold is now met. Pure read of current state,
  /// so it is safe to call repeatedly.
  List<Achievement> _evaluateAchievements() {
    final newly = <Achievement>[];
    for (final achievement in achievements) {
      if (_unlocked.contains(achievement.id)) continue;
      if (_currentValue(achievement.metric) >= achievement.threshold) {
        _unlocked.add(achievement.id);
        newly.add(achievement);
      }
    }
    return newly;
  }

  int _currentValue(AchievementMetric metric) {
    switch (metric) {
      case AchievementMetric.highestTile:
        return _stats.highestTile;
      case AchievementMetric.bestScore:
        return _stats.bestScore;
      case AchievementMetric.gamesPlayed:
        return _stats.gamesPlayed;
      case AchievementMetric.totalMerges:
        return _stats.totalMerges;
      case AchievementMetric.trialsCompleted:
        return trialsCompleted;
      case AchievementMetric.chaptersCompleted:
        return chaptersCompleted;
      case AchievementMetric.dailyStreak:
        return _dailyStreak;
      case AchievementMetric.trialsWithoutUndo:
        return trialsWonWithoutUndo;
    }
  }

  /// Progress toward an achievement in [0.0, 1.0], for locked-state UI.
  double progressToward(Achievement achievement) {
    if (_unlocked.contains(achievement.id)) return 1;
    if (achievement.threshold <= 0) return 1;
    final value = _currentValue(achievement.metric);
    if (achievement.metric == AchievementMetric.highestTile) {
      // Tile progress is a ladder, not a ratio.
      if (value <= 0) return 0;
      final steps = _log2(achievement.threshold) - 1;
      if (steps <= 0) return 1;
      return ((_log2(value) - 1) / steps).clamp(0.0, 1.0);
    }
    return (value / achievement.threshold).clamp(0.0, 1.0);
  }

  static int _log2(int v) {
    var n = 0;
    var x = v;
    while (x > 1) {
      x >>= 1;
      n++;
    }
    return n;
  }

  /// Wipes progress. Used by the existing "reset" affordance in Settings.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statsKey);
    await prefs.remove(_trialsKey);
    await prefs.remove(_achievementsKey);
    await prefs.remove(_streakKey);
    await prefs.remove(_lastDailyKey);
    _stats = const PlayerStats();
    _records = {};
    _unlocked = {};
    _dailyStreak = 0;
    _lastDailyId = null;
    notifyListeners();
  }
}
