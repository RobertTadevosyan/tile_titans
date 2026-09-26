import 'package:flutter_2048/content/titan_ranks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('titan rank ladder', () {
    test('covers the whole playable tile range in ascending order', () {
      expect(titanRanks.first.value, 2);
      for (var i = 1; i < titanRanks.length; i++) {
        expect(titanRanks[i].value, titanRanks[i - 1].value * 2,
            reason: 'the ladder must not skip a doubling');
      }
    });

    test('every rank has a distinct emblem and name', () {
      final emblems = titanRanks.map((r) => r.emblem).toList();
      final names = titanRanks.map((r) => r.name).toList();
      expect(emblems.toSet().length, emblems.length);
      expect(names.toSet().length, names.length);
    });

    test('names stay short enough to sit under a numeral', () {
      for (final rank in titanRanks) {
        expect(rank.name.length, lessThanOrEqualTo(14),
            reason: '${rank.name} will not fit on a tile once translated');
      }
    });

    test('maps values to the right rank', () {
      expect(rankForValue(2).name, 'Whelp');
      expect(rankForValue(128).name, 'Berserker');
      expect(rankForValue(2048).name, 'Titan');
    });

    test('values above the ladder keep the highest rank', () {
      // A 65536 tile is still Eternal, not unranked.
      expect(rankForValue(65536).name, 'Eternal');
      expect(rankForValue(1 << 30).emblem, Emblem.spiral);
    });

    test('a value below the ladder falls back to the first rank', () {
      expect(rankForValue(0).name, 'Whelp');
      expect(rankForValue(1).name, 'Whelp');
    });

    test('tiers escalate and never regress as values climb', () {
      var seen = RankTier.common;
      for (final rank in titanRanks) {
        expect(rank.tier.index, greaterThanOrEqualTo(seen.index),
            reason: '${rank.name} drops back down a tier');
        seen = rank.tier;
      }
    });

    test('the milestones called out in the brief are all significant', () {
      for (final value in [256, 512, 1024, 2048, 4096]) {
        expect(isMilestoneValue(value), isTrue,
            reason: '$value should feel like an achievement');
      }
      // Early tiles must stay quiet so the board does not shout.
      for (final value in [2, 4, 8, 16, 32, 64, 128]) {
        expect(isMilestoneValue(value), isFalse);
      }
    });

    test('legendary tier starts at 2048', () {
      expect(rankForValue(1024).tier, RankTier.forged);
      expect(rankForValue(2048).tier, RankTier.legendary);
    });
  });
}
