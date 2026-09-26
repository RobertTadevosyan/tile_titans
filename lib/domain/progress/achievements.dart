/// Achievement and rank content.
///
/// These are deliberately part of the product rather than platform achievements
/// buried in a system sheet: they are rendered in-app, they drive the Path of
/// the Titans rank, and they are visible from the home screen.
library;

/// What an achievement measures. Kept as an enum rather than a closure so the
/// whole set stays serialisable and testable.
enum AchievementMetric {
  highestTile,
  bestScore,
  gamesPlayed,
  totalMerges,
  trialsCompleted,
  chaptersCompleted,
  dailyStreak,
  trialsWithoutUndo,
}

class Achievement {
  /// Stable storage key. Never renumber.
  final String id;
  final String name;

  /// One line, shown under the name.
  final String description;
  final AchievementMetric metric;

  /// The value that unlocks it.
  final int threshold;

  /// Points toward the player's rank.
  final int points;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.metric,
    required this.threshold,
    this.points = 10,
  });
}

const List<Achievement> achievements = [
  // The tile ladder — the spine of the game's progression.
  Achievement(
    id: 'tile_128',
    name: 'First Blood',
    description: 'Forge a 128 tile',
    metric: AchievementMetric.highestTile,
    threshold: 128,
    points: 5,
  ),
  Achievement(
    id: 'tile_512',
    name: 'Warrior',
    description: 'Forge a 512 tile',
    metric: AchievementMetric.highestTile,
    threshold: 512,
    points: 10,
  ),
  Achievement(
    id: 'tile_1024',
    name: 'Champion',
    description: 'Forge a 1024 tile',
    metric: AchievementMetric.highestTile,
    threshold: 1024,
    points: 20,
  ),
  Achievement(
    id: 'tile_2048',
    name: 'Titan',
    description: 'Forge a 2048 tile',
    metric: AchievementMetric.highestTile,
    threshold: 2048,
    points: 40,
  ),
  Achievement(
    id: 'tile_4096',
    name: 'Beyond the Gods',
    description: 'Forge a 4096 tile',
    metric: AchievementMetric.highestTile,
    threshold: 4096,
    points: 80,
  ),

  // Trials — the differentiating content, so it carries real weight.
  Achievement(
    id: 'trial_first',
    name: 'Initiate',
    description: 'Complete your first Titan Trial',
    metric: AchievementMetric.trialsCompleted,
    threshold: 1,
    points: 10,
  ),
  Achievement(
    id: 'trial_six',
    name: 'Proven',
    description: 'Complete six Titan Trials',
    metric: AchievementMetric.trialsCompleted,
    threshold: 6,
    points: 20,
  ),
  Achievement(
    id: 'trial_all',
    name: 'Trialmaster',
    description: 'Complete every Titan Trial',
    metric: AchievementMetric.trialsCompleted,
    threshold: 18,
    points: 100,
  ),
  Achievement(
    id: 'chapter_one',
    name: 'Forged',
    description: 'Complete a full chapter',
    metric: AchievementMetric.chaptersCompleted,
    threshold: 1,
    points: 25,
  ),
  Achievement(
    id: 'trial_clean',
    name: 'Perfect Trial',
    description: 'Complete five trials without undo',
    metric: AchievementMetric.trialsWithoutUndo,
    threshold: 5,
    points: 25,
  ),

  // Daily — rewards returning.
  Achievement(
    id: 'daily_3',
    name: 'Dedicated',
    description: 'A 3-day Daily Trial streak',
    metric: AchievementMetric.dailyStreak,
    threshold: 3,
    points: 15,
  ),
  Achievement(
    id: 'daily_7',
    name: 'Relentless',
    description: 'A 7-day Daily Trial streak',
    metric: AchievementMetric.dailyStreak,
    threshold: 7,
    points: 30,
  ),

  // Volume.
  Achievement(
    id: 'score_10k',
    name: 'Hoarder',
    description: 'Score 10,000 in a single run',
    metric: AchievementMetric.bestScore,
    threshold: 10000,
    points: 20,
  ),
  Achievement(
    id: 'merges_1000',
    name: 'Ironhand',
    description: 'Merge 1,000 tiles in total',
    metric: AchievementMetric.totalMerges,
    threshold: 1000,
    points: 15,
  ),
  Achievement(
    id: 'games_50',
    name: 'Veteran',
    description: 'Play 50 games',
    metric: AchievementMetric.gamesPlayed,
    threshold: 50,
    points: 15,
  ),
];

/// A rung on the Path of the Titans. Rank is derived from achievement points,
/// so it always reflects real accomplishment and can never be bought or ground
/// out with a currency.
class Rank {
  final String name;

  /// Points required to hold this rank.
  final int required;

  const Rank(this.name, this.required);
}

const List<Rank> ranks = [
  Rank('Novice', 0),
  Rank('Warrior', 40),
  Rank('Champion', 110),
  Rank('Titan', 220),
  Rank('Legend', 350),
];

/// The highest rank earned with [points].
Rank rankForPoints(int points) {
  var current = ranks.first;
  for (final rank in ranks) {
    if (points >= rank.required) current = rank;
  }
  return current;
}

/// The next rank up, or null at the top of the path.
Rank? nextRankAfter(int points) {
  for (final rank in ranks) {
    if (points < rank.required) return rank;
  }
  return null;
}

/// Total points available, so the UI can show "x of y".
int get maxAchievementPoints =>
    achievements.fold<int>(0, (sum, a) => sum + a.points);
