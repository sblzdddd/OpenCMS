import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as iaw;
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../ui/shared/views/web_cms_base.dart';
import '../../ui/shared/widgets/custom_app_bar.dart';

class WebCmsPage extends WebCmsBase {
  final bool disableControls;
  
  const WebCmsPage({
    super.key, 
    super.initialUrl, 
    super.windowTitle, 
    this.disableControls = false
  });

  @override
  State<WebCmsPage> createState() => _WebCmsPageState();
}

class _WebCmsPageState extends WebCmsBaseState<WebCmsPage> {
  bool _canGoBack = false;
  bool _canGoForward = false;

  Future<void> _updateNavState() async {
    if (webViewController == null) return;
    try {
      final bool canBack = await webViewController!.canGoBack();
      final bool canFwd = await webViewController!.canGoForward();
      if (!mounted) return;
      setState(() {
        _canGoBack = canBack;
        _canGoForward = canFwd;
      });
    } catch (_) {}
  }

  @override
  void onWebViewCreated(iaw.InAppWebViewController controller) {
    _updateNavState();
  }

  @override
  void onLoadStart(iaw.InAppWebViewController controller, iaw.WebUri? url) {
    _updateNavState();
  }

  @override
  void onLoadStop(iaw.InAppWebViewController controller, iaw.WebUri? url) {
    _updateNavState();
  }

  @override
  void onLoadResource(iaw.InAppWebViewController controller, iaw.LoadedResource resource) {
    // Re-apply CSS if the main document reloads resources and layout resets
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(widget.windowTitle ?? 'Web CMS'),
        actions: widget.disableControls ? [] : [
          IconButton(
            icon: const Icon(Symbols.arrow_back_rounded),
            onPressed: _canGoBack
                ? () async {
                    await webViewController?.goBack();
                    await _updateNavState();
                  }
                : null,
            tooltip: 'Back',
          ),
          IconButton(
            icon: const Icon(Symbols.arrow_forward_rounded),
            onPressed: _canGoForward
                ? () async {
                    await webViewController?.goForward();
                    await _updateNavState();
                  }
                : null,
            tooltip: 'Forward',
          ),
          IconButton(
            icon: const Icon(Symbols.refresh_rounded),
            onPressed: () async {
              await reload();
            },
            tooltip: 'Reload',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          if (progress < 1.0)
            LinearProgressIndicator(value: progress == 0 ? null : progress),
          Expanded(
            child: buildWebView(
              builder: (controller) => const SizedBox.shrink(), // WebView is built by base class
            ),
          ),
        ],
      ),
    );
  }
}