import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../theme/services/theme_services.dart';
import '../../../shared/pages/actions.dart';
import 'dart:async';
import '../../../shared/views/widgets/scaled_ink_well.dart';
import 'package:opencms/features/theme/views/widgets/skin_icon_widget.dart';

/// Base widget for dashboard items
class BaseDashboardWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? rightSideText;
  final String? bottomText;
  final String? bottomRightText;
  final Widget? extraContent;
  final String actionId;
  final IconData icon;
  final bool isLoading;
  final bool hasError;
  final bool hasData;
  final String? loadingText;
  final String? errorText;
  final String? noDataText;
  final int? refreshTick;
  final Future<void> Function({bool refresh})? onFetch;
  final bool hasMultipleTapAreas;

  const BaseDashboardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionId,
    this.rightSideText,
    this.bottomText,
    this.bottomRightText,
    this.extraContent,
    this.icon = Symbols.dashboard_rounded,
    this.isLoading = false,
    this.hasError = false,
    this.hasData = true,
    this.loadingText = 'Loading...',
    this.errorText = 'Failed to load data',
    this.noDataText = 'No data available',
    this.refreshTick,
    this.onFetch,
    this.hasMultipleTapAreas = false,
  });

  @override
  State<BaseDashboardWidget> createState() => _BaseDashboardWidgetState();
}

class _BaseDashboardWidgetState extends State<BaseDashboardWidget> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Initial fetch if provided
    if (widget.onFetch != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check mounted before calling callback as widget might be disposed
        if (mounted) {
          widget.onFetch!(refresh: false);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant BaseDashboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTick != null &&
        widget.refreshTick != oldWidget.refreshTick) {
      if (widget.onFetch != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onFetch!(refresh: true);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return ScaledInkWell(
      borderRadius: themeNotifier.getBorderRadiusAll(1.5),
      splashFactory: widget.hasMultipleTapAreas
          ? NoSplash.splashFactory
          : InkSplash.splashFactory,
      onTap: () async {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final page = await buildActionPage({'id': widget.actionId});
          if (mounted) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
          }
        });
      },
      background: (inkWell) => Container(
        decoration: BoxDecoration(
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.01),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: themeNotifier.needTransparentBG
              ? (!themeNotifier.isDarkMode
                  ? Theme.of(
                      context,
                    ).colorScheme.surfaceBright.withValues(alpha: 0.6)
                  : Theme.of(
                      context,
                    ).colorScheme.surfaceContainer.withValues(alpha: 0.8))
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
          child: inkWell,
        ),
      ),
      child: Stack(
        children: [
          // Background icon positioned on the right side
          Positioned(
            right: 8,
            bottom: 8,
            child: SkinIcon(
              imageKey: 'home.${widget.actionId}WidgetIcon',
              fallbackIcon: widget.icon,
              fallbackIconColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              fallbackIconBackgroundColor: Colors.transparent,
              size: 64,
              iconSize: 64,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading || widget.hasError) {
      return _buildInactiveState();
    }

    return _buildDataState();
  }

  Widget _buildInactiveState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: widget.hasError
                ? Icon(Symbols.error_outline_rounded, size: 20)
                : CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 12),
          Text(
            widget.hasError ? (widget.errorText ?? '') : (widget.loadingText ?? ''),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDataState() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    
    // Build main content (title and subtitle)
    Widget mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            if (widget.rightSideText != null) ...[
              Text(
                widget.rightSideText!,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
            if (widget.rightSideText == null) ...[
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Symbols.chevron_right_rounded, size: 18),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          widget.hasData ? widget.subtitle : (widget.noDataText ?? ''),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );

    // Wrap main content in tappable area if there are multiple tap areas
    if (widget.hasMultipleTapAreas) {
      mainContent = ScaledInkWell(
        borderRadius: themeNotifier.getBorderRadiusAll(0.5),
        onTap: () async {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final page = await buildActionPage({'id': widget.actionId});
            if (mounted) {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => page));
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
          child: mainContent,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mainContent,
        if (widget.bottomText != null || widget.bottomRightText != null) ...[
          const Spacer(),
          Row(
            children: [
              Text(
                widget.bottomText ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Text(
                widget.bottomRightText ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        if (widget.extraContent != null) ...[const Spacer(), widget.extraContent!],
      ],
    );
  }
}
