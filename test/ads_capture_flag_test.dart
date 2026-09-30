import 'package:flutter_2048/utils/helper.dart';
import 'package:flutter_test/flutter_test.dart';

/// The capture flag must be compile-time and off by default.
///
/// A runtime toggle that silences ads can leak into a release build and be
/// found by a reviewer; a define cannot. This asserts the shipping default so
/// a capture build can never become the shipping one by accident.
void main() {
  test('store capture is off unless defined at build time', () {
    expect(
      kStoreCapture,
      isFalse,
      reason: 'a normal build must never be a capture build',
    );
  });

  test('ads are enabled in a normal build', () {
    // On the test VM isMobile() is true (not web), so this tracks the flag.
    expect(adsEnabled(), isTrue);
  });
}
