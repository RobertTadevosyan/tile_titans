import 'package:flutter_2048/config/ad_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Runs enough sessions to clear the ad-free grace period.
  Future<AdPolicy> pastGracePeriod({DateTime Function()? now}) async {
    final policy = AdPolicy(now: now);
    for (var i = 0; i <= AdPolicy.adFreeSessions; i++) {
      await policy.startSession();
    }
    return policy;
  }

  group('grace period', () {
    test('no interstitial in the first sessions', () async {
      final policy = AdPolicy();
      await policy.startSession();

      expect(policy.inGracePeriod, isTrue);
      expect(policy.shouldShowAfterGameOver(), isFalse);
    });

    test('ends after the configured number of sessions', () async {
      final policy = await pastGracePeriod();
      expect(policy.inGracePeriod, isFalse);
      expect(policy.shouldShowAfterGameOver(), isTrue);
    });

    test('session count survives a relaunch', () async {
      final first = AdPolicy();
      await first.startSession();
      await first.startSession();

      final second = AdPolicy();
      await second.startSession();
      expect(second.sessions, 3);
    });
  });

  group('wins', () {
    test('an interstitial arrives on the third win, not before', () async {
      final policy = await pastGracePeriod();

      expect(await policy.registerWin(), isFalse);
      expect(await policy.registerWin(), isFalse);
      expect(
        await policy.registerWin(),
        isTrue,
        reason: 'third win should earn an interstitial',
      );
    });

    test('the counter resets after firing', () async {
      final policy = await pastGracePeriod();
      for (var i = 0; i < 3; i++) {
        await policy.registerWin();
      }
      policy.markShown();
      policy.debugSetLastShown(null); // ignore cooldown for this assertion

      expect(await policy.registerWin(), isFalse);
      expect(await policy.registerWin(), isFalse);
      expect(await policy.registerWin(), isTrue);
    });

    test('wins still count during the grace period', () async {
      // A win must not be silently uncounted just because no ad could show,
      // otherwise the cadence drifts for every new player.
      final policy = AdPolicy();
      await policy.startSession();

      expect(await policy.registerWin(), isFalse);
      expect(await policy.registerWin(), isFalse);
      expect(
        await policy.registerWin(),
        isFalse,
        reason: 'grace period suppresses the ad',
      );
      expect(policy.winsPending, 3, reason: 'but the wins are remembered');
    });

    test('pending wins survive a relaunch', () async {
      final first = await pastGracePeriod();
      await first.registerWin();
      await first.registerWin();

      final second = AdPolicy();
      await second.startSession();
      expect(second.winsPending, 2);
    });
  });

  group('cooldown', () {
    test('a second interstitial is refused inside the cooldown', () async {
      var now = DateTime(2026, 9, 26, 12, 0);
      final policy = await pastGracePeriod(now: () => now);

      expect(policy.shouldShowAfterGameOver(), isTrue);
      policy.markShown();

      now = now.add(const Duration(minutes: 1));
      expect(
        policy.shouldShowAfterGameOver(),
        isFalse,
        reason: 'two ads a minute apart is the thing players resent',
      );
    });

    test('allowed again once the cooldown has passed', () async {
      var now = DateTime(2026, 9, 26, 12, 0);
      final policy = await pastGracePeriod(now: () => now);
      policy.markShown();

      now = now.add(AdPolicy.cooldown + const Duration(seconds: 1));
      expect(policy.shouldShowAfterGameOver(), isTrue);
    });

    test('a qualifying win is still suppressed inside the cooldown', () async {
      var now = DateTime(2026, 9, 26, 12, 0);
      final policy = await pastGracePeriod(now: () => now);
      policy.markShown();

      await policy.registerWin();
      await policy.registerWin();
      expect(await policy.registerWin(), isFalse);

      // The win is kept pending so it fires once the cooldown clears.
      expect(policy.winsPending, 3);
      now = now.add(AdPolicy.cooldown + const Duration(seconds: 1));
      expect(await policy.registerWin(), isTrue);
    });
  });
}
