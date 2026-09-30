import 'package:flutter/foundation.dart';

bool isMobile() {
  return !kIsWeb;
}

/// True when this build was made to record store footage.
///
/// Compile-time, not a setting: a runtime toggle can leak into a release and a
/// reviewer can find it. Nothing reads this except [adsEnabled].
const bool kStoreCapture = bool.fromEnvironment('STORE_CAPTURE');

/// Whether ad slots should load at all.
///
/// Every banner and the interstitial service ask this rather than [isMobile],
/// so one define silences all of them for a capture session. Store footage
/// showing a banner dates instantly and gives away nothing about the game.
///
///   flutter build apk --release --dart-define=STORE_CAPTURE=true
bool adsEnabled() => isMobile() && !kStoreCapture;
