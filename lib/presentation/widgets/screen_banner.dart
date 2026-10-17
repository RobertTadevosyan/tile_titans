import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/config/ad_region.dart';
import 'package:flutter_2048/config/ad_router.dart';
import 'package:flutter_2048/config/ads_config.dart';
import 'package:flutter_2048/utils/helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as admob;
import 'package:yandex_mobileads/mobile_ads.dart' as yandex;

/// The banner every screen shows, on whichever network serves this region.
///
/// Banner setup was copy-pasted across four screens, each with its own subtly
/// different lifecycle — which is how one of them ended up requesting an ad it
/// never displayed, and another deadlocked by calling loadAd() before its
/// widget was mounted. This is the single correct version.
///
/// Rules encoded here:
///  * Occupy zero height until an ad exists, so a screen never shows a grey gap
///    where an unfilled banner would be.
///  * Ask [adsEnabled], not `isMobile`, so a STORE_CAPTURE build is silent.
///  * Re-request when the width changes by more than [_reloadThreshold]. A
///    banner is sized at request time, so the ad fetched in portrait is the
///    wrong width in landscape — it either letterboxes or overflows.
///
/// Intended as a [Scaffold.bottomNavigationBar]: the Scaffold then insets the
/// body by the ad's height, which is what guarantees the ad never covers
/// content on any screen, orientation or screen size.
class ScreenBanner extends StatelessWidget {
  /// Clear space above the ad. Gameplay screens pass a gap so a swipe that
  /// overshoots the board cannot land on the banner.
  final double gap;

  const ScreenBanner({super.key, this.gap = 0});

  @override
  Widget build(BuildContext context) {
    if (!adsEnabled()) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: AdRouter.resolved,
      builder: (context, resolved, _) {
        if (!resolved) return const SizedBox.shrink();
        return switch (AdRouter.network) {
          AdNetwork.yandex => _YandexBanner(gap: gap),
          AdNetwork.admob => _AdMobBanner(gap: gap),
        };
      },
    );
  }
}

/// Wraps a loaded ad in the shared chrome: below the safe area, with the gap.
class _BannerFrame extends StatelessWidget {
  const _BannerFrame({
    required this.height,
    required this.gap,
    required this.child,
  });

  final double height;
  final double gap;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.only(top: gap),
      child: SizedBox(height: height, child: child),
    ),
  );
}

/// Ignore the pixel or two a system-bar change moves the width by; only a real
/// rotation or a fold should cost a new request.
const int _reloadThreshold = 32;

class _YandexBanner extends StatefulWidget {
  const _YandexBanner({required this.gap});

  final double gap;

  @override
  State<_YandexBanner> createState() => _YandexBannerState();
}

class _YandexBannerState extends State<_YandexBanner> {
  static yandex.AdRequest get _request => yandex.AdRequest(
    adUnitId: AdsConfig.bannerId(AdNetwork.yandex),
    targeting: const yandex.AdTargeting(
      contextQuery: 'puzzle, games, mobile apps, games',
    ),
  );

  yandex.BannerAd? _ad;
  bool _attached = false;
  int _height = 0;
  int _loadedWidth = 0;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) return;
    final width = MediaQuery.sizeOf(context).width.toInt();
    if (_ad == null) {
      _load(width);
    } else if ((width - _loadedWidth).abs() >= _reloadThreshold) {
      _reload(width);
    }
  }

  void _reload(int width) {
    final old = _ad;
    setState(() {
      _ad = null;
      _attached = false;
      _height = 0;
    });
    // Destroy once the AdWidget is out of the tree; destroying one that is
    // still mounted leaves the platform view unusable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      old?.destroy();
      if (mounted) _load(width);
    });
  }

  Future<void> _load(int width) async {
    _loading = true;
    try {
      // Size the slot from the calculated size. load() creates the platform
      // view and sends the request once the AdWidget has mounted it.
      final size = yandex.BannerAdSize.sticky(width: width);
      final calculated = await size.getCalculatedBannerAdSize();
      if (!mounted) return;

      final ad = yandex.BannerAd(adSize: size);
      void hide() {
        if (mounted && identical(_ad, ad)) setState(() => _height = 0);
      }

      ad.loadStateStream.listen((state) {
        if (state is yandex.BannerAdLoadStateLoading) {
          // The platform view exists from here on; mounting the AdWidget
          // before this point leaves it empty and the request never goes out.
          if (mounted && identical(_ad, ad)) setState(() => _attached = true);
        } else if (state is yandex.BannerAdLoadStateError) {
          hide();
        }
      });
      unawaited(ad.load(_request).catchError((Object _) => hide()));

      setState(() {
        _ad = ad;
        _height = calculated.height;
        _loadedWidth = width;
      });
    } catch (_) {
      // The SDK is a platform channel; without one the screen simply shows no
      // banner. A banner is the least important thing on any of these screens.
    } finally {
      _loading = false;
    }
  }

  @override
  void dispose() {
    // Without this the native view leaks every time the screen is opened.
    _ad?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || _height == 0) return const SizedBox.shrink();
    // The slot keeps its height from the start, so nothing moves when the
    // creative arrives.
    return _BannerFrame(
      height: _height.toDouble(),
      gap: widget.gap,
      child:
          _attached ? yandex.AdWidget(bannerAd: ad) : const SizedBox.expand(),
    );
  }
}

class _AdMobBanner extends StatefulWidget {
  const _AdMobBanner({required this.gap});

  final double gap;

  @override
  State<_AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<_AdMobBanner> {
  admob.BannerAd? _ad;
  bool _loaded = false;
  int _loadedWidth = 0;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) return;
    final width = MediaQuery.sizeOf(context).width.toInt();
    if (_ad == null || (width - _loadedWidth).abs() >= _reloadThreshold) {
      _load(width);
    }
  }

  Future<void> _load(int width) async {
    _loading = true;
    try {
      // Anchored adaptive is the size Google asks for: it fills the width and
      // picks its own height, so the slot matches the device rather than the
      // legacy 320x50 box.
      final size = await admob
          .AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
      if (size == null || !mounted) return;

      final old = _ad;
      final ad = admob.BannerAd(
        adUnitId:
            kDebugMode
                ? AdsConfig.admobTestBanner
                : AdsConfig.bannerId(AdNetwork.admob),
        size: size,
        request: const admob.AdRequest(),
        listener: admob.BannerAdListener(
          onAdLoaded: (_) {
            if (!mounted) return;
            setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, _) {
            ad.dispose();
            if (!mounted) return;
            setState(() => _loaded = false);
          },
        ),
      );
      setState(() {
        _ad = ad;
        _loaded = false;
        _loadedWidth = width;
      });
      old?.dispose();
      await ad.load();
    } catch (_) {
      // No banner.
    } finally {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return _BannerFrame(
      height: ad.size.height.toDouble(),
      gap: widget.gap,
      child: admob.AdWidget(ad: ad),
    );
  }
}
