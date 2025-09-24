/// Data models for timetable API response
library;

import 'package:intl/intl.dart';
import '../../constants/periods.dart';
import 'course_merged_event.dart';

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

  factory TimetableResponse.fromJson(Map<String, dynamic> json) {
    return TimetableResponse(
      weekType: json['week_type'] ?? '',
      weekNum: json['week_num'] ?? 0,
      monday: json['monday'] ?? '',
      weekAPeriods: json['week_a_periods'] ?? 0,
      weekBPeriods: json['week_b_periods'] ?? 0,
      dutyPeriods: json['duty_periods'] ?? 0,
      contractPeriods: json['contract_periods'] ?? 0,
      weekdays: (json['weekdays'] as List<dynamic>?)
          ?.map((item) => WeekDay.fromJson(item))
          .toList() ?? [],
    );
  }

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
      final startTime = _parseTime(PeriodConstants.getPeriodInfo(event.startPeriod)?.startTime ?? '');
      final endTime = _parseTime(PeriodConstants.getPeriodInfo(event.endPeriod)?.endTime ?? '');
      
      if (startTime == null || endTime == null) continue;
      
      final currentTime = _parseTime('${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
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
        final startTime = _parseTime(PeriodConstants.getPeriodInfo(event.startPeriod)?.startTime ?? '');
        final endTime = _parseTime(PeriodConstants.getPeriodInfo(event.endPeriod)?.endTime ?? '');
        
        if (startTime != null && endTime != null) {
          final currentTime = _parseTime('${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
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

class WeekDay {
  final List<Period> periods;

  WeekDay({required this.periods});

  factory WeekDay.fromJson(Map<String, dynamic> json) {
    return WeekDay(
      periods: (json['periods'] as List<dynamic>?)
          ?.map((item) => Period.fromJson(item))
          .toList() ?? [],
    );
  }
}

class Period {
  final List<TimetableEvent> events;

  Period({required this.events});

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      events: (json['events'] as List<dynamic>?)
          ?.map((item) => TimetableEvent.fromJson(item))
          .toList() ?? [],
    );
  }
}

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

  factory TimetableEvent.fromJson(Map<String, dynamic> json) {
    return TimetableEvent(
      type: json['type'] ?? 0,
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      room: json['room'] ?? '',
      teacher: json['teacher'] ?? '',
      weekType: json['week_type'] ?? '',
      newRoom: json['new_room'] ?? '',
    );
  }

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
    if (name.contains('-')) {
      return name.split('-').first.trim();
    }
    return name;
  }

  String get code {
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
