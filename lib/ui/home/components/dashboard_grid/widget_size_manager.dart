import 'package:flutter/material.dart';

/// Manages widget sizes and layout for the dashboard grid
class WidgetSizeManager {
  // Available widgets that can be added (excluding banner)
  static const List<String> availableWidgets = <String>[
    'banner',
    'notices',
    'homework',
    'assessments',
    'next_class',
  ];

  // Default span definitions in grid units (max 4 columns)
  static const Map<String, Size> defaultSpans = <String, Size>{
    'notices': Size(2, 1),
    'homework': Size(2, 1),
    'assessments': Size(2, 1),
    'banner': Size(4, 1.9),
    'next_class': Size(2, 1),
  };

  // Default layout
  static const List<MapEntry<String, Size>> defaultLayout = <MapEntry<String, Size>>[
    MapEntry('banner', Size(4, 1.9)),
    MapEntry('homework', Size(2, 1)),
    MapEntry('assessments', Size(2, 1)),
    MapEntry('next_class', Size(4, 1)),
  ];

  /// Get available widgets that can be added
  static List<String> getAddableWidgets(List<MapEntry<String, Size>> currentWidgets) {
    final List<String> currentWidgetIds = currentWidgets.map((e) => e.key).toList();
    return availableWidgets.where((widget) => !currentWidgetIds.contains(widget)).toList();
  }

  /// Get current spans from widget order
  static Map<String, Size> getCurrentSpans(List<MapEntry<String, Size>> widgetOrder) {
    final Map<String, Size> spans = <String, Size>{};
    for (final entry in widgetOrder) {
      spans[entry.key] = entry.value;
    }
    return spans;
  }

  /// Convert saved layout to new format with sizes
  static List<MapEntry<String, Size>> convertSavedLayout(List<String> savedIds) {
    return savedIds.map((id) {
      return MapEntry(id, defaultSpans[id] ?? const Size(2, 1));
    }).toList();
  }

  /// Get widget icon
  static IconData getWidgetIcon(String widgetId) {
    switch (widgetId) {
      case 'notices':
        return Icons.notifications;
      case 'homework':
        return Icons.assignment;
      case 'assessments':
        return Icons.assessment;
      case 'next_class':
        return Icons.schedule;
      default:
        return Icons.widgets;
    }
  }

  /// Get widget title
  static String getWidgetTitle(String widgetId) {
    switch (widgetId) {
      case 'notices':
        return 'Notices';
      case 'homework':
        return 'Homework';
      case 'assessments':
        return 'Assessments';
      case 'next_class':
        return 'Next Class';
      default:
        return widgetId;
    }
  }

  /// Check if widget can be resized (banner cannot be resized)
  static bool canResize(String widgetId) {
    return widgetId != 'banner';
  }

  /// Get the opposite size for a widget
  static Size getOppositeSize(Size currentSize) {
    return currentSize.width == 4 ? const Size(2, 1) : const Size(4, 1);
  }

  /// Get size label
  static String getSizeLabel(Size size) {
    return size.width == 4 ? 'Wide (4×1)' : 'Compact (2×1)';
  }

  /// Get opposite size label
  static String getOppositeSizeLabel(Size currentSize) {
    final opposite = getOppositeSize(currentSize);
    return getSizeLabel(opposite);
  }
}
