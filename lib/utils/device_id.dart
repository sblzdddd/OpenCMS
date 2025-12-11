import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';

Future<String?> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  try {
    if (kIsWeb) {
      // Web has no stable device id; return null
      return null;
    }
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return android.id;
    }
    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return ios.identifierForVendor;
    }
    if (Platform.isWindows) {
      final windows = await deviceInfo.windowsInfo;
      return windows.deviceId.replaceAll(RegExp(r'[\{\}]'), '');
    }
    if (Platform.isMacOS) {
      final mac = await deviceInfo.macOsInfo;
      return mac.systemGUID;
    }
    if (Platform.isLinux) {
      final linux = await deviceInfo.linuxInfo;
      return linux.machineId;
    }
    return null;
  } catch (_) {
    return null;
  }
}
