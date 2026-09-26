import 'package:flutter_2048/domain/engine/board.dart';

/// What a trial asks the player to achieve.
enum ObjectiveKind {
  /// Create a tile of at least [Objective.target].
  reachTile,

  /// Reach a score of at least [Objective.target].
  reachScore,

  /// Have [Objective.count] tiles of exactly [Objective.target] on the board
  /// at the same time.
  createTiles,

  /// Still be able to move after [Objective.target] moves.
  survive,

  /// Merge away every blocked cell's neighbour — used by clearing puzzles where
  /// the goal is to empty the board down to [Objective.count] tiles or fewer.
  clearBoard,
}

/// A trial's win condition. Immutable and pure so it can be evaluated against
/// any board snapshot without side effects.
class Objective {
  final ObjectiveKind kind;

  /// Tile value, score, or move count depending on [kind].
  final int target;

  /// How many tiles are required, for [ObjectiveKind.createTiles] and
  /// [ObjectiveKind.clearBoard].
  final int count;

  const Objective({
    required this.kind,
    required this.target,
    this.count = 1,
  });

  const Objective.reachTile(int tile)
      : kind = ObjectiveKind.reachTile,
        target = tile,
        count = 1;

  const Objective.reachScore(int score)
      : kind = ObjectiveKind.reachScore,
        target = score,
        count = 1;

  const Objective.createTiles(int tile, int howMany)
      : kind = ObjectiveKind.createTiles,
        target = tile,
        count = howMany;

  const Objective.survive(int moves)
      : kind = ObjectiveKind.survive,
        target = moves,
        count = 1;

  const Objective.clearBoard(int tilesRemaining)
      : kind = ObjectiveKind.clearBoard,
        target = 0,
        count = tilesRemaining;

  /// True when the objective has been met by this snapshot.
  bool isMet({
    required List<List<int>> board,
    required int score,
    required int movesUsed,
  }) {
    switch (kind) {
      case ObjectiveKind.reachTile:
        return maxTile(board) >= target;
      case ObjectiveKind.reachScore:
        return score >= target;
      case ObjectiveKind.createTiles:
        return countTiles(board, target) >= count;
      case ObjectiveKind.survive:
        return movesUsed >= target;
      case ObjectiveKind.clearBoard:
        return _tileCount(board) <= count;
    }
  }

  /// Progress toward the objective in [0.0, 1.0], for progress indicators.
  double progress({
    required List<List<int>> board,
    required int score,
    required int movesUsed,
  }) {
    final value = switch (kind) {
      ObjectiveKind.reachTile => _ladderProgress(maxTile(board), target),
      ObjectiveKind.reachScore => target == 0 ? 1.0 : score / target,
      ObjectiveKind.createTiles =>
        count == 0 ? 1.0 : countTiles(board, target) / count,
      ObjectiveKind.survive => target == 0 ? 1.0 : movesUsed / target,
      ObjectiveKind.clearBoard => _clearProgress(board),
    };
    return value.clamp(0.0, 1.0);
  }

  /// Tile progress is measured in doublings, not raw value — going 256→512 is
  /// one step of the ladder, not a 100% jump.
  double _ladderProgress(int current, int goal) {
    if (current <= 0) return 0;
    if (current >= goal) return 1;
    final steps = _log2(goal) - 1; // from the starting 2-tile
    if (steps <= 0) return 1;
    return (_log2(current) - 1) / steps;
  }

  double _clearProgress(List<List<int>> board) {
    final remaining = _tileCount(board);
    if (remaining <= count) return 1;
    return count / remaining;
  }

  static int _tileCount(List<List<int>> board) {
    var n = 0;
    for (final row in board) {
      for (final v in row) {
        if (v > 0) n++;
      }
    }
    return n;
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
}

/// A limit the player must work inside. Constraints are what make two trials
/// with the same objective play differently.
class Constraints {
  /// Maximum moves, or null for unlimited.
  final int? moveLimit;

  /// Seconds available, or null for untimed.
  final int? timeLimit;

  /// Undo is unavailable when false.
  final bool allowUndo;

  /// The hint button is unavailable when false.
  final bool allowHints;

  const Constraints({
    this.moveLimit,
    this.timeLimit,
    this.allowUndo = true,
    this.allowHints = true,
  });

  bool get isLimited => moveLimit != null || timeLimit != null;

  /// True when the player has run out of room, independent of the board.
  bool isExhausted({required int movesUsed, required int secondsElapsed}) {
    if (moveLimit != null && movesUsed >= moveLimit!) return true;
    if (timeLimit != null && secondsElapsed >= timeLimit!) return true;
    return false;
  }
}
