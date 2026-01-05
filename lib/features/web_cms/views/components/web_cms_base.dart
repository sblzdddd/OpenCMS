import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as iaw;
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/features/auth/services/token_refresh_service.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/API/storage/token_storage.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../../../auth/services/auth_service.dart';
import '../../constants/web_cms_styles.dart';
import 'package:logging/logging.dart';

final logger = Logger('WebCmsBase');

/// Base class for web CMS components that handles common functionality
/// like cookie preparation, web view management, and CSS injection
abstract class WebCmsBase extends StatefulWidget {
  final String? initialUrl;
  final String? windowTitle;

  const WebCmsBase({super.key, required this.initialUrl, this.windowTitle});
}

abstract class WebCmsBaseState<T extends WebCmsBase> extends State<T> {
  iaw.InAppWebViewController? _webViewController;
  double _progress = 0.0;
  bool _cookiesPrepared = false;
  String?
  _resolvedUrl; // For web: URL obtained via redirect that contains auth token

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
      if (kIsWeb) {
        try {
          final resolved = await di<AuthService>().getJumpUrlToLegacy();
          if (resolved.isNotEmpty) {
            _resolvedUrl = resolved;
            logger.info(
              'Resolved redirect URL (raw): $_resolvedUrl',
            );
          } else {
            logger.info(
              'Empty redirect location, fallback to CMS referer',
            );
            _resolvedUrl = widget.initialUrl ?? API.cmsReferer;
          }
        } catch (e, stackTrace) {
          logger.severe('Failed to resolve web redirect: $e', e, stackTrace);
          _resolvedUrl = widget.initialUrl ?? API.cmsReferer;
        }
      } else {
        await di<TokenRefreshService>().refreshLegacyCookies();
        final iaw.CookieManager cookieManager = iaw.CookieManager.instance();

        final iaw.WebUri baseUri = iaw.WebUri(API.baseUrl);
        final iaw.WebUri legacyBaseUri = iaw.WebUri(
          API.legacyCMSBaseUrl,
        );

        await cookieManager.setCookie(
          url: baseUri,
          name: "access_token",
          value: (await di<TokenStorage>().accessToken ?? '').replaceFirst('Bearer ', ''),
          path: '/',
          isSecure: true,
          domain: baseUri.host,
          isHttpOnly: true,
          sameSite: iaw.HTTPCookieSameSitePolicy.LAX,
        );
        await cookieManager.setCookie(
          url: baseUri,
          name: "refresh_token",
          value: await di<TokenStorage>().refreshToken ?? '',
          path: '/',
          isSecure: true,
          domain: baseUri.host,
          isHttpOnly: true,
          sameSite: iaw.HTTPCookieSameSitePolicy.LAX,
        );

        await cookieManager.setCookie(
          url: legacyBaseUri,
          name: "sid_nb",
          value: await di<TokenStorage>().sidNb ?? '',
          path: '/',
          isSecure: true,
          domain: legacyBaseUri.host,
          isHttpOnly: false,
          sameSite: iaw.HTTPCookieSameSitePolicy.NONE,
        );

        await cookieManager.setCookie(
          url: legacyBaseUri,
          name: "sid_scie",
          value: await di<TokenStorage>().sidScie ?? '',
          path: '/',
          isSecure: true,
          domain: legacyBaseUri.host,
          isHttpOnly: false,
          sameSite: iaw.HTTPCookieSameSitePolicy.NONE,
        );
      }
    } catch (e, stackTrace) {
      logger.severe('Failed to prepare cookies: $e', e, stackTrace);
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() {
          _cookiesPrepared = true;
        });
        _loadCmsIfReady();
      }
    }
  }

  // No-op helpers for non-web branch

  void _loadCmsIfReady() {
    if (_cookiesPrepared && _webViewController != null) {
      String url = _resolvedUrl ?? widget.initialUrl ?? API.cmsReferer;
      if (di<LoginState>().isMock) {
        url = '${API.mockUrl}/index.html';
      }
      logger.info('Loading CMS with URL: $url');
      _webViewController!.loadUrl(
        urlRequest: iaw.URLRequest(url: iaw.WebUri(url)),
      );
    }
  }

  Future<void> _injectZeroBodyMarginCss() async {
    if (_webViewController == null) return;
    try {
      if (widget.windowTitle != null) {
        await _webViewController!.evaluateJavascript(
          source: zeroBodyMarginStyle(),
        );
      }
      if (mounted) {
        final webCmsStyleString = webCmsStyle(context);
        await _webViewController!.evaluateJavascript(source: webCmsStyleString);
      }
    } catch (e, stackTrace) {
      logger.severe('CSS inject failed: $e', e, stackTrace);
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
      onWebViewCreated: (controller) async {
        await _injectZeroBodyMarginCss();
        _webViewController = controller;
        _loadCmsIfReady();
        onWebViewCreated(controller);
      },
      onLoadStart: (controller, url) async {
        await _injectZeroBodyMarginCss();
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
  void onLoadResource(
    iaw.InAppWebViewController controller,
    iaw.LoadedResource resource,
  ) {}
}
