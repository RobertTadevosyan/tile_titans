import 'package:flutter/material.dart';
import 'package:flutter_2048/utils/helper.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

/// A sticky banner sized to the screen.
///
/// Banner setup was copy-pasted across four screens, each with its own subtly
/// different lifecycle — which is how one of them ended up requesting an ad it
/// never displayed, and another deadlocked by calling loadAd() before its
/// widget was mounted. This is the single correct version.
///
/// Two rules encoded here:
///  * Never call `loadAd()` before the [AdWidget] is in the tree. This SDK
///    registers a banner's platform channel on mount, so loading first throws
///    MissingPluginException.
///  * Occupy zero height until an ad exists, so a screen never shows a grey gap
///    where an unfilled banner would be.
class ScreenBanner extends StatefulWidget {
  final String adUnitId;

  /// Reported back so the host can inset its content and keep clear space
  /// between the ad and anything tappable.
  final ValueChanged<int>? onHeight;

  const ScreenBanner({super.key, required this.adUnitId, this.onHeight});

  @override
  State<ScreenBanner> createState() => _ScreenBannerState();
}

class _ScreenBannerState extends State<ScreenBanner> {
  static const _request = AdRequest(
    contextQuery: 'puzzle, games, mobile apps, games',
  );

  BannerAd? _ad;
  int _height = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ad == null && isMobile()) _load();
  }

  Future<void> _load() async {
    final width = MediaQuery.sizeOf(context).width.toInt();
    final size = BannerAdSize.sticky(width: width);
    final calculated = await size.getCalculatedBannerAdSize();
    if (!mounted) return;

    final ad = BannerAd(
      adUnitId: widget.adUnitId,
      adSize: size,
      adRequest: _request,
      onAdLoaded: () {},
      onAdFailedToLoad: (_) {
        if (!mounted) return;
        setState(() => _height = 0);
        widget.onHeight?.call(0);
      },
      onAdClicked: () {},
      onLeftApplication: () {},
      onReturnedToApplication: () {},
      onImpression: (_) {},
    );

    setState(() {
      _ad = ad;
      _height = calculated.height;
    });
    widget.onHeight?.call(calculated.height);
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

    return SafeArea(
      top: false,
      child: SizedBox(
        height: _height.toDouble(),
        child: AdWidget(bannerAd: ad),
      ),
    );
  }
}
