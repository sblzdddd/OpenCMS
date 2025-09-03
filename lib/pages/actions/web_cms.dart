import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as iaw;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../data/constants/api_constants.dart';
import '../../services/shared/storage_client.dart';

class WebCmsPage extends StatefulWidget {
  final String? initialUrl;
  final String? windowTitle;
  final bool disableControls;
  const WebCmsPage({super.key, this.initialUrl, this.windowTitle, this.disableControls = false});

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

      // Inject cookies for both new CMS and legacy CMS domains
      final iaw.WebUri baseUri = iaw.WebUri(ApiConstants.baseUrl);
      final iaw.WebUri legacyBaseUri = iaw.WebUri(ApiConstants.legacyCMSBaseUrl);
      
      // Inject stored cookies for both domains so they are available to the WebView session
      for (final Cookie cookie in cookies) {
        // Inject for new CMS domain
        await cookieManager.setCookie(
          url: baseUri,
          name: cookie.name,
          value: cookie.value,
          path: cookie.path ?? '/',
          isSecure: cookie.secure,
          domain: cookie.domain,
          isHttpOnly: cookie.httpOnly,
        );
        
        // Inject for legacy CMS domain (needed for notification/daily bulletin URLs)
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
      print('Loading CMS with URL: ${widget.initialUrl}');
      _webViewController!.loadUrl(
        urlRequest: iaw.URLRequest(
          url: iaw.WebUri(widget.initialUrl ?? ApiConstants.cmsReferer),
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
      if(widget.windowTitle != null) {
        await _webViewController!.evaluateJavascript(source: '''
          var s = document.createElement('style');
          s.id = 'ocms-css-inject';
          s.type = 'text/css';
          s.appendChild(document.createTextNode(`
            .leftbar, #leaders1, .btop.a12, .main1>.main1.noprint {display:none!important;}
            .main1, .rightbar1, .ctbody1, .meair_lef {width:100%!important;margin: 0!important;}
            
          `));
          (document.head || document.documentElement).appendChild(s);
        ''');
      }
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
        title: Text(widget.windowTitle ?? 'Web CMS'),
        actions: widget.disableControls ? [] : [
          IconButton(
            icon: const Icon(Symbols.arrow_back_rounded),
            onPressed: _canGoBack
                ? () async {
                    await _webViewController?.goBack();
                    await _updateNavState();
                  }
                : null,
            tooltip: 'Back',
          ),
          IconButton(
            icon: const Icon(Symbols.arrow_forward_rounded),
            onPressed: _canGoForward
                ? () async {
                    await _webViewController?.goForward();
                    await _updateNavState();
                  }
                : null,
            tooltip: 'Forward',
          ),
          IconButton(
            icon: const Icon(Symbols.refresh_rounded),
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
              onReceivedError: (controller, request, error) async {
                await _updateNavState();
              },
            ),
          ),
        ],
      ),
    );
  }
}