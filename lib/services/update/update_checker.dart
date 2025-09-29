import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateChecker {
  static const String _githubLatestReleaseApi = 'https://api.github.com/repos/sblzdddd/OpenCMS/releases/latest';
  static const String _githubReleasesPage = 'https://github.com/sblzdddd/OpenCMS/releases';

  static bool _alreadyChecked = false;

  static Future<void> checkForUpdates(BuildContext context) async {
    if (_alreadyChecked) return;
    _alreadyChecked = true;

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersionRaw = packageInfo.version; // e.g., 0.9.0

      final Dio dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
        headers: {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
          'User-Agent': 'OpenCMS-Update-Checker'
        },
      ));

      final Response response = await dio.get(_githubLatestReleaseApi);
      if (response.statusCode == 200 && response.data is Map) {
        final Map data = response.data as Map;
        final String tagName = (data['tag_name'] ?? '').toString(); // e.g., v1.0.0
        if (tagName.isEmpty) return;

        final String latestVersionRaw = _normalizeVersion(tagName);
        final String currentVersion = _normalizeVersion(currentVersionRaw);

        if (_isNewer(latestVersionRaw, currentVersion)) {
          if (!context.mounted) return;
          _showUpdateDialog(context, latestVersionRaw);
        }
      }
    } catch (_) {
      // Silently ignore errors; do not block startup
    }
  }

  static String _normalizeVersion(String input) {
    String v = input.trim();
    if (v.startsWith('v') || v.startsWith('V')) {
      v = v.substring(1);
    }
    // Remove build metadata if present (e.g., +1)
    final int plusIndex = v.indexOf('+');
    if (plusIndex != -1) {
      v = v.substring(0, plusIndex);
    }
    return v;
  }

  static bool _isNewer(String a, String b) {
    // Compare semantic versions a > b ?
    List<int> pa = _parseSemver(a);
    List<int> pb = _parseSemver(b);
    for (int i = 0; i < 3; i++) {
      if (pa[i] != pb[i]) return pa[i] > pb[i];
    }
    return false;
  }

  static List<int> _parseSemver(String v) {
    final parts = v.split('.');
    int major = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    int minor = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    int patch = 0;
    if (parts.length > 2) {
      final patchPart = parts[2].split('-').first; // drop pre-release
      patch = int.tryParse(patchPart) ?? 0;
    }
    return [major, minor, patch];
  }

  static Future<void> _showUpdateDialog(BuildContext context, String latestVersion) async {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Update available'),
          content: Text('A new version ($latestVersion) is available. Would you like to view the releases page?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final Uri uri = Uri.parse(_githubReleasesPage);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Open Releases'),
            ),
          ],
        );
      },
    );
  }
}
