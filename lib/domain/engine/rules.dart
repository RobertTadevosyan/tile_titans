import 'package:flutter_2048/domain/engine/board.dart';
import 'package:flutter_2048/domain/engine/seeded_random.dart';

/// How a mode behaves when the board fills up.
enum EndBehaviour {
  /// Normal 2048: no moves left means the run is over.
  gameOver,

  /// The run never ends — the lowest tiles are dissolved to make room.
  /// This is what makes Zen genuinely relaxed rather than "normal with the
  /// score hidden".
  dissolveLowest,

  /// The run ends when a limit is hit rather than when the board jams.
  objective,
}

/// The mechanical definition of a mode. Everything that makes modes play
/// differently lives here, so a mode is data rather than scattered `if`s.
class RuleSet {
  /// Board edge length.
  final int gridSize;

  /// Values a new tile can take, with their relative weights. Hardcore spawns
  /// 4s far more often, which is what actually makes it hard: the board fills
  /// with un-mergeable mid tiles.
  final Map<int, int> spawnWeights;

  /// How many tiles appear after each move.
  final int spawnPerMove;

  /// Whether a score is kept at all.
  final bool scored;

  final bool allowUndo;
  final bool allowHints;
  final EndBehaviour endBehaviour;

  /// Seconds on the clock, or null for untimed.
  final int? timeLimit;

  /// Seconds added per merge, for modes where chaining buys time.
  final int secondsPerMerge;

  const RuleSet({
    this.gridSize = 4,
    this.spawnWeights = const {2: 9, 4: 1},
    this.spawnPerMove = 1,
    this.scored = true,
    this.allowUndo = true,
    this.allowHints = true,
    this.endBehaviour = EndBehaviour.gameOver,
    this.timeLimit,
    this.secondsPerMerge = 0,
  });

  /// The strategic baseline. Unchanged from the original game.
  static const classic = RuleSet();

  /// No score, no loss. When the board jams, the lowest tiles dissolve so play
  /// continues indefinitely.
  static const zen = RuleSet(
    scored: false,
    endBehaviour: EndBehaviour.dissolveLowest,
  );

  /// Score attack on a clock where merges buy seconds, so chaining is the
  /// strategy rather than raw speed.
  static const timeAttack = RuleSet(
    timeLimit: 90,
    secondsPerMerge: 2,
    allowUndo: false,
    endBehaviour: EndBehaviour.gameOver,
  );

  /// Spawn pressure rather than a hidden button: a bigger board, two tiles per
  /// move, weighted toward 4s, with no assistance at all.
  static const hardcore = RuleSet(
    gridSize: 5,
    spawnWeights: {2: 3, 4: 7},
    spawnPerMove: 2,
    allowUndo: false,
    allowHints: false,
  );

  /// Objective play. Limits come from the trial's own constraints.
  static const trial = RuleSet(
    endBehaviour: EndBehaviour.objective,
  );

  RuleSet copyWith({
    int? gridSize,
    Map<int, int>? spawnWeights,
    int? spawnPerMove,
    bool? scored,
    bool? allowUndo,
    bool? allowHints,
    EndBehaviour? endBehaviour,
    int? timeLimit,
    int? secondsPerMerge,
  }) {
    return RuleSet(
      gridSize: gridSize ?? this.gridSize,
      spawnWeights: spawnWeights ?? this.spawnWeights,
      spawnPerMove: spawnPerMove ?? this.spawnPerMove,
      scored: scored ?? this.scored,
      allowUndo: allowUndo ?? this.allowUndo,
      allowHints: allowHints ?? this.allowHints,
      endBehaviour: endBehaviour ?? this.endBehaviour,
      timeLimit: timeLimit ?? this.timeLimit,
      secondsPerMerge: secondsPerMerge ?? this.secondsPerMerge,
    );
  }

  /// Picks a spawn value according to [spawnWeights].
  int rollSpawnValue(SeededRandom random) {
    final total = spawnWeights.values.fold<int>(0, (a, b) => a + b);
    var roll = random.nextInt(total);
    for (final entry in spawnWeights.entries) {
      roll -= entry.value;
      if (roll < 0) return entry.key;
    }
    return spawnWeights.keys.first;
  }
}

/// Removes the lowest-value tiles so a jammed Zen board can keep going.
/// Returns the new board and how many tiles were dissolved.
({List<List<int>> board, int dissolved}) dissolveLowestTiles(
  List<List<int>> board,
) {
  var lowest = 0;
  for (final row in board) {
    for (final v in row) {
      if (v > 0 && (lowest == 0 || v < lowest)) lowest = v;
    }
  }
  if (lowest == 0) return (board: board, dissolved: 0);

  final next = cloneBoard(board);
  var dissolved = 0;
  for (var y = 0; y < next.length; y++) {
    for (var x = 0; x < next[y].length; x++) {
      if (next[y][x] == lowest) {
        next[y][x] = 0;
        dissolved++;
      }
    }
  }
  return (board: next, dissolved: dissolved);
}
