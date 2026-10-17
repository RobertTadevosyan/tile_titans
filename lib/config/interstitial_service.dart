import 'package:flutter/foundation.dart';
import 'package:flutter_2048/config/ad_policy.dart';
import 'package:flutter_2048/config/ad_region.dart';
import 'package:flutter_2048/config/ad_router.dart';
import 'package:flutter_2048/config/ads_config.dart';
import 'package:flutter_2048/utils/helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as admob;
import 'package:yandex_mobileads/mobile_ads.dart' as yandex;

/// Loads and shows interstitials, gated by [AdPolicy].
///
/// One service shared by every screen that can end a run, so the cooldown and
/// the ad-free grace period are genuinely global. When each screen owned its
/// own loader, "one interstitial per game over" was only true per screen.
///
/// Both networks are handled here rather than behind an interface: there are
/// exactly two, each with a different enough lifecycle that an abstraction
/// would hide more than it saved.
class InterstitialService {
  InterstitialService(this.policy);

  final AdPolicy policy;

  yandex.InterstitialAd? _yandexAd;
  admob.InterstitialAd? _admobAd;
  bool _loading = false;

  /// Guards against a second show while one is already on screen.
  bool _showing = false;

  bool get isReady => _yandexAd != null || _admobAd != null;

  /// Fetches an ad ahead of time so the eventual show is instant.
  Future<void> preload() async {
    if (!adsEnabled() || isReady || _loading) return;
    _loading = true;
    try {
      switch (AdRouter.network) {
        case AdNetwork.yandex:
          await _preloadYandex();
        case AdNetwork.admob:
          await _preloadAdMob();
      }
    } catch (_) {
      _loading = false;
    }
  }

  Future<void> _preloadYandex() async {
    final loader = await yandex.InterstitialAdLoader.create(
      onAdLoaded: (ad) {
        _yandexAd = ad;
        _loading = false;
      },
      onAdFailedToLoad: (_) {
        // Deliberately not retrying here: requesting again from the failure
        // callback is discouraged and can spiral into a request loop.
        _loading = false;
      },
    );
    await loader.loadAd(
      adRequestConfiguration: yandex.AdRequestConfiguration(
        adUnitId: AdsConfig.interstitialId(AdNetwork.yandex),
      ),
    );
  }

  Future<void> _preloadAdMob() async {
    await admob.InterstitialAd.load(
      adUnitId:
          kDebugMode
              ? AdsConfig.admobTestInterstitial
              : AdsConfig.interstitialId(AdNetwork.admob),
      request: const admob.AdRequest(),
      adLoadCallback: admob.InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _admobAd = ad;
          _loading = false;
        },
        onAdFailedToLoad: (_) => _loading = false,
      ),
    );
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
    if (!isReady) {
      // Nothing loaded: skip rather than block the player behind a fetch.
      await preload();
      return;
    }

    _showing = true;
    policy.markShown();
    try {
      if (_yandexAd != null) {
        await _showYandex(_yandexAd!);
      } else if (_admobAd != null) {
        await _showAdMob(_admobAd!);
      }
    } catch (_) {
      _disposeAndReload();
    } finally {
      _showing = false;
    }
  }

  Future<void> _showYandex(yandex.InterstitialAd ad) async {
    ad.setAdEventListener(
      eventListener: yandex.InterstitialAdEventListener(
        onAdShown: () {},
        onAdFailedToShow: (_) => _disposeAndReload(),
        onAdClicked: () {},
        onAdDismissed: _disposeAndReload,
        onAdImpression: (_) {},
      ),
    );
    await ad.show();
    await ad.waitForDismiss();
  }

  Future<void> _showAdMob(admob.InterstitialAd ad) async {
    ad.fullScreenContentCallback = admob.FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _admobAd = null;
        _showing = false;
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _admobAd = null;
        _showing = false;
        preload();
      },
    );
    await ad.show();
  }

  void _disposeAndReload() {
    _dispose();
    _showing = false;
    preload();
  }

  void _dispose() {
    _yandexAd?.destroy();
    _yandexAd = null;
    _admobAd?.dispose();
    _admobAd = null;
  }

  void dispose() => _dispose();
}
