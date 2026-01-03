import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../../../theme/services/theme_services.dart';
import 'package:opencms/features/web_cms/services/webview_service.dart';
import 'captcha_html_content.dart';
import 'captcha_dialog_web.dart'
    if (dart.library.io) 'captcha_dialog_stub.dart'
    as web_helper;
import 'package:logging/logging.dart';
import '../../../services/auto_captcha_service.dart';
import '../../../../shared/views/custom_snackbar/snackbar_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

final logger = Logger('CaptchaDialog');

/// Tencent Captcha implementation
class TencentCaptchaDialog {

  /// Perform captcha verification with popup webview
  static Future<void> verify({
    required BuildContext context,
    required TencentCaptchaDialogConfig config,
    required Function(dynamic) onLoaded,
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFail,
  }) async {
    logger.info('Starting verification...');

    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 200));
    onLoaded({'status': 'loaded', 'bizState': config.bizState});
    if (!context.mounted) {
      logger.severe('Context is not mounted');
      return;
    }

    // Show popup webview
    await _showCaptchaWebView(
      context: context,
      config: config,
      onSuccess: onSuccess,
      onFail: onFail,
    );
  }

  /// Show auto-solve confirmation dialog
  static void _showAutoSolveConfirmation(
    BuildContext context,
    String username,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("Auto-Solve Request"),
            content: Text(
              "Your username ($username) and Device Id might be collected for Captcha auto-verification service (to ensure such service is not abused), based on your agreement to this additional service. Apart from that, We do not collect, store, analyze, or transmit any personal data or usage analytics to our servers or any third parties.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  // Close confirmation dialog
                  Navigator.of(dialogContext).pop();

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (loadingContext) =>
                            const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final service = AutoCaptchaService();
                    final success = await service.sendRequest(username);

                    if (!context.mounted) return;

                    // Close loading indicator
                    Navigator.of(context).pop();

                    if (success) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('auto_captcha_requested', true);

                      if (context.mounted) {
                        SnackbarUtils.showSuccess(
                          context,
                          "Auto-solve request sent successfully",
                        );
                      }
                    } else {
                      SnackbarUtils.showError(
                        context,
                        "Failed to send auto-solve request",
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close loading
                      SnackbarUtils.showError(context, "Error: $e");
                    }
                  }
                },
                child: const Text("Accept"),
              ),
            ],
          ),
    );
  }

  /// Show captcha webview in a popup dialog
  static Future<void> _showCaptchaWebView({
    required BuildContext context,
    required TencentCaptchaDialogConfig config,
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFail,
  }) async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final bool autoSolveRequested =
        prefs.getBool('auto_captcha_requested') ?? false;

    await showDialog(
      context: context,
      barrierDismissible: false, // Disable clicking outside to close
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        // Set up message listener for web platform inside the dialog
        if (kIsWeb) {
          web_helper.WebHelper.setupMessageListener(
            removeListener: () {},
            closeDialog: () => Navigator.of(dialogContext).pop(),
            onSuccess: onSuccess,
            onFail: onFail,
          );
        }

        return Dialog(
          insetPadding: const EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          child: Container(
            width: 360,
            height: 358,
            decoration: BoxDecoration(color: Colors.transparent),
            child: Column(
              children: [
                // WebView content
                Expanded(
                  child: ClipRRect(
                    borderRadius: themeNotifier.getBorderRadiusAll(0.75),
                    child: InAppWebView(
                      webViewEnvironment: WebviewService.webViewEnvironment,
                      initialData: InAppWebViewInitialData(
                        data: captchaHtmlContent(
                          Theme.of(context).brightness == Brightness.dark,
                        ),
                        baseUrl: WebUri('https://localhost/'),
                      ),
                      initialSettings: InAppWebViewSettings(
                        isInspectable: true,
                        mediaPlaybackRequiresUserGesture: false,
                        allowsInlineMediaPlayback: true,
                        iframeAllow: "camera; microphone",
                        iframeAllowFullscreen: true,
                        javaScriptEnabled: true,
                        domStorageEnabled: true,
                        databaseEnabled: true,
                        clearCache: false,
                        cacheEnabled: true,
                        mixedContentMode:
                            MixedContentMode.MIXED_CONTENT_COMPATIBILITY_MODE,
                        allowsBackForwardNavigationGestures: true,
                        supportZoom: false,
                        disableDefaultErrorPage: false,
                        useOnLoadResource: false,
                        useShouldInterceptAjaxRequest: false,
                        useShouldInterceptFetchRequest: false,
                        applicationNameForUserAgent: "OpenCMS-Captcha-WebView",
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        logger.fine('Captcha WebView created');

                        // Add JavaScript handler to listen for captcha completion (non-web platforms)
                        if (!kIsWeb) {
                          controller.addJavaScriptHandler(
                            handlerName: 'captchaComplete',
                            callback: (args) {
                              logger.fine('Received captcha completion event: $args');
                              
                              Navigator.of(dialogContext).pop();
                              if (args[0] == 'success') {
                                onSuccess(args[1]);
                              } else if (args[0] == 'error') {
                                onFail(args[1]);
                              }
                            },
                          );
                        }
                      },
                      onLoadStart:
                          (InAppWebViewController controller, WebUri? url) {
                            logger.fine(
                              'CaptchaDialog: Captcha WebView loading...',
                            );
                          },
                      onLoadStop:
                          (
                            InAppWebViewController controller,
                            WebUri? url,
                          ) async {
                            logger.fine('Captcha WebView loaded');
                          },
                      onReceivedError:
                          (
                            InAppWebViewController controller,
                            WebResourceRequest request,
                            WebResourceError error,
                          ) {
                            logger.warning('Captcha WebView error: ${error.description}');

                            // For any errors, just log them since we're already using local HTML
                            logger.warning('CaptchaDialog: WebView error: ${error.description} for ${request.url}');
                          },
                      onProgressChanged:
                          (InAppWebViewController controller, int progress) {},
                    ),
                  ),
                ),
                if (!autoSolveRequested &&
                    config.username != null &&
                    config.username!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't want to slide this bs? ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showAutoSolveConfirmation(context, config.username!),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Request Auto-Solve",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tencent Captcha configuration class
class TencentCaptchaDialogConfig {
  final String bizState;
  final bool enableDarkMode;
  final String? username;

  const TencentCaptchaDialogConfig({
    required this.bizState,
    this.enableDarkMode = false,
    this.username,
  });
}
