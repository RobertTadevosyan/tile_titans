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
    // 512 was in this pool and made roughly half of all dailies unwinnable:
    // it demands near-perfect play on a 4x4, which is too much to ask of a
    // puzzle that resets every day.
    (objective: const Objective.reachTile(128), summary: 'Forge a 128 tile'),
    (objective: const Objective.reachTile(256), summary: 'Forge a 256 tile'),
    (objective: const Objective.reachScore(1000), summary: 'Score 1,000'),
    (objective: const Objective.reachScore(2500), summary: 'Score 2,500'),
    (objective: const Objective.survive(60), summary: 'Survive 60 moves'),
    // "Hold N tiles of X at once" is deliberately absent here. It fights the
    // way people naturally play — anyone competent merges 32+32 on sight,
    // which destroys the condition — so it belongs in an authored trial the
    // player approaches knowingly, not in a daily that should be approachable.
    // Trials IV, X and XVII still use it.
  ];
  final chosen = random.pick(objectives);

  // Move budgets are derived from the material the objective needs, not chosen
  // by feel. Merging only redistributes value — spawns are the sole source — so
  // a target tile of T requires roughly T total value on the board, and each
  // move contributes about 2.2. The original budgets were under half of that
  // and left most dailies mathematically unwinnable.
  final moveLimit = switch (chosen.objective.kind) {
    ObjectiveKind.reachTile =>
      chosen.objective.target >= 512 ? 450 : 230,
    ObjectiveKind.reachScore => 400,
    ObjectiveKind.createTiles => 200,
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
