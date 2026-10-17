import 'dart:async';
import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// GDPR consent for AdMob, via Google's User Messaging Platform.
///
/// Required wherever AdMob serves in the EEA and the UK: without a consent
/// form the SDK may only serve non-personalised ads, and shipping without one
/// is a policy violation. Yandex regions never reach this code.
///
/// Everything here fails open. A player who cannot reach the consent service
/// still gets a working game; they simply see non-personalised ads, which is
/// the safe default rather than the lucrative one.
class AdConsent {
  /// How long to wait for the consent round trip before starting without it.
  /// A slow consent service must not hold the first screen hostage.
  static const _timeout = Duration(seconds: 8);

  /// Asks for consent if the player's region requires it, then returns
  /// whether ad requests may proceed.
  static Future<bool> gather() async {
    try {
      await _requestUpdate().timeout(_timeout);
      return await ConsentInformation.instance.canRequestAds();
    } on TimeoutException {
      log('consent timed out; starting without it', name: 'ads');
      return true;
    } catch (error) {
      log('consent unavailable: $error', name: 'ads');
      // Fail open: the SDK falls back to non-personalised ads by itself.
      return true;
    }
  }

  static Future<void> _requestUpdate() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            await _loadAndShow();
          }
        } catch (error) {
          log('consent form failed: $error', name: 'ads');
        }
        if (!done.isCompleted) done.complete();
      },
      (error) {
        // Outside the EEA this is also the path for "nothing required".
        log('consent info failed: ${error.message}', name: 'ads');
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  static Future<void> _loadAndShow() {
    final shown = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((error) {
      if (error != null) {
        log('consent form error: ${error.message}', name: 'ads');
      }
      if (!shown.isCompleted) shown.complete();
    });
    return shown.future;
  }
}
