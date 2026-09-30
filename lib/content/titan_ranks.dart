/// The Titan rank ladder.
///
/// Every tile value carries a name and an emblem. The numeral stays primary and
/// fully legible — the emblem is a sigil that rides with it, so the board gains
/// an identity without the player having to memorise an arbitrary symbol order.
///
/// Emblems are drawn as vector paths (see `presentation/widgets/titan_emblem.dart`),
/// not imported artwork: original, themeable, and free at any density.
library;

/// Which sigil a rank uses. Drawn, not an asset.
enum Emblem {
  spark,
  chevron,
  arrow,
  axe,
  shield,
  crossedAxes,
  fang,
  helm,
  crown,
  hammer,
  rune,
  sun,
  bolt,
  spiral,
}

/// How much visual ceremony a tile earns. The brief asks that 256 / 512 / 1024
/// / 2048 / 4096+ feel progressively more significant, so weight is a property
/// of the rank rather than something each widget re-derives.
enum RankTier {
  /// 2–128: a quiet mark behind the numeral.
  common,

  /// 256–1024: a stronger sigil and a warmer surface.
  forged,

  /// 2048+: full ceremony, and a forge-flash the first time it is reached.
  legendary,
}

class TitanRank {
  final int value;
  final String name;
  final Emblem emblem;
  final RankTier tier;

  const TitanRank({
    required this.value,
    required this.name,
    required this.emblem,
    required this.tier,
  });

  bool get isMilestone => tier != RankTier.common;
}

/// The ladder, ascending. Names are deliberately short — they sit under a
/// numeral on a small tile and must survive translation without wrapping.
const List<TitanRank> titanRanks = [
  TitanRank(
    value: 2,
    name: 'Whelp',
    emblem: Emblem.spark,
    tier: RankTier.common,
  ),
  TitanRank(
    value: 4,
    name: 'Thrall',
    emblem: Emblem.chevron,
    tier: RankTier.common,
  ),
  TitanRank(
    value: 8,
    name: 'Scout',
    emblem: Emblem.arrow,
    tier: RankTier.common,
  ),
  TitanRank(
    value: 16,
    name: 'Raider',
    emblem: Emblem.axe,
    tier: RankTier.common,
  ),
  TitanRank(
    value: 32,
    name: 'Shieldman',
    emblem: Emblem.shield,
    tier: RankTier.common,
  ),
  TitanRank(
    value: 64,
    name: 'Warrior',
    emblem: Emblem.crossedAxes,
    tier: RankTier.common,
  ),
  TitanRank(
    value: 128,
    name: 'Berserker',
    emblem: Emblem.fang,
    tier: RankTier.common,
  ),
  TitanRank(
    value: 256,
    name: 'Huscarl',
    emblem: Emblem.helm,
    tier: RankTier.forged,
  ),
  TitanRank(
    value: 512,
    name: 'Jarl',
    emblem: Emblem.crown,
    tier: RankTier.forged,
  ),
  TitanRank(
    value: 1024,
    name: 'Warlord',
    emblem: Emblem.hammer,
    tier: RankTier.forged,
  ),
  TitanRank(
    value: 2048,
    name: 'Titan',
    emblem: Emblem.rune,
    tier: RankTier.legendary,
  ),
  TitanRank(
    value: 4096,
    name: 'World-Breaker',
    emblem: Emblem.sun,
    tier: RankTier.legendary,
  ),
  TitanRank(
    value: 8192,
    name: 'Godslayer',
    emblem: Emblem.bolt,
    tier: RankTier.legendary,
  ),
  TitanRank(
    value: 16384,
    name: 'Eternal',
    emblem: Emblem.spiral,
    tier: RankTier.legendary,
  ),
];

/// The rank for a tile value.
///
/// Values above the top of the ladder keep the highest rank rather than falling
/// back to nothing — a 65536 tile is still Eternal.
TitanRank rankForValue(int value) {
  TitanRank? match;
  for (final rank in titanRanks) {
    if (rank.value <= value) match = rank;
  }
  return match ?? titanRanks.first;
}

/// Convenience for the tile widget.
Emblem emblemForValue(int value) => rankForValue(value).emblem;

/// True when reaching this value deserves a celebration.
bool isMilestoneValue(int value) =>
    titanRanks.any((r) => r.value == value && r.isMilestone);
