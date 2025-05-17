import 'device_info_stub.dart' // Default fallback (optional)
    if (dart.library.html) 'device_info_web.dart'
    if (dart.library.io) 'device_info_mobile.dart';

Future<Map<String, dynamic>> getDeviceInfoSafe() async {
  return getDeviceInfo();
}
