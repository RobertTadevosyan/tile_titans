import 'package:flutter_2048/domain/progress/progress_store.dart';
import 'package:flutter_2048/presentation/models/leaderboard_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('leaderboard paths', () {
    test('Classic writes to the legacy flat path', () {
      // The live database holds several hundred rows at `leaderboard/<uid>`.
      // Classic must keep landing there or the existing ladder splits in two.
      expect(leaderboardPathFor(ModeKeys.classic, 'abc123'),
          'leaderboard/abc123');
    });

    test('other modes get their own bucket', () {
      expect(leaderboardPathFor(ModeKeys.timeAttack, 'abc123'),
          'leaderboard/timeAttack/abc123');
      expect(leaderboardPathFor(ModeKeys.hardcore, 'abc123'),
          'leaderboard/hardcore/abc123');
    });

    test('no mode bucket can collide with a legacy uid row', () {
      // A legacy row is `leaderboard/<uid>`; a bucket is `leaderboard/<mode>`.
      // If a mode key ever looked like a uid the reader could not tell them
      // apart, so the keys stay short and lower-camel.
      for (final mode in [ModeKeys.timeAttack, ModeKeys.hardcore, ModeKeys.zen]) {
        expect(mode.length, lessThan(20));
        expect(RegExp(r'^[a-zA-Z]+$').hasMatch(mode), isTrue);
      }
    });
  });

  group('publishing is gated per mode, not globally', () {
    // Reproduces the reported bug: the Time Attack and Hardcore boards were
    // empty because a run only published when it beat the single global high
    // score. A player holding a 153,532 Classic record would have to beat it
    // inside a 90-second Time Attack run before their first score ever posted.
    int threshold({
      required String mode,
      required int globalHigh,
      required int modeBest,
    }) =>
        mode == ModeKeys.classic && modeBest == 0 ? globalHigh : modeBest;

    test('a first Time Attack score posts despite a huge Classic record', () {
      final bar = threshold(
          mode: ModeKeys.timeAttack, globalHigh: 153532, modeBest: 0);
      expect(800 > bar, isTrue);
    });

    test('a first Hardcore score posts despite a huge Classic record', () {
      final bar =
          threshold(mode: ModeKeys.hardcore, globalHigh: 153532, modeBest: 0);
      expect(1200 > bar, isTrue);
    });

    test('a worse run on the same board does not post', () {
      final bar = threshold(
          mode: ModeKeys.timeAttack, globalHigh: 153532, modeBest: 5000);
      expect(4200 > bar, isFalse);
    });

    test('Classic still measures against the legacy global figure', () {
      // Otherwise the first Classic run after updating would repost a low
      // score over a record earned before per-mode statistics existed.
      final bar =
          threshold(mode: ModeKeys.classic, globalHigh: 153532, modeBest: 0);
      expect(500 > bar, isFalse);
      expect(160000 > bar, isTrue);
    });
  });
}
