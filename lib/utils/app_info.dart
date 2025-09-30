import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoUtil {
  static Future<String> getVersionText() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return ' v${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (_) {
      return '';
    }
  }

  static Future<String> getDeviceText() async {
    try {
      if (kIsWeb) {
        final String platformName = defaultTargetPlatform.name;
        return 'Web • $platformName';
      }
      final String os = Platform.operatingSystem; // e.g., windows, macos, linux, android, ios
      final String osVersion = Platform.operatingSystemVersion;
      String arch = '';
      try {
        final String vmVersion = Platform.version;
        if (vmVersion.contains('arm64')) {
          arch = 'arm64';
        } else if (vmVersion.contains('x64')) {
          arch = 'x64';
        }
      } catch (_) {}
      final String osName = os.isNotEmpty ? '${os[0].toUpperCase()}${os.substring(1)}' : 'Unknown';
      return arch.isNotEmpty ? '$osName $arch • $osVersion' : '$osName • $osVersion';
    } catch (_) {
      return '';
    }
  }

  static Future<String> getCombinedFooterText() async {
    final String version = 'OpenCMS${await getVersionText()}';
    final String device = await getDeviceText();
    final List<String> parts = [];
    if (version.isNotEmpty) parts.add(version);
    if (device.isNotEmpty) parts.add(device);
    return parts.join(' • ');
  }
}
