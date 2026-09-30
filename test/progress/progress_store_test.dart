import 'package:flutter_2048/domain/engine/trial.dart';
import 'package:flutter_2048/domain/progress/achievements.dart';
import 'package:flutter_2048/domain/progress/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ProgressStore> freshStore() async {
    final store = ProgressStore();
    await store.load();
    return store;
  }

  group('achievement content', () {
    test('ids are unique', () {
      final ids = achievements.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('rank thresholds are reachable with the points on offer', () {
      expect(
        maxAchievementPoints,
        greaterThanOrEqualTo(ranks.last.required),
        reason: 'Legend must be attainable',
      );
    });

    test('ranks are ordered', () {
      for (var i = 1; i < ranks.length; i++) {
        expect(ranks[i].required, greaterThan(ranks[i - 1].required));
      }
    });

    test('rankForPoints picks the highest earned rank', () {
      expect(rankForPoints(0).name, 'Novice');
      expect(rankForPoints(ranks.last.required + 500).name, 'Legend');
      expect(nextRankAfter(ranks.last.required + 500), isNull);
      expect(nextRankAfter(0)?.name, 'Warrior');
    });
  });

  group('statistics', () {
    test('start empty', () async {
      final store = await freshStore();
      expect(store.stats.gamesPlayed, 0);
      expect(store.stats.averageScore, 0);
      expect(store.stats.favouriteMode, isNull);
      expect(store.rank.name, 'Novice');
    });

    test('keep records separate per mode', () async {
      final store = await freshStore();
      await store.recordGame(
        mode: ModeKeys.classic,
        score: 5000,
        highestTile: 512,
        moves: 200,
        merges: 90,
        seconds: 300,
      );
      await store.recordGame(
        mode: ModeKeys.hardcore,
        score: 800,
        highestTile: 64,
        moves: 40,
        merges: 15,
        seconds: 60,
      );

      // A weak Hardcore run must not be compared against a strong Classic one.
      expect(store.stats.forMode(ModeKeys.classic).bestScore, 5000);
      expect(store.stats.forMode(ModeKeys.hardcore).bestScore, 800);
      expect(store.stats.forMode(ModeKeys.zen).isEmpty, isTrue);
    });

    test('lifetime figures are derived, never stored', () async {
      final store = await freshStore();
      await store.recordGame(
        mode: ModeKeys.classic,
        score: 1000,
        highestTile: 128,
        moves: 50,
        merges: 20,
        seconds: 100,
      );
      await store.recordGame(
        mode: ModeKeys.timeAttack,
        score: 3000,
        highestTile: 256,
        moves: 70,
        merges: 35,
        seconds: 90,
      );

      // Totals add up; bests are the best of any single mode, not a pool.
      expect(store.stats.gamesPlayed, 2);
      expect(store.stats.totalMerges, 55);
      expect(store.stats.playTimeSeconds, 190);
      expect(store.stats.bestScore, 3000);
      expect(store.stats.highestTile, 256);
    });

    test('per-mode records survive a reload', () async {
      final store = await freshStore();
      await store.recordGame(
        mode: ModeKeys.hardcore,
        score: 4200,
        highestTile: 256,
        moves: 120,
        merges: 60,
        seconds: 200,
      );

      final reloaded = await freshStore();
      expect(reloaded.stats.forMode(ModeKeys.hardcore).bestScore, 4200);
      expect(reloaded.stats.forMode(ModeKeys.classic).isEmpty, isTrue);
    });

    test(
      'version 1 pooled data folds into Classic rather than vanishing',
      () async {
        SharedPreferences.setMockInitialValues({
          'tt_stats':
              '{"gamesPlayed":7,"bestScore":9000,"highestTile":1024,'
              '"totalMerges":400,"totalMoves":900,"totalScore":30000,'
              '"longestGameMoves":300,"playTimeSeconds":1200}',
        });
        final store = ProgressStore();
        await store.load();

        expect(store.stats.forMode(ModeKeys.classic).bestScore, 9000);
        expect(
          store.stats.gamesPlayed,
          7,
          reason: 'a player must not lose their history to the format change',
        );
      },
    );

    test('accumulate across runs and keep bests', () async {
      final store = await freshStore();
      await store.recordGame(
        mode: ModeKeys.classic,
        score: 1200,
        highestTile: 128,
        moves: 90,
        merges: 40,
        seconds: 120,
      );
      await store.recordGame(
        mode: ModeKeys.classic,
        score: 800,
        highestTile: 64,
        moves: 60,
        merges: 25,
        seconds: 80,
      );

      expect(store.stats.gamesPlayed, 2);
      expect(store.stats.bestScore, 1200, reason: 'best must not regress');
      expect(store.stats.highestTile, 128);
      expect(store.stats.totalMerges, 65);
      expect(store.stats.longestGameMoves, 90);
      expect(store.stats.averageScore, 1000);
      expect(store.stats.favouriteMode, ModeKeys.classic);
    });

    test('favourite mode tracks the most played', () async {
      final store = await freshStore();
      for (var i = 0; i < 3; i++) {
        await store.recordGame(
          mode: ModeKeys.zen,
          score: 10,
          highestTile: 8,
          moves: 5,
          merges: 2,
          seconds: 10,
        );
      }
      await store.recordGame(
        mode: ModeKeys.classic,
        score: 10,
        highestTile: 8,
        moves: 5,
        merges: 2,
        seconds: 10,
      );
      expect(store.stats.favouriteMode, ModeKeys.zen);
    });

    test('survive a reload', () async {
      final store = await freshStore();
      await store.recordGame(
        mode: ModeKeys.classic,
        score: 5000,
        highestTile: 512,
        moves: 200,
        merges: 100,
        seconds: 300,
      );

      final reloaded = await freshStore();
      expect(reloaded.stats.bestScore, 5000);
      expect(reloaded.stats.highestTile, 512);
    });
  });

  group('achievement unlocking', () {
    test('unlocks on threshold and reports only newly earned ones', () async {
      final store = await freshStore();

      final first = await store.recordGame(
        mode: ModeKeys.classic,
        score: 100,
        highestTile: 128,
        moves: 10,
        merges: 5,
        seconds: 30,
      );
      expect(first.map((a) => a.id), contains('tile_128'));

      // Same achievement must not fire twice.
      final second = await store.recordGame(
        mode: ModeKeys.classic,
        score: 100,
        highestTile: 128,
        moves: 10,
        merges: 5,
        seconds: 30,
      );
      expect(second.map((a) => a.id), isNot(contains('tile_128')));
    });

    test('points and rank follow unlocks', () async {
      final store = await freshStore();
      expect(store.points, 0);

      await store.recordGame(
        mode: ModeKeys.classic,
        score: 100,
        highestTile: 2048,
        moves: 10,
        merges: 5,
        seconds: 30,
      );

      // 128 + 512 + 1024 + 2048 all unlock at once.
      expect(store.points, greaterThanOrEqualTo(75));
      expect(store.rank.name, isNot('Novice'));
    });

    test('tile progress is measured in doublings, not ratio', () async {
      final store = await freshStore();
      await store.recordGame(
        mode: ModeKeys.classic,
        score: 0,
        highestTile: 64,
        moves: 1,
        merges: 1,
        seconds: 1,
      );
      final titan = achievements.firstWhere((a) => a.id == 'tile_2048');
      final progress = store.progressToward(titan);

      // 64 is 5 doublings into an 10-doubling climb — about halfway, not 3%.
      expect(progress, greaterThan(0.4));
      expect(progress, lessThan(0.7));
    });
  });

  group('trial records', () {
    TrialResult win(String id, int moves) => TrialResult(
      trialId: id,
      outcome: TrialOutcome.won,
      movesUsed: moves,
      score: 500,
      highestTile: 128,
    );

    test('keep the fewest winning moves', () async {
      final store = await freshStore();
      await store.recordTrial(win('forge-1', 30), usedUndo: false);
      await store.recordTrial(win('forge-1', 22), usedUndo: false);
      await store.recordTrial(win('forge-1', 40), usedUndo: false);

      expect(store.recordFor('forge-1')!.bestMoves, 22);
      expect(store.trialsCompleted, 1);
    });

    test('a loss does not clear an earlier win', () async {
      final store = await freshStore();
      await store.recordTrial(win('forge-1', 25), usedUndo: false);
      await store.recordTrial(
        const TrialResult(
          trialId: 'forge-1',
          outcome: TrialOutcome.outOfMoves,
          movesUsed: 40,
          score: 100,
          highestTile: 32,
        ),
        usedUndo: true,
      );

      expect(store.recordFor('forge-1')!.completed, isTrue);
      expect(store.recordFor('forge-1')!.bestMoves, 25);
    });

    test('a clean win is remembered even after a later messy one', () async {
      final store = await freshStore();
      await store.recordTrial(win('forge-2', 30), usedUndo: false);
      await store.recordTrial(win('forge-2', 28), usedUndo: true);

      expect(store.recordFor('forge-2')!.cleanWin, isTrue);
      expect(store.trialsWonWithoutUndo, 1);
    });

    test('completing every trial in a chapter counts the chapter', () async {
      final store = await freshStore();
      expect(store.chaptersCompleted, 0);

      for (var i = 1; i <= 6; i++) {
        await store.recordTrial(win('forge-$i', 20), usedUndo: false);
      }
      expect(store.chaptersCompleted, 1);
      expect(store.hasAchievement('chapter_one'), isTrue);
    });

    test('records for unknown trials do not inflate the count', () async {
      final store = await freshStore();
      await store.recordTrial(win('retired-trial-99', 10), usedUndo: false);
      expect(store.trialsCompleted, 0);
    });
  });

  group('daily streak', () {
    test('consecutive days increment', () async {
      final store = await freshStore();
      await store.recordDaily(date: DateTime(2026, 9, 20), won: true);
      await store.recordDaily(date: DateTime(2026, 9, 21), won: true);
      await store.recordDaily(date: DateTime(2026, 9, 22), won: true);
      expect(store.dailyStreak, 3);
      expect(store.hasAchievement('daily_3'), isTrue);
    });

    test('a gap resets to one, because today still counts', () async {
      final store = await freshStore();
      await store.recordDaily(date: DateTime(2026, 9, 20), won: true);
      await store.recordDaily(date: DateTime(2026, 9, 25), won: true);
      expect(store.dailyStreak, 1);
    });

    test('the same day cannot be counted twice', () async {
      final store = await freshStore();
      await store.recordDaily(date: DateTime(2026, 9, 20), won: true);
      await store.recordDaily(date: DateTime(2026, 9, 20, 23), won: true);
      expect(store.dailyStreak, 1);
    });

    test('a loss does not advance the streak', () async {
      final store = await freshStore();
      await store.recordDaily(date: DateTime(2026, 9, 20), won: false);
      expect(store.dailyStreak, 0);
    });
  });

  test('reset clears everything', () async {
    final store = await freshStore();
    await store.recordGame(
      mode: ModeKeys.classic,
      score: 900,
      highestTile: 256,
      moves: 50,
      merges: 20,
      seconds: 60,
    );
    await store.reset();

    expect(store.stats.gamesPlayed, 0);
    expect(store.points, 0);
    expect(store.unlockedAchievements, isEmpty);

    final reloaded = await freshStore();
    expect(reloaded.stats.gamesPlayed, 0);
  });

  test('corrupt stored data does not crash the load', () async {
    SharedPreferences.setMockInitialValues({
      'tt_stats': 'not json at all',
      'tt_trial_records': '{{{',
    });
    final store = ProgressStore();
    await store.load();

    expect(store.stats.gamesPlayed, 0);
    expect(store.records, isEmpty);
    expect(store.isLoaded, isTrue);
  });
}
