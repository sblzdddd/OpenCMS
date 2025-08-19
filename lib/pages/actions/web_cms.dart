import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as iaw;
import 'package:cookie_jar/cookie_jar.dart';

import '../../data/constants/api_constants.dart';
import '../../services/shared/storage_client.dart';

class WebCmsPage extends StatefulWidget {
  const WebCmsPage({super.key});

  @override
  State<WebCmsPage> createState() => _WebCmsPageState();
}

class _WebCmsPageState extends State<WebCmsPage> {
  iaw.InAppWebViewController? _webViewController;
  double _progress = 0.0;
  bool _cookiesPrepared = false;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _prepareCookies();
  }

  Future<void> _prepareCookies() async {
    try {
      final List<Cookie> cookies = await StorageClient.currentCookies;
      final iaw.CookieManager cookieManager = iaw.CookieManager.instance();

      final iaw.WebUri baseUri = iaw.WebUri(ApiConstants.baseUrl);
      // Inject stored cookies for the base domain so they are available to the WebView session
      for (final Cookie cookie in cookies) {
        await cookieManager.setCookie(
          url: baseUri,
          name: cookie.name,
          value: cookie.value,
          path: cookie.path ?? '/',
          isSecure: cookie.secure,
          domain: cookie.domain,
          isHttpOnly: cookie.httpOnly,
        );
      }
    } catch (e) {
      debugPrint('WebCmsPage: Failed to prepare cookies: $e');
    } finally {
      setState(() {
        _cookiesPrepared = true;
      });
      _loadCmsIfReady();
    }
  }

  void _loadCmsIfReady() {
    if (_cookiesPrepared && _webViewController != null) {
      _webViewController!.loadUrl(
        urlRequest: iaw.URLRequest(
          url: iaw.WebUri(ApiConstants.cmsReferer),
        ),
      );
    }
  }

  Future<void> _injectZeroBodyMarginCss() async {
    if (_webViewController == null) return;
		const String js = '''
(function(){
  try {
    var ensure = function() {
      try {
        var existing = document.getElementById('ocms-css-inject');
        if (!existing) {
          var s = document.createElement('style');
          s.id = 'ocms-css-inject';
          s.type = 'text/css';
          s.appendChild(document.createTextNode(`body{margin:0!important;}
          :where(.css-45f3r4).ant-layout{background-color:transparent!important;}
          `));
          (document.head || document.documentElement).appendChild(s);
        }
      } catch (e) {}
    };
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', ensure);
    } else {
      ensure();
    }
  } catch (e) {}
})();
''';
    try {
      await _webViewController!.evaluateJavascript(source: js);
    } catch (e) {
      debugPrint('WebCmsPage: CSS inject failed: $e');
    }
  }

  Future<void> _updateNavState() async {
    if (_webViewController == null) return;
    try {
      final bool canBack = await _webViewController!.canGoBack();
      final bool canFwd = await _webViewController!.canGoForward();
      if (!mounted) return;
      setState(() {
        _canGoBack = canBack;
        _canGoForward = canFwd;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web CMS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _canGoBack
                ? () async {
                    await _webViewController?.goBack();
                    await _updateNavState();
                  }
                : null,
            tooltip: 'Back',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _canGoForward
                ? () async {
                    await _webViewController?.goForward();
                    await _updateNavState();
                  }
                : null,
            tooltip: 'Forward',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              if (_webViewController != null) {
                await _webViewController!.reload();
              }
            },
            tooltip: 'Reload',
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 1.0)
            LinearProgressIndicator(value: _progress == 0 ? null : _progress),
          Expanded(
            child: iaw.InAppWebView(
              initialSettings: iaw.InAppWebViewSettings(
                // Keep defaults sensible; JavaScript enabled by default
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
                _loadCmsIfReady();
                _updateNavState();
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _progress = 0.1;
                });
                _updateNavState();
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100.0;
                });
              },
              onLoadStop: (controller, url) async {
                await _injectZeroBodyMarginCss();
                await _updateNavState();
              },
              onLoadResource: (controller, resource) async {
                // Re-apply CSS if the main document reloads resources and layout resets
                await _injectZeroBodyMarginCss();
              },
              onUpdateVisitedHistory: (controller, url, isReload) async {
                await _updateNavState();
              },
              onLoadError: (controller, url, code, message) async {
                await _updateNavState();
              },
            ),
          ),
        ],
      ),
    );
  }
}