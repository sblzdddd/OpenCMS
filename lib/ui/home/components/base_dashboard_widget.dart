import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/theme/theme_services.dart';
import '../../../pages/actions.dart';
import 'dart:async';
import '../../shared/scaled_ink_well.dart';
import '../../../global_press_scale.dart';

/// Base mixin for dashboard widget states that provides common functionality
/// including layout, refresh logic, error handling, and common UI patterns
mixin BaseDashboardWidgetMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _updateTimer;

  /// Get the current loading state
  bool get isLoading => _isLoading;

  /// Get the current error state
  bool get hasError => _hasError;

  /// Initialize the widget - override this to set up initial data
  Future<void> initializeWidget();

  /// Start the update timer - override to customize update frequency
  void startTimer() {
    // Default: update every hour
    _updateTimer = Timer.periodic(const Duration(hours: 1), (_) {
      if (mounted) {
        setState(() {
          // Force rebuild to update data
        });
      }
    });
  }

  /// Set custom timer duration - call this in initializeWidget if needed
  void setCustomTimer(Duration duration) {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(duration, (_) {
      if (mounted) {
        setState(() {
          // Force rebuild to update data
        });
      }
    });
  }

  /// Set loading state
  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  /// Set error state
  void setError(bool hasError) {
    if (mounted) {
      setState(() {
        _hasError = hasError;
      });
    }
  }

  /// Refresh the widget data
  Future<void> refresh() async {
    debugPrint('${widget.runtimeType}: Refreshing data');
    await refreshData();
  }

  /// Refresh data - override this to implement data fetching
  Future<void> refreshData();

  /// Get the extra content for the widget
  Widget? getExtraContent(BuildContext context) => null;

  /// Get the title text for the widget
  String getWidgetTitle() => '';

  /// Get the subtitle text for the widget
  String getWidgetSubtitle() => '';

  /// Get the right side text (optional)
  String? getRightSideText() => null;

  /// Get the bottom text (optional)
  String? getBottomText() => null;

  /// Get the bottom text (optional)
  String? getBottomRightText() => null;

  /// Get the loading text
  String getLoadingText() => 'Loading...';

  /// Get the error text
  String getErrorText() => 'Failed to load data';

  /// Get the no data text
  String getNoDataText() => 'No data available';

  /// Get the refresh hint text
  String getRefreshHintText() => 'Swipe down to refresh';

  /// Check if widget has data to display
  bool hasWidgetData();

  /// Get the action ID for navigation
  String getActionId();

  /// Get the widget icon
  IconData getWidgetIcon() => Icons.dashboard;

  /// Check if widget has multiple tap areas (overrides main tap behavior)
  bool hasMultipleTapAreas() => false;

  /// Clean up timer
  void disposeMixin() {
    _updateTimer?.cancel();
  }

  /// Build the common widget layout
  Widget buildCommonLayout() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return ScaledInkWell(
      borderRadius: themeNotifier.getBorderRadiusAll(1.5),
      splashFactory: hasMultipleTapAreas() ? NoSplash.splashFactory : InkSplash.splashFactory,
      onTap: () async {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final page = await buildActionPage({'id': getActionId()});
          if (mounted) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
          }
        });
      },
      background: (inkWell) => Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: themeNotifier.getBorderRadiusAll(1.5),
        child: inkWell,
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: _buildContent(),
          ),
          // Background icon positioned on the right side
          Positioned(
            right: 8,
            bottom: 8,
            child: Icon(
              getWidgetIcon(),
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading || _hasError) {
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
            child: hasError
                ? Icon(Icons.error_outline, size: 20)
                : CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 12),
          Text(
            hasError ? getErrorText() : getLoadingText(),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDataState() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final rightText = getRightSideText();
    final bottomRightText = getBottomRightText();
    final bottomText = getBottomText();
    final extraContent = getExtraContent(context);

    // Build main content (title and subtitle)
    Widget mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                getWidgetTitle(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            if (rightText != null) ...[
              Text(
                rightText,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
            if (rightText == null) ...[
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.chevron_right, size: 18),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          hasWidgetData() ? getWidgetSubtitle() : getNoDataText(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );

    // Wrap main content in tappable area if there are multiple tap areas
    if (hasMultipleTapAreas()) {
      mainContent = ScaledInkWell(
        borderRadius: themeNotifier.getBorderRadiusAll(0.5),
        onTap: () async {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final page = await buildActionPage({'id': getActionId()});
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
        if (bottomText != null || bottomRightText != null) ...[
          const Spacer(),
          Row(
            children: [
              Text(
                bottomText ?? '',
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
                bottomRightText ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        if (extraContent != null) ...[const Spacer(), extraContent],
      ],
    );
  }
}
