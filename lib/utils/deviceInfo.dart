import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
export 'device_info_mobile.dart' if (dart.library.html) 'device_info_web.dart';

String getPlatform() {
  if (kIsWeb) return 'Web';
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Unknown';
}

Future<Map<String, dynamic>> getDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();

  if (kIsWeb) {
    // final userAgent = getWebUserAgent();
    return getDeviceInfo();
  } else if (Platform.isAndroid) {
    final info = await deviceInfo.androidInfo;
    return {'device': info.model, 'os': 'Android ${info.version.release}'};
  } else if (Platform.isIOS) {
    final info = await deviceInfo.iosInfo;
    return {'device': info.utsname.machine, 'os': 'iOS ${info.systemVersion}'};
  } else {
    return {'device': 'Unknown', 'os': getPlatform()};
  }
}
