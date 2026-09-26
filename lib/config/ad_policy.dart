import 'package:shared_preferences/shared_preferences.dart';

/// Decides when an interstitial may be shown.
///
/// Kept apart from the ad SDK so the rules are plain, testable logic rather
/// than conditions scattered through screens — which is how the original build
/// ended up firing an interstitial repeatedly for a single game over.
///
/// The rules, in order of precedence:
///  1. The first few sessions are ad-free. A new player's first impression is
///     worth more than the impressions it costs.
///  2. Interstitials never appear more often than the cooldown, whatever else
///     qualifies. Two in quick succession is the thing players actually resent.
///  3. A win only counts toward an ad every Nth time, so finishing a trial is
///     usually followed by the result screen and nothing else.
class AdPolicy {
  static const _sessionsKey = 'tt_ad_sessions';
  static const _winsKey = 'tt_ad_wins_pending';

  /// Sessions played before the first interstitial is allowed.
  static const int adFreeSessions = 2;

  /// Wins between interstitials on the win path.
  static const int winsPerInterstitial = 3;

  /// Minimum gap between any two interstitials.
  static const Duration cooldown = Duration(minutes: 3);

  int _sessions = 0;
  int _winsPending = 0;
  DateTime? _lastShown;

  /// Injectable clock so cooldown behaviour can be tested without waiting.
  final DateTime Function() _now;

  AdPolicy({DateTime Function()? now}) : _now = now ?? DateTime.now;

  int get sessions => _sessions;
  int get winsPending => _winsPending;

  /// True while the player is still inside their ad-free grace period.
  bool get inGracePeriod => _sessions <= adFreeSessions;

  /// Loads counters and counts this launch as a session.
  Future<void> startSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessions = (prefs.getInt(_sessionsKey) ?? 0) + 1;
    _winsPending = prefs.getInt(_winsKey) ?? 0;
    await prefs.setInt(_sessionsKey, _sessions);
  }

  bool get _cooledDown {
    final last = _lastShown;
    if (last == null) return true;
    return _now().difference(last) >= cooldown;
  }

  /// Whether an interstitial may be shown now that a run has ended in a loss.
  bool shouldShowAfterGameOver() {
    if (inGracePeriod) return false;
    return _cooledDown;
  }

  /// Counts a win and reports whether it earns an interstitial.
  ///
  /// The counter is advanced even during the grace period or cooldown, so the
  /// cadence stays honest — a win is not silently uncounted just because an ad
  /// could not be shown for it.
  Future<bool> registerWin() async {
    _winsPending++;
    await _persistWins();

    if (_winsPending < winsPerInterstitial) return false;
    if (inGracePeriod) return false;
    if (!_cooledDown) return false;

    _winsPending = 0;
    await _persistWins();
    return true;
  }

  /// Records that an interstitial was actually shown, starting the cooldown.
  void markShown() => _lastShown = _now();

  Future<void> _persistWins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_winsKey, _winsPending);
  }

  /// Test seam.
  void debugSetLastShown(DateTime? when) => _lastShown = when;
}
