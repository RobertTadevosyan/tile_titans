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

    test('other modes nest under the player, not in a top-level bucket', () {
      // The security rules grant write access only to leaderboard/<own uid>.
      // A top-level bucket such as leaderboard/timeAttack/<uid> is rejected
      // with permission denied, and the failure is swallowed so that a broken
      // leaderboard write never interrupts play — so it failed invisibly and
      // the mode boards stayed empty.
      expect(leaderboardPathFor(ModeKeys.timeAttack, 'abc123'),
          'leaderboard/abc123/modes/timeAttack');
      expect(leaderboardPathFor(ModeKeys.hardcore, 'abc123'),
          'leaderboard/abc123/modes/hardcore');
    });

    test('every write stays inside the branch the player owns', () {
      for (final mode in ModeKeys.freePlay) {
        expect(leaderboardPathFor(mode, 'abc123'), startsWith('leaderboard/abc123'));
      }
    });
  });

  group('reading a board', () {
    final node = {
      'high_score': 153532,
      'platform': 'Android',
      'device': 'SM-S928B',
      'os': 'Android 16',
      'modes': {
        'timeAttack': {
          'high_score': 624,
          'platform': 'Android',
          'device': 'Mi A2',
          'os': 'Android 12',
        },
      },
    };

    test('Classic reads the legacy top-level fields', () {
      final row = leaderboardRowFor(ModeKeys.classic, node);
      expect(row, isNotNull);
      expect(LeaderboardEntry.fromMap('u', row!).score, 153532);
    });

    test('a mode reads its nested row', () {
      final row = leaderboardRowFor(ModeKeys.timeAttack, node);
      expect(row, isNotNull);
      final entry = LeaderboardEntry.fromMap('u', row!);
      expect(entry.score, 624);
      // Same four fields on every board, so one model serves them all.
      expect(entry.device, 'Mi A2');
      expect(entry.platform, 'Android');
    });

    test('a player absent from a board is left off it', () {
      expect(leaderboardRowFor(ModeKeys.hardcore, node), isNull);
    });

    test('a legacy-only player still appears on Classic', () {
      final legacy = {'high_score': 900, 'platform': 'Web', 'device': 'Mac'};
      expect(leaderboardRowFor(ModeKeys.classic, legacy), isNotNull);
      expect(leaderboardRowFor(ModeKeys.timeAttack, legacy), isNull);
    });
  });

  group('the global record stays Classic-only', () {
    // The stored global high score is the legacy Classic record, and startup
    // republishes it to the Classic ladder. When any scored mode could write
    // it, a Time Attack run leaked onto the main board one launch later: a
    // 24-point 90-second run appeared beside six-figure Classic scores.
    bool writesGlobal(String mode, int score, int globalHigh) =>
        mode == ModeKeys.classic && score > globalHigh;

    test('a Classic record still updates the global figure', () {
      expect(writesGlobal(ModeKeys.classic, 200000, 153532), isTrue);
    });

    test('Time Attack never touches it', () {
      expect(writesGlobal(ModeKeys.timeAttack, 24, 0), isFalse);
      expect(writesGlobal(ModeKeys.timeAttack, 999999, 153532), isFalse);
    });

    test('Hardcore never touches it', () {
      expect(writesGlobal(ModeKeys.hardcore, 50000, 0), isFalse);
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
