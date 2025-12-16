/// Data models for timetable API response
library;
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../shared/constants/period_constants.dart';
import 'course_merged_event.dart';

part 'course_timetable_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TimetableResponse {
  final String weekType;
  final int weekNum;
  final String monday;
  final int weekAPeriods;
  final int weekBPeriods;
  final int dutyPeriods;
  final int contractPeriods;
  final List<WeekDay> weekdays;

  TimetableResponse({
    required this.weekType,
    required this.weekNum,
    required this.monday,
    required this.weekAPeriods,
    required this.weekBPeriods,
    required this.dutyPeriods,
    required this.contractPeriods,
    required this.weekdays,
  });

  factory TimetableResponse.fromJson(Map<String, dynamic> json) =>
   _$TimetableResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TimetableResponseToJson(this);

  /// Get current and next class for today
  Map<String, CourseMergedEvent?> getCurrentAndNextClass() {
    if (weekdays.isEmpty) return {'current': null, 'next': null};

    final now = DateTime.now();
    final today = now.weekday - 1; // Convert to 0-based index (Monday = 0)

    // Only show for weekdays (Monday = 1 to Friday = 5)
    if (today < 0 || today >= 5) {
      return {'current': null, 'next': null};
    }

    final weekday = weekdays[today];
    final mergedEvents = CourseMergedEvent.mergeEventsForDay(weekday);

    CourseMergedEvent? currentClass;
    CourseMergedEvent? nextClass;

    for (final event in mergedEvents) {
      final startTime = _parseTime(
        PeriodConstants.getPeriodInfo(event.startPeriod)?.startTime ?? '',
      );
      final endTime = _parseTime(
        PeriodConstants.getPeriodInfo(event.endPeriod)?.endTime ?? '',
      );

      if (startTime == null || endTime == null) continue;

      final currentTime = _parseTime(
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      );
      if (currentTime == null) continue;

      if (_isTimeInRange(currentTime, startTime, endTime)) {
        // Currently in this class
        currentClass = event;
        break;
      } else if (_isTimeBefore(currentTime, startTime)) {
        // This is the next class
        nextClass = event;
        break;
      }
    }

    // If no current class and no next class found, look for next class in remaining events
    if (currentClass == null && nextClass == null) {
      for (final event in mergedEvents) {
        final startTime = _parseTime(
          PeriodConstants.getPeriodInfo(event.startPeriod)?.startTime ?? '',
        );
        final endTime = _parseTime(
          PeriodConstants.getPeriodInfo(event.endPeriod)?.endTime ?? '',
        );

        if (startTime != null && endTime != null) {
          final currentTime = _parseTime(
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          );
          if (currentTime != null && _isTimeBefore(currentTime, startTime)) {
            // Only show as next class if it hasn't started yet (future class)
            nextClass = event;
            break;
          }
        }
      }
    }

    return {'current': currentClass, 'next': nextClass};
  }

  /// Time utility methods
  static DateTime? _parseTime(String timeString) {
    try {
      return DateFormat('HH:mm').parse(timeString);
    } catch (e) {
      return null;
    }
  }

  static bool _isTimeInRange(DateTime time, DateTime start, DateTime end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return timeMinutes >= startMinutes && timeMinutes < endMinutes;
  }

  static bool _isTimeBefore(DateTime time, DateTime other) {
    final timeMinutes = time.hour * 60 + time.minute;
    final otherMinutes = other.hour * 60 + other.minute;
    return timeMinutes < otherMinutes;
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class WeekDay {
  final List<Period> periods;

  WeekDay({required this.periods});

  factory WeekDay.fromJson(Map<String, dynamic> json) =>
      _$WeekDayFromJson(json);
  Map<String, dynamic> toJson() => _$WeekDayToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Period {
  final List<TimetableEvent> events;

  Period({required this.events});

  factory Period.fromJson(Map<String, dynamic> json) =>
      _$PeriodFromJson(json);
  Map<String, dynamic> toJson() => _$PeriodToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TimetableEvent {
  final int type;
  final int id;
  final String name;
  final String room;
  final String teacher;
  final String weekType;
  final String newRoom;

  TimetableEvent({
    required this.type,
    required this.id,
    required this.name,
    required this.room,
    required this.teacher,
    required this.weekType,
    required this.newRoom,
  });

  factory TimetableEvent.fromJson(Map<String, dynamic> json) =>
      _$TimetableEventFromJson(json);
  Map<String, dynamic> toJson() => _$TimetableEventToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimetableEvent &&
        other.id == id &&
        other.name == name &&
        other.room == room &&
        other.teacher == teacher;
  }

  String get subject {
    if (name.contains('Form')) {
      return name;
    }
    if (name.contains('-')) {
      return name.split('-').first.trim();
    }
    return name;
  }

  String get code {
    if (name.contains('Form')) {
      return '';
    }
    if (name.contains('-')) {
      return name.split('-')[1].trim();
    }
    return 'ECA';
  }

  @override
  int get hashCode {
    return Object.hash(id, name, room, teacher);
  }
}
