import 'package:flutter/material.dart';
import 'web_cms_base.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class WebCmsContent extends WebCmsBase {
  final bool isWideScreen;

  const WebCmsContent({
    super.key,
    required super.initialUrl,
    super.windowTitle,
    this.isWideScreen = false,
  });

  @override
  State<WebCmsContent> createState() => _WebCmsContentState();
}

class _WebCmsContentState extends WebCmsBaseState<WebCmsContent> {


  @override
  Widget build(BuildContext context) {
    if (widget.initialUrl == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.error_outline_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No content available',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final content = Column(
      children: [
        if (progress < 1.0)
          LinearProgressIndicator(value: progress == 0 ? null : progress),
        Expanded(
          child: buildWebView(
            builder: (controller) => const SizedBox.shrink(), // WebView is built by base class
          ),
        ),
      ],
    );

    // Only wrap with RefreshIndicator in mobile mode
    // In wide screen mode, let the parent page handle refresh
    if (widget.isWideScreen) {
      return content;
    } else {
      return RefreshIndicator(
        onRefresh: () async {
          await reload();
        },
        child: content,
      );
    }
  }
}
