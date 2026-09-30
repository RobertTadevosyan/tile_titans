import 'package:flutter_2048/config/ad_policy.dart';
import 'package:flutter_2048/config/ads_config.dart';
import 'package:flutter_2048/utils/helper.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

/// Loads and shows interstitials, gated by [AdPolicy].
///
/// One service shared by every screen that can end a run, so the cooldown and
/// the ad-free grace period are genuinely global. When each screen owned its
/// own loader, "one interstitial per game over" was only true per screen.
class InterstitialService {
  InterstitialService(this.policy);

  final AdPolicy policy;

  InterstitialAd? _ad;
  bool _loading = false;

  /// Guards against a second show while one is already on screen.
  bool _showing = false;

  bool get isReady => _ad != null;

  /// Fetches an ad ahead of time so the eventual show is instant.
  Future<void> preload() async {
    if (!adsEnabled() || _ad != null || _loading) return;
    _loading = true;

    try {
      final loader = await InterstitialAdLoader.create(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (_) {
          // Deliberately not retrying here: requesting again from the failure
          // callback is discouraged and can spiral into a request loop.
          _loading = false;
        },
      );
      await loader.loadAd(
        adRequestConfiguration: AdRequestConfiguration(
          adUnitId: AdsConfig.getInterstitialID(),
        ),
      );
    } catch (_) {
      _loading = false;
    }
  }

  /// Shows an ad if the policy allows it after a lost run.
  Future<void> maybeShowAfterGameOver() async {
    if (!policy.shouldShowAfterGameOver()) return;
    await _show();
  }

  /// Counts a win and shows an ad if this is the one that earns it.
  Future<void> maybeShowAfterWin() async {
    final earned = await policy.registerWin();
    if (!earned) return;
    await _show();
  }

  Future<void> _show() async {
    if (!adsEnabled() || _showing) return;
    final ad = _ad;
    if (ad == null) {
      // Nothing loaded: skip rather than block the player behind a fetch.
      await preload();
      return;
    }

    _showing = true;
    policy.markShown();

    ad.setAdEventListener(
      eventListener: InterstitialAdEventListener(
        onAdShown: () {},
        onAdFailedToShow: (_) => _disposeAndReload(),
        onAdClicked: () {},
        onAdDismissed: _disposeAndReload,
        onAdImpression: (_) {},
      ),
    );

    try {
      await ad.show();
      await ad.waitForDismiss();
    } catch (_) {
      _disposeAndReload();
    } finally {
      _showing = false;
    }
  }

  void _disposeAndReload() {
    _ad?.destroy();
    _ad = null;
    _showing = false;
    preload();
  }

  void dispose() {
    _ad?.destroy();
    _ad = null;
  }
}
