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
  });
}
