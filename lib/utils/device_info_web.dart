// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
//
// Selected only by `if (dart.library.html)` in deviceInfo.dart, so it is
// compiled for web builds and never for the Android or iOS app this ships as.
// Only used on Web
import 'dart:html' as html;

String getWebUserAgent() => html.window.navigator.userAgent;

Future<Map<String, dynamic>> getDeviceInfo() async {
  final userAgent = html.window.navigator.userAgent;
  final platform = html.window.navigator.platform;
  return {'device': platform ?? 'Web', 'os': userAgent, 'platform': platform};
}
