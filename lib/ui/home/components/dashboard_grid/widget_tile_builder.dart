import 'package:flutter/material.dart';
import '../banner_widget.dart';
import '../homework_widget.dart';
import '../latest_assessment_widget.dart';
import '../next_class_widget.dart';
import '../../components/notice_card.dart';
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
    {bool? isEditModeParam, VoidCallback? onRefresh, int refreshTick = 0,}
  ) {
    final String id = entry.key;
    final Size span = entry.value;
    final double spanX = span.width;
    final double spanY = span.height;
    final double width = baseTileWidth * spanX + spacing * (spanX - 1);
    final double unitHeight = 100;
    final double height = unitHeight * spanY + spacing * (spanY - 1);

    Widget child = _buildWidgetContent(id, onRefresh, refreshTick);
    
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
                    borderRadius: BorderRadius.circular(8),
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
  static Widget _buildWidgetContent(String id, VoidCallback? onRefresh, int refreshTick) {
    switch (id) {
      case 'notices':
        return const NoticeCard();
      case 'homework':
        return HomeworkCard(onRefresh: onRefresh, refreshTick: refreshTick);
      case 'assessments':
        return const LatestAssessmentWidget();
      case 'banner':
        return RepaintBoundary(
          child: BannerWidget(
            key: const ValueKey('banner_card'),
          ),
        );
      case 'next_class':
        return NextClassWidget(onRefresh: onRefresh, refreshTick: refreshTick);
      default:
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
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
    final newSize = WidgetSizeManager.getOppositeSize(currentSize);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change ${WidgetSizeManager.getWidgetTitle(widgetId)} Size'),
        content: Text('Choose the size for this widget:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSizeChange(newSize);
              Navigator.of(context).pop();
            },
            child: Text(WidgetSizeManager.getOppositeSizeLabel(currentSize)),
          ),
        ],
      ),
    );
  }
}
