import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

String getPlatform() {
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Unknown';
}

Future<Map<String, dynamic>> getDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final info = await deviceInfo.androidInfo;
    return {'device': info.model, 'os': 'Android ${info.version.release}'};
  } else if (Platform.isIOS) {
    final info = await deviceInfo.iosInfo;
    return {'device': info.utsname.machine, 'os': 'iOS ${info.systemVersion}'};
  } else {
    return {'device': 'Unknown', 'os': getPlatform()};
  }
}
