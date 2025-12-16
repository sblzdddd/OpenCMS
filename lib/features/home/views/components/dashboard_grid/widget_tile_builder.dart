import 'package:flutter/material.dart';
import '../../widgets/banner_widget.dart';
import '../../../../homework/views/_widgets/homework_widget.dart';
import '../../../../assessment/views/_widgets/latest_assessment_widget.dart';
import '../../../../timetable/course_timetable/views/_widgets/next_class_widget.dart';
import '../../widgets/notices_widget.dart';
import '../../../../calendar/views/_widgets/calendar_widget.dart';

/// Builder for dashboard widget tiles
class WidgetTileBuilder {
  static Widget buildTile(
    MapEntry<String, Size> entry,
    double baseTileWidth,
    double spacing,
    bool isEditMode,
    BuildContext context, {
    bool? isEditModeParam,
    VoidCallback? onRefresh,
    int refreshTick = 0,
  }) {
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
      child: Stack(children: [child]),
    );
  }

  /// Build the widget content based on widget ID
  static Widget _buildWidgetContent(
    String id,
    VoidCallback? onRefresh,
    int refreshTick,
    Size span,
  ) {
    switch (id) {
      case 'notices':
        return NoticeCard(
          onRefresh: onRefresh,
          refreshTick: refreshTick,
          widgetSize: span,
        );
      case 'homework':
        return HomeworkCard(onRefresh: onRefresh, refreshTick: refreshTick);
      case 'assessments':
        return LatestAssessmentWidget(
          onRefresh: onRefresh,
          refreshTick: refreshTick,
        );
      case 'banner':
        return RepaintBoundary(
          child: BannerWidget(key: const ValueKey('banner_card')),
        );
      case 'next_class':
        return NextClassWidget(onRefresh: onRefresh, refreshTick: refreshTick);
      case 'calendar':
        return CalendarWidget(
          onRefresh: onRefresh,
          refreshTick: refreshTick,
          widgetSize: span,
        );
      default:
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1)),
          child: Text(id),
        );
    }
  }
}
