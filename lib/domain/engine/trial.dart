import 'package:flutter_2048/domain/engine/board.dart';
import 'package:flutter_2048/domain/engine/objective.dart';
import 'package:flutter_2048/domain/engine/rules.dart';
import 'package:flutter_2048/domain/engine/seeded_random.dart';

/// A single authored puzzle: a fixed starting board, one objective, and the
/// constraints you must work inside.
///
/// Trials are the thing an endless merge game does not have. They are data, so
/// the library in `lib/content/trials.dart` can be read and verified at a
/// glance, and each one is reproducible — the same trial always starts from the
/// same board.
class Trial {
  /// Stable identifier used as a storage key. Never renumber these.
  final String id;

  /// Display name, e.g. "Trial IV".
  final String name;

  /// One short line describing the goal. Deliberately not a paragraph.
  final String summary;

  /// The starting board. `-1` marks a blocked cell.
  final List<List<int>> startBoard;

  final Objective objective;
  final Constraints constraints;

  /// Extra rule overrides on top of [RuleSet.trial].
  final RuleSet rules;

  const Trial({
    required this.id,
    required this.name,
    required this.summary,
    required this.startBoard,
    required this.objective,
    this.constraints = const Constraints(),
    this.rules = RuleSet.trial,
  });

  int get gridSize => startBoard.length;

  bool get hasBlockedCells =>
      startBoard.any((row) => row.any((c) => c == blockedCell));

  /// A fresh mutable copy of the starting position.
  List<List<int>> freshBoard() => cloneBoard(startBoard);
}

/// How a trial attempt finished.
enum TrialOutcome { won, outOfMoves, outOfTime, boardJammed }

/// Result of one attempt, for records and statistics.
class TrialResult {
  final String trialId;
  final TrialOutcome outcome;
  final int movesUsed;
  final int score;
  final int highestTile;

  const TrialResult({
    required this.trialId,
    required this.outcome,
    required this.movesUsed,
    required this.score,
    required this.highestTile,
  });

  bool get won => outcome == TrialOutcome.won;
}

/// Builds the Daily Titan Trial for a date.
///
/// Deterministic by construction: the same date produces the same board,
/// objective and constraints on every device, with no network call. This is
/// what lets a daily challenge exist without any backend.
Trial dailyTrialFor(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  final random = SeededRandom.forDate(day);

  const size = 4;
  final board = emptyBoard(size);

  // Seed a handful of starting tiles. Weighted low so the puzzle is about
  // building, not inheriting a nearly-solved board.
  final startingTiles = 4 + random.nextInt(3); // 4-6
  final values = [2, 2, 2, 4, 4, 8];
  var placed = 0;
  var guard = 0;
  while (placed < startingTiles && guard < 200) {
    guard++;
    final x = random.nextInt(size);
    final y = random.nextInt(size);
    if (board[y][x] != 0) continue;
    board[y][x] = random.pick(values);
    placed++;
  }

  // One blocked cell on roughly half of days, never in a corner — corners are
  // where the strategy lives, and blocking one is more frustrating than
  // interesting.
  if (random.nextInt(2) == 0) {
    var attempts = 0;
    while (attempts < 40) {
      attempts++;
      final x = random.nextInt(size);
      final y = random.nextInt(size);
      final isCorner = (x == 0 || x == size - 1) && (y == 0 || y == size - 1);
      if (isCorner || board[y][x] != 0) continue;
      board[y][x] = blockedCell;
      break;
    }
  }

  final objectives = <({Objective objective, String summary})>[
    (objective: const Objective.reachTile(256), summary: 'Forge a 256 tile'),
    (objective: const Objective.reachTile(512), summary: 'Forge a 512 tile'),
    (objective: const Objective.reachScore(3000), summary: 'Score 3,000'),
    (
      objective: const Objective.createTiles(64, 3),
      summary: 'Hold three 64 tiles at once'
    ),
    (objective: const Objective.survive(80), summary: 'Survive 80 moves'),
  ];
  final chosen = random.pick(objectives);

  // Move budgets scale with how demanding the objective is.
  final moveLimit = switch (chosen.objective.kind) {
    ObjectiveKind.reachTile =>
      chosen.objective.target >= 512 ? 220 : 130,
    ObjectiveKind.reachScore => 160,
    ObjectiveKind.createTiles => 150,
    ObjectiveKind.survive => null,
    ObjectiveKind.clearBoard => 120,
  };

  final stamp = '${day.year}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  return Trial(
    id: 'daily-$stamp',
    name: 'Daily Titan Trial',
    summary: chosen.summary,
    startBoard: board,
    objective: chosen.objective,
    constraints: Constraints(moveLimit: moveLimit, allowUndo: false),
    rules: RuleSet.trial,
  );
}
