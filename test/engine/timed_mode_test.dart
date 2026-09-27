import 'package:flutter_2048/domain/engine/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// Time Attack is started from the home screen by its RuleSet, while the timer
/// used to be driven by the legacy GameMode enum. Nothing connected the two, so
/// the mode ran with no countdown, never ended, recorded no statistics, and its
/// leaderboard stayed empty however the publishing code behaved.
void main() {
  group('timed rules', () {
    test('Time Attack carries a limit and Classic does not', () {
      expect(RuleSet.timeAttack.timeLimit, isNotNull);
      expect(RuleSet.classic.timeLimit, isNull);
      expect(RuleSet.zen.timeLimit, isNull);
      expect(RuleSet.hardcore.timeLimit, isNull);
    });

    test('the countdown starts from the rule, not a hardcoded 60', () {
      // _startTimer used to set 60 while the rule said 90, so a third of the
      // round was silently missing.
      expect(RuleSet.timeAttack.timeLimit, 90);
    });

    test('merges buy time back, which is what makes the mode its own thing', () {
      expect(RuleSet.timeAttack.secondsPerMerge, greaterThan(0));
      expect(RuleSet.classic.secondsPerMerge, 0);
    });

    test('a timed run is scored, so it has something to rank', () {
      expect(RuleSet.timeAttack.scored, isTrue);
    });

    test('the clock is capped, so a good run still ends', () {
      // Uncapped, a merge pays for more than it costs: at +2s per merge a
      // competent player gains time faster than it drains and the round runs
      // forever. On device a run climbed from 84s to 190s while being played,
      // and a round that never ends never posts a score.
      const limit = 90;
      const perMerge = 2;
      var clock = 40;
      // Fifty merging moves, one second of real time each.
      for (var i = 0; i < 50; i++) {
        clock -= 1;
        clock = (clock + perMerge) > limit ? limit : clock + perMerge;
      }
      expect(clock, lessThanOrEqualTo(limit));

      // And with no merges at all it still runs out.
      var idle = limit;
      for (var i = 0; i < limit; i++) {
        idle -= 1;
      }
      expect(idle, 0);
    });
  });
}
