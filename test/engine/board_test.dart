import 'package:flutter_2048/domain/direction.dart';
import 'package:flutter_2048/domain/engine/board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('collapseLine', () {
    test('slides tiles toward index 0 without merging unequal values', () {
      expect(collapseLine([0, 2, 0, 4]), [2, 4, 0, 0]);
    });

    test('merges a matching pair into one doubled tile', () {
      expect(collapseLine([2, 2, 0, 0]), [4, 0, 0, 0]);
    });

    test('merges each tile at most once per move', () {
      // The classic 2048 rule: 2,2,2,2 becomes 4,4 — never 8.
      expect(collapseLine([2, 2, 2, 2]), [4, 4, 0, 0]);
    });

    test('merges the leading pair first', () {
      expect(collapseLine([4, 4, 8, 0]), [8, 8, 0, 0]);
    });

    test('leaves an already-collapsed line untouched', () {
      expect(collapseLine([8, 4, 2, 0]), [8, 4, 2, 0]);
    });

    test('does not merge across a blocked cell', () {
      expect(collapseLine([2, blockedCell, 2, 0]),
          [2, blockedCell, 2, 0]);
    });

    test('merges within a segment bounded by a blocked cell', () {
      expect(collapseLine([2, 2, blockedCell, 0]),
          [4, 0, blockedCell, 0]);
    });

    test('keeps blocked cells in place while tiles slide around them', () {
      expect(collapseLine([0, 4, blockedCell, 2]),
          [4, 0, blockedCell, 2]);
    });

    test('handles a line that is entirely blocked', () {
      final line = List<int>.filled(4, blockedCell);
      expect(collapseLine(line), line);
    });
  });

  group('applyMove', () {
    test('left move collapses every row toward x = 0', () {
      final result = applyMove([
        [0, 2, 0, 2],
        [4, 0, 4, 0],
        [0, 0, 0, 0],
        [8, 0, 0, 0],
      ], Direction.left);

      expect(result.board, [
        [4, 0, 0, 0],
        [8, 0, 0, 0],
        [0, 0, 0, 0],
        [8, 0, 0, 0],
      ]);
      expect(result.gained, 12); // 4 + 8
      expect(result.moved, isTrue);
    });

    test('right move collapses toward the far edge', () {
      final result = applyMove([
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ], Direction.right);

      expect(result.board.first, [0, 0, 0, 4]);
    });

    test('up move collapses columns toward y = 0', () {
      final result = applyMove([
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ], Direction.up);

      expect(result.board[0][0], 4);
      expect(result.board[1][0], 0);
    });

    test('down move collapses columns toward the bottom', () {
      final result = applyMove([
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ], Direction.down);

      expect(result.board[3][0], 4);
      expect(result.board[0][0], 0);
    });

    test('reports moved = false when the board cannot change', () {
      final board = [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ];
      final result = applyMove(board, Direction.left);

      expect(result.moved, isFalse);
      expect(result.gained, 0);
    });

    test('does not mutate the board it was given', () {
      final board = [
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      applyMove(board, Direction.left);

      expect(board[0], [2, 2, 0, 0], reason: 'input must be untouched');
    });

    test('reports merge positions in board coordinates', () {
      final result = applyMove([
        [0, 0, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ], Direction.right);

      expect(result.merges, hasLength(1));
      expect(result.merges.single.value, 4);
      expect(result.merges.single.x, 3);
      expect(result.merges.single.y, 0);
    });
  });

  group('board queries', () {
    test('emptyCells finds every zero', () {
      expect(emptyCells(emptyBoard(4)), hasLength(16));
    });

    test('hasMoves is true while an empty cell exists', () {
      expect(hasMoves(emptyBoard(4)), isTrue);
    });

    test('hasMoves is true on a full board with an adjacent pair', () {
      expect(
        hasMoves([
          [2, 2, 4, 8],
          [4, 8, 16, 32],
          [2, 4, 8, 16],
          [4, 8, 16, 32],
        ]),
        isTrue,
      );
    });

    test('hasMoves is false on a jammed board', () {
      expect(
        hasMoves([
          [2, 4, 2, 4],
          [4, 2, 4, 2],
          [2, 4, 2, 4],
          [4, 2, 4, 2],
        ]),
        isFalse,
      );
    });

    test('blocked cells do not count as playable space', () {
      expect(
        hasMoves([
          [2, 4, 2, 4],
          [4, 2, 4, 2],
          [2, 4, 2, 4],
          [4, 2, 4, blockedCell],
        ]),
        isFalse,
      );
    });

    test('maxTile and countTiles read the board', () {
      final board = [
        [2, 4, 4, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      expect(maxTile(board), 4);
      expect(countTiles(board, 4), 2);
      expect(countTiles(board, 8), 0);
    });
  });
}
