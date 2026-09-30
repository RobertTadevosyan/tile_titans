import 'package:flutter_2048/content/trials.dart';
import 'package:flutter_2048/domain/engine/board.dart';
import 'package:flutter_2048/domain/engine/rules.dart';
import 'package:flutter_2048/domain/engine/seeded_random.dart';
import 'package:flutter_test/flutter_test.dart';

/// The App Store rejection was about six modes that played identically. These
/// tests exist to make that regression loud: each rule set must differ
/// mechanically, not merely by label.
void main() {
  group('rule sets are mechanically distinct', () {
    test('no two modes share the same configuration', () {
      final signatures = <String>{};
      final modes = {
        'classic': RuleSet.classic,
        'zen': RuleSet.zen,
        'timeAttack': RuleSet.timeAttack,
        'hardcore': RuleSet.hardcore,
        'trial': RuleSet.trial,
      };

      modes.forEach((name, rules) {
        final signature = [
          rules.gridSize,
          rules.spawnWeights.toString(),
          rules.spawnPerMove,
          rules.scored,
          rules.allowUndo,
          rules.allowHints,
          rules.endBehaviour,
          rules.timeLimit,
          rules.secondsPerMerge,
        ].join('|');
        expect(
          signatures.add(signature),
          isTrue,
          reason: '$name is mechanically identical to another mode',
        );
      });
    });

    test('Zen removes scoring and cannot be lost', () {
      expect(RuleSet.zen.scored, isFalse);
      expect(RuleSet.zen.endBehaviour, EndBehaviour.dissolveLowest);
    });

    test('Time Attack pays seconds for merges', () {
      expect(RuleSet.timeAttack.timeLimit, isNotNull);
      expect(
        RuleSet.timeAttack.secondsPerMerge,
        greaterThan(0),
        reason: 'without this it is just a countdown, not a strategy',
      );
    });

    test('Hardcore is spawn pressure, not a hidden button', () {
      expect(RuleSet.hardcore.gridSize, greaterThan(RuleSet.classic.gridSize));
      expect(
        RuleSet.hardcore.spawnPerMove,
        greaterThan(RuleSet.classic.spawnPerMove),
      );
      expect(RuleSet.hardcore.allowUndo, isFalse);
      expect(RuleSet.hardcore.allowHints, isFalse);

      // The defining property: most spawns are 4s, which clog the board.
      final weights = RuleSet.hardcore.spawnWeights;
      final total = weights.values.fold<int>(0, (a, b) => a + b);
      expect((weights[4] ?? 0) / total, greaterThan(0.5));
    });

    test('Classic remains the unmodified baseline', () {
      expect(RuleSet.classic.gridSize, 4);
      expect(RuleSet.classic.spawnPerMove, 1);
      expect(RuleSet.classic.scored, isTrue);
      expect(RuleSet.classic.allowUndo, isTrue);
      expect(RuleSet.classic.endBehaviour, EndBehaviour.gameOver);
    });
  });

  group('player board-size preference', () {
    test('ordinary free play honours the setting', () {
      expect(RuleSet.classic.respectsPlayerGrid, isTrue);
      expect(RuleSet.zen.respectsPlayerGrid, isTrue);
      expect(RuleSet.timeAttack.respectsPlayerGrid, isTrue);
    });

    test('modes and trials that define their own grid opt out', () {
      expect(RuleSet.hardcore.respectsPlayerGrid, isFalse);
      expect(RuleSet.trial.respectsPlayerGrid, isFalse);
    });

    test('every authored trial pins its grid', () {
      for (final trial in allTrials) {
        expect(
          trial.rules.respectsPlayerGrid,
          isFalse,
          reason: '${trial.id} would be re-tuned by the player\'s setting',
        );
      }
    });
  });

  group('spawn weighting', () {
    test('classic spawns mostly 2s', () {
      final random = SeededRandom(42);
      var fours = 0;
      for (var i = 0; i < 1000; i++) {
        if (RuleSet.classic.rollSpawnValue(random) == 4) fours++;
      }
      expect(fours, lessThan(200), reason: 'classic is 10% fours');
    });

    test('hardcore spawns mostly 4s', () {
      final random = SeededRandom(42);
      var fours = 0;
      for (var i = 0; i < 1000; i++) {
        if (RuleSet.hardcore.rollSpawnValue(random) == 4) fours++;
      }
      expect(fours, greaterThan(600), reason: 'hardcore is 70% fours');
    });

    test('only ever spawns values the rule set declares', () {
      final random = SeededRandom(7);
      for (var i = 0; i < 300; i++) {
        expect(
          RuleSet.classic.spawnWeights.keys,
          contains(RuleSet.classic.rollSpawnValue(random)),
        );
      }
    });
  });

  group('Zen dissolve', () {
    test('clears the lowest tiles so a jammed board keeps going', () {
      final board = [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ];
      expect(hasMoves(board), isFalse);

      final result = dissolveLowestTiles(board);
      expect(result.dissolved, greaterThan(0));
      expect(hasMoves(result.board), isTrue, reason: 'Zen must never dead-end');
      expect(maxTile(result.board), 4, reason: 'only the 2s should go');
    });

    test('leaves an empty board alone', () {
      final result = dissolveLowestTiles(emptyBoard(4));
      expect(result.dissolved, 0);
    });

    test('does not disturb blocked cells', () {
      final board = [
        [2, blockedCell, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, blockedCell],
      ];
      final result = dissolveLowestTiles(board);
      expect(result.board[0][1], blockedCell);
      expect(result.board[3][3], blockedCell);
    });
  });
}
