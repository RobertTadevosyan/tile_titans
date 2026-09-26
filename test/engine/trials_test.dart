import 'package:flutter_2048/domain/direction.dart';
import 'package:flutter_2048/content/trials.dart';
import 'package:flutter_2048/domain/engine/board.dart';
import 'package:flutter_2048/domain/engine/trial.dart';
import 'package:flutter_test/flutter_test.dart';

bool _isPowerOfTwo(int v) => v > 0 && (v & (v - 1)) == 0;

void main() {
  group('trial library integrity', () {
    test('there is a substantial amount of authored content', () {
      expect(allTrials.length, greaterThanOrEqualTo(18));
      expect(trialChapters.length, 3);
    });

    test('every trial id is unique and stable-looking', () {
      final ids = allTrials.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate trial id');
      for (final id in ids) {
        expect(id, matches(RegExp(r'^[a-z]+-\d+$')));
      }
    });

    for (final chapter in trialChapters) {
      group('chapter ${chapter.name}', () {
        for (final trial in chapter.trials) {
          group(trial.id, () {
            test('board is square and matches the declared grid size', () {
              expect(trial.startBoard, isNotEmpty);
              for (final row in trial.startBoard) {
                expect(row.length, trial.startBoard.length,
                    reason: '${trial.id} board is not square');
              }
              expect(trial.rules.gridSize, trial.gridSize,
                  reason: '${trial.id} ruleset grid size disagrees with board');
            });

            test('every cell is empty, blocked, or a power of two', () {
              for (final row in trial.startBoard) {
                for (final cell in row) {
                  final valid =
                      cell == 0 || cell == blockedCell || _isPowerOfTwo(cell);
                  expect(valid, isTrue,
                      reason: '${trial.id} has invalid cell value $cell');
                }
              }
            });

            test('starts from a playable position', () {
              expect(hasMoves(trial.freshBoard()), isTrue,
                  reason: '${trial.id} starts jammed');
            });

            test('does not start already solved', () {
              final solved = trial.objective.isMet(
                board: trial.freshBoard(),
                score: 0,
                movesUsed: 0,
              );
              expect(solved, isFalse,
                  reason: '${trial.id} is already won on move zero');
            });

            test('leaves room to breathe', () {
              final empties = emptyCells(trial.freshBoard()).length;
              expect(empties, greaterThanOrEqualTo(2),
                  reason: '${trial.id} has almost no empty space');
            });

            test('constraints are sane', () {
              final limit = trial.constraints.moveLimit;
              final time = trial.constraints.timeLimit;
              if (limit != null) expect(limit, greaterThan(10));
              if (time != null) expect(time, greaterThanOrEqualTo(60));
            });

            test('has a short human summary', () {
              expect(trial.summary, isNotEmpty);
              expect(trial.summary.length, lessThan(60),
                  reason: 'summaries must be a line, not a paragraph');
            });
          });
        }
      });
    }

    test('blocked cells never occupy all four corners', () {
      for (final trial in allTrials) {
        final b = trial.startBoard;
        final n = b.length;
        final corners = [b[0][0], b[0][n - 1], b[n - 1][0], b[n - 1][n - 1]];
        final blockedCorners = corners.where((c) => c == blockedCell).length;
        expect(blockedCorners, lessThan(4),
            reason: '${trial.id} blocks every corner');
      }
    });

    test('the deterministic puzzle (Trial XII) is actually solvable', () {
      final trial = trialById('proving-6')!;
      expect(trial.rules.spawnPerMove, 0,
          reason: 'a fixed-position puzzle must not spawn tiles');

      // Known solution: collapse left twice, then up.
      var board = trial.freshBoard();
      var moves = 0;
      for (final direction in [
        Direction.left,
        Direction.left,
        Direction.up,
      ]) {
        final result = applyMove(board, direction);
        expect(result.moved, isTrue, reason: 'solution move $moves did nothing');
        board = result.board;
        moves++;
      }

      expect(
        trial.objective.isMet(board: board, score: 0, movesUsed: moves),
        isTrue,
        reason: 'the intended solution must satisfy the objective',
      );
      expect(moves, lessThanOrEqualTo(trial.constraints.moveLimit!));
    });

    test('lookup helpers resolve real trials and reject unknown ids', () {
      expect(trialById('forge-1'), isNotNull);
      expect(trialById('does-not-exist'), isNull);
      expect(chapterForTrial('forge-1')?.id, 'forge');
      expect(chapterForTrial('nope'), isNull);
    });
  });

  group('daily trial determinism', () {
    test('the same date always produces an identical trial', () {
      final a = dailyTrialFor(DateTime(2026, 9, 26));
      final b = dailyTrialFor(DateTime(2026, 9, 26));

      expect(a.id, b.id);
      expect(a.startBoard, b.startBoard);
      expect(a.objective.kind, b.objective.kind);
      expect(a.objective.target, b.objective.target);
      expect(a.constraints.moveLimit, b.constraints.moveLimit);
    });

    test('the time of day does not change the trial', () {
      final morning = dailyTrialFor(DateTime(2026, 9, 26, 6, 30));
      final night = dailyTrialFor(DateTime(2026, 9, 26, 23, 59));

      expect(morning.startBoard, night.startBoard);
      expect(morning.id, night.id);
    });

    test('different dates generally produce different boards', () {
      final boards = <String>{};
      for (var day = 1; day <= 28; day++) {
        final trial = dailyTrialFor(DateTime(2026, 9, day));
        boards.add(trial.startBoard.toString());
      }
      // Not demanding all-28-unique (collisions are legitimate), but a single
      // repeated board across a month would mean the seed is not varying.
      expect(boards.length, greaterThan(20));
    });

    test('the id encodes the date so records key correctly', () {
      expect(dailyTrialFor(DateTime(2026, 1, 5)).id, 'daily-2026-01-05');
    });

    test('generated dailies obey the same integrity rules as authored ones',
        () {
      for (var day = 1; day <= 31; day++) {
        final trial = dailyTrialFor(DateTime(2026, 3, day));
        expect(hasMoves(trial.freshBoard()), isTrue,
            reason: '${trial.id} starts jammed');
        expect(
          trial.objective.isMet(
            board: trial.freshBoard(),
            score: 0,
            movesUsed: 0,
          ),
          isFalse,
          reason: '${trial.id} starts solved',
        );
        expect(emptyCells(trial.freshBoard()).length, greaterThan(4));
      }
    });

    test('never blocks a corner', () {
      for (var day = 1; day <= 31; day++) {
        final b = dailyTrialFor(DateTime(2026, 5, day)).startBoard;
        final n = b.length;
        for (final corner in [
          b[0][0],
          b[0][n - 1],
          b[n - 1][0],
          b[n - 1][n - 1]
        ]) {
          expect(corner, isNot(blockedCell));
        }
      }
    });
  });
}
