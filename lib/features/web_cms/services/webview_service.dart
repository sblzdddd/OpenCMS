import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';

final logger = Logger('WebviewService');

class WebviewService {
  static WebViewEnvironment? webViewEnvironment;
  static Future<void> initWebview() async {
    if (kIsWeb) return;

    if (Platform.isWindows) {
      final availableVersion = await WebViewEnvironment.getAvailableVersion();
      assert(
        availableVersion != null,
        'Failed to find a WebView2 Runtime or Edge.',
      );

      try {
        webViewEnvironment = await WebViewEnvironment.create();
      } catch (e) {
        logger.warning('Failed to create WebViewEnvironment: $e');
      }
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    }
    PlatformInAppWebViewController.debugLoggingSettings.enabled = false;
  }
}
