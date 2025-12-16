import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Manages widget sizes and layout for the dashboard grid
class WidgetSizeManager {
  // Available widgets that can be added (excluding banner)
  static const List<String> availableWidgets = <String>[
    'banner',
    'notices',
    'homework',
    'assessments',
    'next_class',
    'calendar',
  ];

  // Available sizes for each widget type
  static const Map<String, List<Size>> availableSizes = <String, List<Size>>{
    'notices': [
      Size(2, 1), // Compact
      Size(4, 1), // Wide
      Size(4, 1.6), // Extra Wide
    ],
    'homework': [
      Size(2, 1), // Compact
      Size(4, 1), // Wide
    ],
    'assessments': [
      Size(2, 1), // Compact
      Size(4, 1), // Wide
    ],
    'banner': [
      Size(4, 1.6), // Fixed size
    ],
    'next_class': [
      Size(2, 1), // Compact
      Size(4, 1), // Wide
    ],
    'calendar': [
      Size(2, 1), // Compact
      Size(4, 1), // Wide
      Size(4, 1.6), // Extra Wide
    ],
  };

  // Default span definitions in grid units (max 4 columns)
  static const Map<String, Size> defaultSpans = <String, Size>{
    'notices': Size(2, 1),
    'homework': Size(2, 1),
    'assessments': Size(2, 1),
    'banner': Size(4, 1.6),
    'next_class': Size(2, 1),
    'calendar': Size(2, 1),
  };

  // Default layout
  static const List<MapEntry<String, Size>> defaultLayout =
      <MapEntry<String, Size>>[
        MapEntry('banner', Size(4, 1.6)),
        MapEntry('homework', Size(2, 1)),
        MapEntry('assessments', Size(2, 1)),
        MapEntry('next_class', Size(4, 1)),
      ];

  /// Get available widgets that can be added
  static List<String> getAddableWidgets(
    List<MapEntry<String, Size>> currentWidgets,
  ) {
    final List<String> currentWidgetIds = currentWidgets
        .map((e) => e.key)
        .toList();
    return availableWidgets
        .where((widget) => !currentWidgetIds.contains(widget))
        .toList();
  }

  /// Get current spans from widget order
  static Map<String, Size> getCurrentSpans(
    List<MapEntry<String, Size>> widgetOrder,
  ) {
    final Map<String, Size> spans = <String, Size>{};
    for (final entry in widgetOrder) {
      spans[entry.key] = entry.value;
    }
    return spans;
  }

  /// Get widget icon
  static IconData getWidgetIcon(String widgetId) {
    switch (widgetId) {
      case 'notices':
        return Symbols.notifications_rounded;
      case 'homework':
        return Symbols.assignment_rounded;
      case 'assessments':
        return Symbols.assessment_rounded;
      case 'next_class':
        return Symbols.schedule_rounded;
      case 'calendar':
        return Symbols.calendar_today_rounded;
      default:
        return Symbols.widgets_rounded;
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
      case 'calendar':
        return 'Calendar';
      default:
        return widgetId;
    }
  }

  static IconData getSizeIcon(Size size) {
    switch (size) {
      case const Size(4, 1.6):
        return Symbols.speed_2x_rounded;
      case const Size(4, 1):
        return Symbols.speed_1_5x_rounded;
      case const Size(2, 1):
        return Symbols.one_x_mobiledata_rounded;
      default:
        return Symbols.crop_square_rounded;
    }
  }

  /// Check if widget can be resized (banner cannot be resized)
  static bool canResize(String widgetId) {
    return widgetId != 'banner';
  }

  /// Get all available sizes for a widget
  static List<Size> getAvailableSizes(String widgetId) {
    return availableSizes[widgetId] ?? [const Size(2, 1)];
  }

  /// Get the next size in the cycle for a widget
  static Size getNextSize(String widgetId, Size currentSize) {
    final sizes = getAvailableSizes(widgetId);
    if (sizes.length <= 1) return currentSize;

    final currentIndex = sizes.indexWhere(
      (size) =>
          size.width == currentSize.width && size.height == currentSize.height,
    );

    if (currentIndex == -1) return sizes.first;

    final nextIndex = (currentIndex + 1) % sizes.length;
    return sizes[nextIndex];
  }

  /// Get all available sizes except the current one
  static List<Size> getAlternativeSizes(String widgetId, Size currentSize) {
    final sizes = getAvailableSizes(widgetId);
    return sizes
        .where(
          (size) =>
              !(size.width == currentSize.width &&
                  size.height == currentSize.height),
        )
        .toList();
  }

  /// Check if a size is valid for a widget
  static bool isValidSize(String widgetId, Size size) {
    final sizes = getAvailableSizes(widgetId);
    return sizes.any((s) => s.width == size.width && s.height == size.height);
  }

  /// Get size label
  static String getSizeLabel(Size size) {
    return '${size.width.toInt()}×${size.height}';
  }

  /// Get next size label
  static String getNextSizeLabel(String widgetId, Size currentSize) {
    final nextSize = getNextSize(widgetId, currentSize);
    return getSizeLabel(nextSize);
  }

  /// Get size description for UI
  static String getSizeDescription(Size size) {
    if (size.width == 4 && size.height == 1.6) {
      return 'Extra wide format with more content';
    } else if (size.width == 4 && size.height == 1) {
      return 'Wide format for better visibility';
    } else if (size.width == 2 && size.height == 1) {
      return 'Compact format to save space';
    } else {
      return 'Custom size';
    }
  }
}
