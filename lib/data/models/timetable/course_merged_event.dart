import 'timetable_response.dart';
import '../../constants/period_constants.dart';
import 'package:intl/intl.dart';

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

  /// Static method to merge consecutive periods with the same event for a given day
  static List<CourseMergedEvent> mergeEventsForDay(WeekDay weekday) {
    final List<CourseMergedEvent> mergedEvents = [];
    
    int i = 0;
    while (i < weekday.periods.length) {
      final period = weekday.periods[i];
      
      if (period.events.isEmpty) {
        i++;
        continue;
      }

      final event = period.events.first;
      int endPeriod = i;
      
      // Find consecutive periods with the same event
      while (endPeriod + 1 < weekday.periods.length) {
        final nextPeriod = weekday.periods[endPeriod + 1];
        if (nextPeriod.events.isEmpty || 
            nextPeriod.events.first != event) {
          break;
        }
        endPeriod++;
      }

      mergedEvents.add(CourseMergedEvent(
        event: event,
        startPeriod: i,
        endPeriod: endPeriod,
      ));

      i = endPeriod + 1;
    }

    return mergedEvents;
  }

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

  /// Calculate the progress of the current class (0.0 to 1.0)
  double getClassProgress() {
    final now = DateTime.now();
    final startTime = _parseTime(PeriodConstants.getPeriodInfo(startPeriod)?.startTime ?? '');
    final endTime = _parseTime(PeriodConstants.getPeriodInfo(endPeriod)?.endTime ?? '');
    
    if (startTime == null || endTime == null) return 0.0;
    
    final currentTime = _parseTime('${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
    if (currentTime == null) return 0.0;
    
    final totalDuration = endTime.difference(startTime).inMinutes;
    final elapsedDuration = currentTime.difference(startTime).inMinutes;
    
    if (totalDuration <= 0) return 0.0;
    
    final progress = elapsedDuration / totalDuration;
    return progress.clamp(0.0, 1.0);
  }

  /// Get time until this class starts (e.g., "in 2h 30m" or "in 45m")
  String getTimeUntilClass() {
    final now = DateTime.now();
    final startTime = _parseTime(PeriodConstants.getPeriodInfo(startPeriod)?.startTime ?? '');
    
    if (startTime == null) return '';
    
    final classTime = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
    final difference = classTime.difference(now);
    
    if (difference.isNegative) return '';
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    if (hours > 0) {
      return 'in ${hours}h ${minutes}m';
    } else {
      return 'in ${minutes}m';
    }
  }

  /// Private time parsing method
  DateTime? _parseTime(String timeString) {
    try {
      return DateFormat('HH:mm').parse(timeString);
    } catch (e) {
      return null;
    }
  }
}
