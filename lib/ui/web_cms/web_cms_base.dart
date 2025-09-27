import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as iaw;
import 'package:cookie_jar/cookie_jar.dart';
import '../../data/constants/api_endpoints.dart';
import '../../services/auth/auth_service.dart';
import '../../services/shared/storage_client.dart';
import '../../data/constants/web_cms_styles.dart';

/// Base class for web CMS components that handles common functionality
/// like cookie preparation, web view management, and CSS injection
abstract class WebCmsBase extends StatefulWidget {
  final String? initialUrl;
  final String? windowTitle;

  const WebCmsBase({
    super.key,
    required this.initialUrl,
    this.windowTitle,
  });
}

abstract class WebCmsBaseState<T extends WebCmsBase> extends State<T> {
  iaw.InAppWebViewController? _webViewController;
  final AuthService _authService = AuthService();
  double _progress = 0.0;
  bool _cookiesPrepared = false;

  @override
  void initState() {
    super.initState();
    _prepareCookies();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialUrl != widget.initialUrl) {
      _prepareCookies();
    }
  }

  Future<void> _prepareCookies() async {
    try {
      await _authService.refreshLegacyCookies();
      final List<Cookie> cookies = await StorageClient.currentCookies;
      final iaw.CookieManager cookieManager = iaw.CookieManager.instance();

      final iaw.WebUri baseUri = iaw.WebUri(ApiConstants.baseUrl);
      final iaw.WebUri legacyBaseUri = iaw.WebUri(ApiConstants.legacyCMSBaseUrl);

      for (final Cookie cookie in cookies) {
        if(cookie.value.isEmpty) continue;
        await cookieManager.setCookie(
          url: baseUri,
          name: cookie.name,
          value: cookie.value,
          path: cookie.path ?? '/',
          isSecure: cookie.secure,
          domain: cookie.domain,
          isHttpOnly: cookie.httpOnly,
        );
        await cookieManager.setCookie(
          url: legacyBaseUri,
          name: cookie.name,
          value: cookie.value,
          path: cookie.path ?? '/',
          isSecure: cookie.secure,
          domain: cookie.domain,
          isHttpOnly: cookie.httpOnly,
        );
      }
    } catch (e) {
      debugPrint('WebCmsBase: Failed to prepare cookies: $e');
      if(!mounted) return;
    } finally {
      if (mounted) {
        setState(() {
          _cookiesPrepared = true;
        });
        _loadCmsIfReady();
      }
    }
  }

  void _loadCmsIfReady() {
    if (_cookiesPrepared && _webViewController != null) {
      debugPrint('WebCmsBase: Loading CMS with URL: ${widget.initialUrl}');
      _webViewController!.loadUrl(
        urlRequest: iaw.URLRequest(
          url: iaw.WebUri(widget.initialUrl ?? ApiConstants.cmsReferer),
        ),
      );
    }
  }

  Future<void> _injectZeroBodyMarginCss() async {
    if (_webViewController == null) return;
    try {
      if(widget.windowTitle != null) {
        await _webViewController!.evaluateJavascript(source: '''
          var s = document.createElement('style');
          s.id = 'ocms-css-inject';
          s.type = 'text/css';
          s.appendChild(document.createTextNode(`
            .leftbar, #leaders1, .btop.a12, .main1>.main1.noprint, .btop, .photo1.m_left, .mae_tok.a12 {display:none!important;}
            .main1, .rightbar1, .ctbody1, .meair_lef {width:100%!important;margin: 0!important;}
            
          `));
          (document.head || document.documentElement).appendChild(s);
        ''');
      }
      // Capture the webCmsStyle result before async operations to avoid using context across async gaps
      final currentContext = context;
      final webCmsStyleString = webCmsStyle(currentContext);
      if (mounted) {
        await _webViewController!.evaluateJavascript(source: webCmsStyleString);
      }
    } catch (e) {
      debugPrint('WebCmsBase: CSS inject failed: $e');
    }
  }

  /// Get the current web view controller
  iaw.InAppWebViewController? get webViewController => _webViewController;

  /// Get the current progress value
  double get progress => _progress;

  /// Get whether cookies are prepared
  bool get cookiesPrepared => _cookiesPrepared;

  /// Reload the web view
  Future<void> reload() async {
    if (_webViewController != null) {
      await _webViewController!.reload();
    }
  }

  /// Build the web view widget with common settings and event handlers
  Widget buildWebView({
    required Widget Function(iaw.InAppWebViewController controller) builder,
  }) {
    return iaw.InAppWebView(
      initialSettings: iaw.InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        isInspectable: true,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        _loadCmsIfReady();
        onWebViewCreated(controller);
      },
      onLoadStart: (controller, url) {
        if (mounted) {
          setState(() {
            _progress = 0.1;
          });
        }
        onLoadStart(controller, url);
      },
      onProgressChanged: (controller, progress) {
        if (mounted) {
          setState(() {
            _progress = progress / 100.0;
          });
        }
        onProgressChanged(controller, progress);
      },
      onLoadStop: (controller, url) async {
        await _injectZeroBodyMarginCss();
        onLoadStop(controller, url);
      },
      onLoadResource: (controller, resource) async {
        await _injectZeroBodyMarginCss();
        onLoadResource(controller, resource);
      },
    );
  }

  /// Override these methods in subclasses for custom behavior
  void onWebViewCreated(iaw.InAppWebViewController controller) {}
  void onLoadStart(iaw.InAppWebViewController controller, iaw.WebUri? url) {}
  void onProgressChanged(iaw.InAppWebViewController controller, int progress) {}
  void onLoadStop(iaw.InAppWebViewController controller, iaw.WebUri? url) {}
  void onLoadResource(iaw.InAppWebViewController controller, iaw.LoadedResource resource) {}
}
