import 'package:flutter_2048/domain/direction.dart';
import 'package:flutter_2048/domain/engine/board.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression coverage for the movement-path bug: tiles used to animate exactly
/// one cell regardless of how far they actually travelled, because identity was
/// recovered by matching positions *after* the board had already moved.
void main() {
  group('tile movement tracking', () {
    test('records the full distance a tile slides', () {
      final result = applyMove([
        [0, 0, 0, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ], Direction.left);

      final move = result.moves.single;
      expect(move.fromX, 3);
      expect(move.toX, 0);
      expect(
        move.travelled,
        isTrue,
        reason: 'a tile crossing the whole row must report the whole path',
      );
    });

    test('a tile that cannot move reports no travel', () {
      final result = applyMove([
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ], Direction.left);

      expect(result.moves.single.travelled, isFalse);
      expect(result.moved, isFalse);
    });

    test('both halves of a merge travel to the same destination', () {
      final result = applyMove([
        [2, 0, 0, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ], Direction.left);

      expect(result.moves, hasLength(2));
      for (final move in result.moves) {
        expect(move.toX, 0);
        expect(move.toY, 0);
      }
      // Exactly one of the pair is the tile that disappears.
      expect(result.moves.where((m) => m.merged), hasLength(1));
      expect(result.moves.where((m) => !m.merged), hasLength(1));
    });

    test('the surviving tile of a merge is the nearer one', () {
      final result = applyMove([
        [0, 2, 0, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ], Direction.left);

      final survivor = result.moves.firstWhere((m) => !m.merged);
      expect(survivor.fromX, 1, reason: 'the leading tile survives the merge');
    });

    test('originOf prefers the surviving path', () {
      final result = applyMove([
        [2, 0, 0, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ], Direction.left);

      final origin = result.originOf(0, 0)!;
      expect(origin.merged, isFalse);
      expect(origin.fromX, 0);
    });

    test('originOf returns null for a cell nothing moved into', () {
      final result = applyMove(emptyBoard(4), Direction.left);
      expect(result.originOf(2, 2), isNull);
    });

    test('tracks vertical travel', () {
      final result = applyMove([
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [4, 0, 0, 0],
      ], Direction.up);

      final move = result.moves.single;
      expect(move.fromY, 3);
      expect(move.toY, 0);
      expect(move.fromX, 0);
      expect(move.toX, 0);
    });

    test('tracks travel toward the far edge', () {
      final result = applyMove([
        [8, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ], Direction.right);

      final move = result.moves.single;
      expect(move.fromX, 0);
      expect(move.toX, 3);
    });

    test('a blocked cell stops travel short', () {
      final result = applyMove([
        [0, blockedCell, 0, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ], Direction.left);

      // The tile can only reach the far side of the blocker, not the wall.
      final move = result.moves.single;
      expect(move.fromX, 3);
      expect(move.toX, 2);
    });

    test('every non-empty cell of the result has a recorded origin', () {
      final board = [
        [2, 4, 0, 2],
        [0, 8, 8, 0],
        [4, 0, 0, 4],
        [0, 2, 0, 2],
      ];
      final result = applyMove(board, Direction.left);

      for (var y = 0; y < 4; y++) {
        for (var x = 0; x < 4; x++) {
          if (result.board[y][x] > 0) {
            expect(
              result.originOf(x, y),
              isNotNull,
              reason: 'tile at ($x,$y) has no path to animate from',
            );
          }
        }
      }
    });

    test('reported moves conserve every tile on the board', () {
      final board = [
        [2, 2, 4, 4],
        [8, 0, 8, 0],
        [0, 16, 0, 16],
        [2, 4, 8, 16],
      ];
      final before = board.expand((row) => row).where((v) => v > 0).length;
      final result = applyMove(board, Direction.left);

      expect(
        result.moves,
        hasLength(before),
        reason: 'every tile must be accounted for exactly once',
      );
    });
  });
}
