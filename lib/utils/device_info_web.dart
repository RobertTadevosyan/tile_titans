// Only used on Web
import 'dart:html' as html;

String getWebUserAgent() => html.window.navigator.userAgent;

Future<Map<String, dynamic>> getDeviceInfo() async {
  final userAgent = html.window.navigator.userAgent;
  final platform = html.window.navigator.platform;
  return {'device': platform ?? 'Web', 'os': userAgent};
}
