/// Pure board mechanics. No Flutter, no I/O, no state — every function here
/// takes a board and returns a new one, so the rules can be unit tested and
/// replayed deterministically.
///
/// Cell encoding:
///   0   empty
///  >0   a tile value (always a power of two)
///  -1   a blocked cell: immovable, unmergeable, and it splits a line into
///       independent segments. Trials use these to shape a puzzle.
library;

import 'package:flutter_2048/domain/direction.dart';

/// A cell that nothing can move through or merge with.
const int blockedCell = -1;

/// Where a merge happened, so the presentation layer can animate it.
class MergeEvent {
  final int x;
  final int y;
  final int value;

  const MergeEvent(this.x, this.y, this.value);
}

/// One tile's journey during a move.
///
/// Movement has to be recorded *while* the line collapses. Trying to recover it
/// afterwards by matching tiles to board positions cannot work: once the board
/// has moved, a tile is no longer where it started, so every travelling tile
/// looks like a brand-new one and its path is lost.
class TileMove {
  final int fromX;
  final int fromY;
  final int toX;
  final int toY;

  /// The tile's value before the move.
  final int value;

  /// True when this tile merged into its destination, meaning it should slide
  /// the full distance and then disappear behind the doubled tile.
  final bool merged;

  const TileMove({
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.value,
    required this.merged,
  });

  bool get travelled => fromX != toX || fromY != toY;
}

/// The outcome of applying one move to a board.
class MoveResult {
  final List<List<int>> board;

  /// Points earned by this move — the sum of every tile created by merging.
  final int gained;

  /// Tiles created by merging this move.
  final List<MergeEvent> merges;

  /// Every tile's origin and destination, so the UI can animate real paths.
  final List<TileMove> moves;

  /// False when the move changed nothing, in which case callers must not
  /// consume a turn, push undo history, or spawn a tile.
  final bool moved;

  const MoveResult({
    required this.board,
    required this.gained,
    required this.merges,
    required this.moves,
    required this.moved,
  });

  /// Where the tile now sitting at ([x], [y]) came from, or null if it did not
  /// move. When two tiles merged into this cell the surviving path is the one
  /// that did not merge away.
  TileMove? originOf(int x, int y) {
    TileMove? best;
    for (final move in moves) {
      if (move.toX != x || move.toY != y) continue;
      if (best == null || (best.merged && !move.merged)) best = move;
    }
    return best;
  }
}

/// Collapses one line toward index 0, merging each pair at most once.
///
/// Blocked cells stay where they are and partition the line, so
/// `[2, -1, 2]` does not merge but `[2, 2, -1]` becomes `[4, 0, -1]`.
List<int> collapseLine(List<int> line) {
  final result = <int>[];
  var segment = <int>[];

  void flushSegment() {
    final compacted = segment.where((v) => v != 0).toList();
    final merged = <int>[];
    var i = 0;
    while (i < compacted.length) {
      if (i + 1 < compacted.length && compacted[i] == compacted[i + 1]) {
        merged.add(compacted[i] * 2);
        i += 2;
      } else {
        merged.add(compacted[i]);
        i++;
      }
    }
    while (merged.length < segment.length) {
      merged.add(0);
    }
    result.addAll(merged);
    segment = <int>[];
  }

  for (final cell in line) {
    if (cell == blockedCell) {
      flushSegment();
      result.add(blockedCell);
    } else {
      segment.add(cell);
    }
  }
  flushSegment();
  return result;
}

/// Same as [collapseLine] but also reports each merge and, crucially, where
/// every tile started and finished so paths can be animated.
List<int> _collapseLineTracked(
  List<int> line,
  List<_LineMerge> mergesOut,
  List<_LineMove> movesOut,
) {
  final result = <int>[];
  // Values paired with the index they occupied in the original line.
  var segment = <({int value, int index})>[];

  void flushSegment() {
    final compacted = segment.where((e) => e.value != 0).toList();
    final merged = <int>[];
    var i = 0;
    while (i < compacted.length) {
      final destination = result.length + merged.length;
      if (i + 1 < compacted.length &&
          compacted[i].value == compacted[i + 1].value) {
        final value = compacted[i].value * 2;
        mergesOut.add(_LineMerge(destination, value));
        // Both tiles travel to the destination; the second one merges away.
        movesOut.add(_LineMove(
          from: compacted[i].index,
          to: destination,
          value: compacted[i].value,
          merged: false,
        ));
        movesOut.add(_LineMove(
          from: compacted[i + 1].index,
          to: destination,
          value: compacted[i + 1].value,
          merged: true,
        ));
        merged.add(value);
        i += 2;
      } else {
        movesOut.add(_LineMove(
          from: compacted[i].index,
          to: destination,
          value: compacted[i].value,
          merged: false,
        ));
        merged.add(compacted[i].value);
        i++;
      }
    }
    while (merged.length < segment.length) {
      merged.add(0);
    }
    result.addAll(merged);
    segment = <({int value, int index})>[];
  }

  for (var index = 0; index < line.length; index++) {
    final cell = line[index];
    if (cell == blockedCell) {
      flushSegment();
      result.add(blockedCell);
    } else {
      segment.add((value: cell, index: index));
    }
  }
  flushSegment();
  return result;
}

