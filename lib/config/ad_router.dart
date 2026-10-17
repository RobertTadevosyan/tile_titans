import 'package:flutter/foundation.dart';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_2048/config/ad_region.dart';

/// Which ad network this launch uses.
///
/// Resolved once, before the first screen builds, and never stored: the choice
/// is made again on every cold start, so a player who travels or changes their
/// SIM is routed correctly next time without any migration.
class AdRouter {
  static const MethodChannel _device = MethodChannel('lets.play.game/device');

  /// Defaults to AdMob so a failure to resolve still serves the larger market.
  static AdNetwork _network = AdNetwork.admob;
  static AdNetwork get network => _network;

  /// True once [resolve] has picked this launch's network. Banners built
  /// earlier (the home screen) wait for it instead of taking the default.
  static final ValueNotifier<bool> resolved = ValueNotifier(false);

  /// What the routing saw, for the log line only.
  static String? _timeZone;
  static String? _locale;

  /// QA override, compile-time so it cannot leak into a release as a setting:
  ///
  ///   flutter run --dart-define=AD_NETWORK=admob
  ///
  /// Testing the other region otherwise means re-flashing an emulator's time
  /// zone, which a Play-Store image will not allow without root.
  static const String _forced = String.fromEnvironment('AD_NETWORK');

  static Future<void> resolve() async {
    try {
      _timeZone = await _detectTimeZone();
      _locale = localeCountry();
      _network = switch (_forced) {
        'admob' => AdNetwork.admob,
        'yandex' => AdNetwork.yandex,
        _ => chooseAdNetwork(timeZone: _timeZone, localeCountry: _locale),
      };
      log(
        'Ads: ${_network.name} (zone ${_timeZone ?? '—'}, '
        'region ${_locale ?? '—'})',
        name: 'ads',
      );
    } finally {
      // Even when detection fails, banners go ahead with the default network.
      resolved.value = true;
    }
  }

  /// Test seam: forces the network without touching platform channels.
  static void debugSetNetwork(AdNetwork network) => _network = network;

  static Future<String?> _detectTimeZone() async {
    try {
      return await _device.invokeMethod<String>('timeZone');
    } on MissingPluginException {
      // iOS has no channel yet, and tests have no platform at all.
      return null;
    } on PlatformException catch (error) {
      log('time zone unavailable: $error', name: 'ads');
      return null;
    }
  }
}
