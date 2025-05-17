// Placeholder for mobile (can return something else or empty)
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

String getWebUserAgent() => 'not available';

Future<Map<String, dynamic>> getDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final info = await deviceInfo.androidInfo;
    return {'device': info.model, 'os': 'Android ${info.version.release}', 'platform': getPlatform()};
  } else if (Platform.isIOS) {
    final info = await deviceInfo.iosInfo;
    return {'device': info.utsname.machine, 'os': 'iOS ${info.systemVersion}', 'platform': getPlatform()};
  } else {
    return {'device': 'Unknown', 'os': getPlatform()};
  }
}

String getPlatform() {
  if (kIsWasm) return 'Web';
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Unknown';
}