class _LineMerge {
  final int index;
  final int value;
  const _LineMerge(this.index, this.value);
}

class _LineMove {
  final int from;
  final int to;
  final int value;
  final bool merged;
  const _LineMove({
    required this.from,
    required this.to,
    required this.value,
    required this.merged,
  });
}

/// Reads one line out of [board] in the order a move in [direction] collapses
/// it, so every direction reduces to "collapse toward index 0".
List<int> _readLine(List<List<int>> board, Direction direction, int i) {
  final size = board.length;
  switch (direction) {
    case Direction.left:
      return List<int>.from(board[i]);
    case Direction.right:
      return board[i].reversed.toList();
    case Direction.up:
      return List<int>.generate(size, (y) => board[y][i]);
    case Direction.down:
      return List<int>.generate(size, (y) => board[size - 1 - y][i]);
  }
}

/// Writes a collapsed line back, undoing the read transform.
void _writeLine(
  List<List<int>> board,
  Direction direction,
  int i,
  List<int> line,
) {
  final size = board.length;
  switch (direction) {
    case Direction.left:
      board[i] = line;
    case Direction.right:
      board[i] = line.reversed.toList();
    case Direction.up:
      for (var y = 0; y < size; y++) {
        board[y][i] = line[y];
      }
    case Direction.down:
      for (var y = 0; y < size; y++) {
        board[size - 1 - y][i] = line[y];
      }
  }
}

/// Maps a position within a collapsed line back to board coordinates.
({int x, int y}) _lineIndexToCell(Direction direction, int i, int index, int size) {
  switch (direction) {
    case Direction.left:
      return (x: index, y: i);
    case Direction.right:
      return (x: size - 1 - index, y: i);
    case Direction.up:
      return (x: i, y: index);
    case Direction.down:
      return (x: i, y: size - 1 - index);
  }
}

/// Applies one move. Returns a new board; [board] is not modified.
MoveResult applyMove(List<List<int>> board, Direction direction) {
  final size = board.length;
  final next = board.map((row) => List<int>.from(row)).toList();
  final merges = <MergeEvent>[];
  var gained = 0;
  var moved = false;

  final moves = <TileMove>[];

  for (var i = 0; i < size; i++) {
    final original = _readLine(board, direction, i);
    final lineMerges = <_LineMerge>[];
    final lineMoves = <_LineMove>[];
    final collapsed = _collapseLineTracked(original, lineMerges, lineMoves);

    if (!_sameLine(original, collapsed)) moved = true;

    for (final m in lineMerges) {
      gained += m.value;
      final cell = _lineIndexToCell(direction, i, m.index, size);
      merges.add(MergeEvent(cell.x, cell.y, m.value));
    }

    for (final m in lineMoves) {
      final from = _lineIndexToCell(direction, i, m.from, size);
      final to = _lineIndexToCell(direction, i, m.to, size);
      moves.add(TileMove(
        fromX: from.x,
        fromY: from.y,
        toX: to.x,
        toY: to.y,
        value: m.value,
        merged: m.merged,
      ));
    }
    _writeLine(next, direction, i, collapsed);
  }

  return MoveResult(
    board: next,
    gained: gained,
    merges: merges,
    moves: moves,
    moved: moved,
  );
}

bool _sameLine(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Coordinates of every empty cell, in row-major order.
List<({int x, int y})> emptyCells(List<List<int>> board) {
  final out = <({int x, int y})>[];
  for (var y = 0; y < board.length; y++) {
    for (var x = 0; x < board[y].length; x++) {
      if (board[y][x] == 0) out.add((x: x, y: y));
    }
  }
  return out;
}

/// True when at least one direction would change the board.
bool hasMoves(List<List<int>> board) {
  if (emptyCells(board).isNotEmpty) return true;
  for (final direction in Direction.values) {
    if (applyMove(board, direction).moved) return true;
  }
  return false;
}

/// Highest tile currently on the board, or 0 on an empty board.
int maxTile(List<List<int>> board) {
  var best = 0;
  for (final row in board) {
    for (final v in row) {
      if (v > best) best = v;
    }
  }
  return best;
}

/// How many tiles of exactly [value] are on the board.
int countTiles(List<List<int>> board, int value) {
  var n = 0;
  for (final row in board) {
    for (final v in row) {
      if (v == value) n++;
    }
  }
  return n;
}

/// An empty [size]×[size] board.
List<List<int>> emptyBoard(int size) =>
    List<List<int>>.generate(size, (_) => List<int>.filled(size, 0));

/// A deep copy, safe to mutate.
List<List<int>> cloneBoard(List<List<int>> board) =>
    board.map((row) => List<int>.from(row)).toList();
