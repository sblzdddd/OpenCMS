import 'timetable_response.dart';
import '../../constants/period_constants.dart';

/// Represents a timetable event that may span multiple consecutive periods
class CourseMergedEvent {
  final TimetableEvent event;
  final int startPeriod;
  final int endPeriod;

  CourseMergedEvent({
    required this.event,
    required this.startPeriod,
    required this.endPeriod,
  });

  /// Get the time span for this merged event
  String get timeSpan {
    return PeriodConstants.getTimeSpan(startPeriod, endPeriod);
  }

  /// Get the start period name
  String get startPeriodName {
    final periodInfo = PeriodConstants.getPeriodInfo(startPeriod);
    return periodInfo?.name ?? 'Period ${startPeriod + 1}';
  }

  /// Get the end period name
  String get endPeriodName {
    if (!(startPeriod == 0 || startPeriod == 7 || startPeriod == 8)) {
      return (endPeriod > 8? endPeriod-2: endPeriod).toString();
    }
    final periodInfo = PeriodConstants.getPeriodInfo(endPeriod);
    return periodInfo?.name ?? 'Period ${endPeriod + 1}';
  }

  String get periodText {
    if (isMultiPeriod) {
      return '$startPeriodName - $endPeriodName';
    }
    return startPeriodName;
  }

  /// Check if this event spans multiple periods
  bool get isMultiPeriod => endPeriod > startPeriod;

  /// Get period count
  int get periodCount => endPeriod - startPeriod + 1;
}
