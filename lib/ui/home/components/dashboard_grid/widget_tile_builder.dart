import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../services/theme/theme_services.dart';
import '../../widgets/banner_widget.dart';
import '../../widgets/homework_widget.dart';
import '../../widgets/latest_assessment_widget.dart';
import '../../widgets/next_class_widget.dart';
import '../../widgets/notices_widget.dart';
import '../../widgets/calendar_widget.dart';
import 'widget_size_manager.dart';

/// Builder for dashboard widget tiles
class WidgetTileBuilder {
  /// Build a widget tile with size indicator and resize functionality
  static Widget buildTile(
    MapEntry<String, Size> entry,
    double baseTileWidth,
    double spacing,
    bool isEditMode,
    Function(String) onSizeChange,
    BuildContext context,
    {bool? isEditModeParam, VoidCallback? onRefresh, int refreshTick = 0,}
  ) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final String id = entry.key;
    final Size span = entry.value;
    final double spanX = span.width;
    final double spanY = span.height;
    final double width = baseTileWidth * spanX + spacing * (spanX - 1);
    final double unitHeight = 110;
    final double height = unitHeight * spanY + spacing * (spanY - 1);

    Widget child = _buildWidgetContent(id, onRefresh, refreshTick, span);
    
    // Make widgets non-clickable when in edit mode
    if (isEditModeParam == true) {
      child = GestureDetector(
        onTap: () {}, // Empty onTap to prevent navigation
        child: child,
      );
    }

    return SizedBox(
      key: ValueKey('tile_$id'),
      width: width,
      height: height,
      child: Stack(
        children: [
          child,
          // Size indicator in edit mode (except for banner)
          if (isEditMode && WidgetSizeManager.canResize(id))
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => onSizeChange(id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: themeNotifier.getBorderRadiusAll(0.5),
                  ),
                  child: Text(
                    '${span.width.toInt()}×${span.height.toInt()}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build the widget content based on widget ID
  static Widget _buildWidgetContent(String id, VoidCallback? onRefresh, int refreshTick, Size span) {
    switch (id) {
      case 'notices':
        return NoticeCard(onRefresh: onRefresh, refreshTick: refreshTick, widgetSize: span);
      case 'homework':
        return HomeworkCard(onRefresh: onRefresh, refreshTick: refreshTick);
      case 'assessments':
        return LatestAssessmentWidget(onRefresh: onRefresh, refreshTick: refreshTick);
      case 'banner':
        return RepaintBoundary(
          child: BannerWidget(
            key: const ValueKey('banner_card'),
          ),
        );
      case 'next_class':
        return NextClassWidget(onRefresh: onRefresh, refreshTick: refreshTick);
      case 'calendar':
        return CalendarWidget(onRefresh: onRefresh, refreshTick: refreshTick, widgetSize: span);
      default:
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
          ),
          child: Text(id),
        );
    }
  }

  /// Show dialog to change widget size
  static void showSizeChangeDialog(
    BuildContext context,
    String widgetId,
    Size currentSize,
    Function(Size) onSizeChange,
  ) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final alternativeSizes = WidgetSizeManager.getAlternativeSizes(widgetId, currentSize);
    
    if (alternativeSizes.isEmpty) {
      // No alternative sizes available
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
        ),
        clipBehavior: Clip.antiAlias,
        title: Text('Change ${WidgetSizeManager.getWidgetTitle(widgetId)} Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current size: ${WidgetSizeManager.getSizeLabel(currentSize)}'),
            const SizedBox(height: 16),
            const Text('Choose a new size:'),
            const SizedBox(height: 8),
            ...alternativeSizes.map((size) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              title: Text(WidgetSizeManager.getSizeLabel(size)),
              subtitle: Text(WidgetSizeManager.getSizeDescription(size)),
              leading: Icon(WidgetSizeManager.getSizeIcon(size)),
              onTap: () {
                onSizeChange(size);
                Navigator.of(context).pop();
              },
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
