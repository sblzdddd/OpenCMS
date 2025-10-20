import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../../../services/theme/theme_services.dart';
import '../../../../main.dart';
import 'captcha_html_content.dart';
import 'dart:html' as html show window, MessageEvent, Event;

/// Tencent Captcha implementation
class TencentCaptchaDialog {

  /// Initialize the captcha with appId
  static void init(String appId) {
    debugPrint('CaptchaDialog: Tencent Captcha initialized with appId: $appId');
  }

  /// Perform captcha verification with popup webview
  static Future<void> verify({
    required BuildContext context,
    required TencentCaptchaDialogConfig config,
    required Function(dynamic) onLoaded,
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFail,
  }) async {
    debugPrint('CaptchaDialog: Tencent Captcha: Starting verification...');
    
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 200));
    onLoaded({'status': 'loaded', 'bizState': config.bizState});
    if(!context.mounted) {
      debugPrint('CaptchaDialog: Tencent Captcha: Context is not mounted');
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

  /// Show captcha webview in a popup dialog
  static Future<void> _showCaptchaWebView({
    required BuildContext context,
    required TencentCaptchaDialogConfig config,
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFail,
  }) async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    await showDialog(
      context: context,
      barrierDismissible: false, // Disable clicking outside to close
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        // Set up message listener for web platform inside the dialog
        if (kIsWeb) {
          void messageListener(html.Event event) {
            if (event is html.MessageEvent) {
              final data = event.data;
              
              if (data is Map && data['type'] == 'captchaResult') {
                debugPrint('CaptchaDialog: Received captcha result via postMessage: $data');
                
                // Remove the listener to prevent multiple calls
                html.window.removeEventListener('message', messageListener);
                
                // Close the dialog
                Navigator.of(dialogContext).pop();
                
                final payload = data['payload'];
                if (payload is Map) {
                  final result = payload['result'];
                  final captchaData = payload['data'];
                  
                  if (result == 'success') {
                    onSuccess(captchaData);
                  } else if (result == 'error') {
                    onFail(captchaData);
                  }
                }
              }
            }
          }
          
          html.window.addEventListener('message', messageListener);
        }
        
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
                    borderRadius: themeNotifier.getBorderRadiusAll(0.75),
                    child: InAppWebView(
                      webViewEnvironment: webViewEnvironment,
                      initialData: InAppWebViewInitialData(
                        data: captchaHtmlContent(Theme.of(context).brightness == Brightness.dark),
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
                        debugPrint('CaptchaDialog: Captcha WebView created');
                        
                        // Add JavaScript handler to listen for captcha completion (non-web platforms)
                        if (!kIsWeb) {
                          controller.addJavaScriptHandler(
                            handlerName: 'captchaComplete',
                            callback: (args) {
                              debugPrint('CaptchaDialog: Received captcha completion event: $args');
                              
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
                      onLoadStart: (InAppWebViewController controller, WebUri? url) {
                        debugPrint('CaptchaDialog: Captcha WebView loading...');
                      },
                      onLoadStop: (InAppWebViewController controller, WebUri? url) async {
                        debugPrint('CaptchaDialog: Captcha WebView loaded');
                      },
                      onReceivedError: (InAppWebViewController controller, WebResourceRequest request, WebResourceError error) {
                        debugPrint('CaptchaDialog: Captcha WebView error: ${error.description}');
                        
                        // For any errors, just log them since we're already using local HTML
                        debugPrint('CaptchaDialog: WebView error: ${error.description} for ${request.url}');
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
