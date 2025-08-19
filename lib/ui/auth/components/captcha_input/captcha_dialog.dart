import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../main.dart';
import 'captcha_html_content.dart';

/// Tencent Captcha implementation
class TencentCaptchaDialog {

  /// Initialize the captcha with appId
  static void init(String appId) {
    print('Tencent Captcha initialized with appId: $appId');
  }

  /// Perform captcha verification with popup webview
  static Future<void> verify({
    required BuildContext context,
    required TencentCaptchaDialogConfig config,
    required Function(dynamic) onLoaded,
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFail,
  }) async {
    print('Tencent Captcha: Starting verification...');
    
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 200));
    onLoaded({'status': 'loaded', 'bizState': config.bizState});
    
    // Show popup webview
    await _showCaptchaWebView(
      context: context,
      config: config,
      onSuccess: onSuccess,
      onFail: onFail,
    );
  }

  /// Show captcha webview in a popup dialog
  static Future<void> _showCaptchaWebView({
    required BuildContext context,
    required TencentCaptchaDialogConfig config,
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFail,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Disable clicking outside to close
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          child: Container(
            width: 360,
            height: 358,
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              children: [
                // WebView content
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: InAppWebView(
                      webViewEnvironment: webViewEnvironment,
                      initialData: InAppWebViewInitialData(
                        data: captchaHtmlContent,
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
                        mixedContentMode: MixedContentMode.MIXED_CONTENT_COMPATIBILITY_MODE,
                        allowsBackForwardNavigationGestures: true,
                        supportZoom: false,
                        disableDefaultErrorPage: false,
                        useOnLoadResource: false,
                        useShouldInterceptAjaxRequest: false,
                        useShouldInterceptFetchRequest: false,
                        applicationNameForUserAgent: "OpenCMS-Captcha-WebView",
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        print('Captcha WebView created');
                        
                        // Add JavaScript handler to listen for captcha completion
                        controller.addJavaScriptHandler(
                          handlerName: 'captchaComplete',
                          callback: (args) {
                            print('Received captcha completion event: $args');
                            
                            Navigator.of(dialogContext).pop();
                            if (args[0] == 'success') {
                              onSuccess(args[1]);
                            } else if (args[0] == 'error') {
                              onFail(args[1]);
                            }
                          },
                        );
                      },
                      onLoadStart: (InAppWebViewController controller, WebUri? url) {
                        print('Captcha WebView loading: $url');
                      },
                      onLoadStop: (InAppWebViewController controller, WebUri? url) async {
                        print('Captcha WebView loaded: $url');
                      },
                      onReceivedError: (InAppWebViewController controller, WebResourceRequest request, WebResourceError error) {
                        print('Captcha WebView error: ${error.description}');
                        
                        // For any errors, just log them since we're already using local HTML
                        print('WebView error: ${error.description} for ${request.url}');
                      },
                      onProgressChanged: (InAppWebViewController controller, int progress) {
                      },
                    ),
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

  const TencentCaptchaDialogConfig({
    required this.bizState,
    this.enableDarkMode = false,
  });
}
