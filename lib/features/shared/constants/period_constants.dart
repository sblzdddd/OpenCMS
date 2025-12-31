/// Constants for timetable periods and their time spans
library;

import 'package:intl/intl.dart';


class PeriodConstants {
  static List<PeriodInfo> get periods => [
    PeriodInfo(
      name: 'Form Time',
      startTime: '07:50',
      endTime: '08:00',
    ),
    PeriodInfo(
      name: 'Period 1',
      startTime: '08:10',
      endTime: '08:50',
    ),
    PeriodInfo(
      name: 'Period 2',
      startTime: '08:50',
      endTime: '09:30',
    ),
    PeriodInfo(
      name: 'Period 3',
      startTime: '09:40',
      endTime: '10:20',
    ),
    PeriodInfo(
      name: 'Period 4',
      startTime: '10:20',
      endTime: '11:00',
    ),
    PeriodInfo(
      name: 'Period 5',
      startTime: '11:20',
      endTime: '12:00',
    ),
    PeriodInfo(
      name: 'Period 6',
      startTime: '12:00',
      endTime: '12:40',
    ),
    PeriodInfo(
      name: 'Lunch',
      startTime: '12:40',
      endTime: '13:10',
    ),
    PeriodInfo(
      name: 'Pastoral',
      startTime: '13:10',
      endTime: '13:30',
    ),
    PeriodInfo(
      name: 'Period 7',
      startTime: '13:40',
      endTime: '14:20',
    ),
    PeriodInfo(
      name: 'Period 8',
      startTime: '14:20',
      endTime: '15:00',
    ),
    PeriodInfo(
      name: 'Period 9',
      startTime: '15:10',
      endTime: '15:50',
    ),
    PeriodInfo(
      name: 'Period 10',
      startTime: '15:50',
      endTime: '16:30',
    ),
    PeriodInfo(
      name: 'Period 11',
      startTime: '16:30',
      endTime: '17:30',
    ),
    PeriodInfo(
      name: 'Period 12',
      startTime: '17:30',
      endTime: '18:30',
    ),
    PeriodInfo(
      name: 'Period 13',
      startTime: '19:00',
      endTime: '20:00',
    ),
    PeriodInfo(
      name: 'Period 14',
      startTime: '20:00',
      endTime: '21:00',
    ),
  ];

  static List<PeriodInfo> get attendancePeriods => [
    PeriodInfo(name: 'MR', startTime: '07:50', endTime: '08:00'),
    PeriodInfo(
      name: 'Period 1',
      startTime: '08:10',
      endTime: '08:50',
    ),
    PeriodInfo(
      name: 'Period 2',
      startTime: '08:50',
      endTime: '09:30',
    ),
    PeriodInfo(
      name: 'Period 3',
      startTime: '09:40',
      endTime: '10:20',
    ),
    PeriodInfo(
      name: 'Period 4',
      startTime: '10:20',
      endTime: '11:00',
    ),
    PeriodInfo(
      name: 'Period 5',
      startTime: '11:20',
      endTime: '12:00',
    ),
    PeriodInfo(
      name: 'Period 6',
      startTime: '12:00',
      endTime: '12:40',
    ),
    PeriodInfo(
      name: 'Pastoral',
      startTime: '13:10',
      endTime: '13:30',
    ),
    PeriodInfo(
      name: 'Period 7',
      startTime: '13:40',
      endTime: '14:20',
    ),
    PeriodInfo(
      name: 'Period 8',
      startTime: '14:20',
      endTime: '15:00',
    ),
    PeriodInfo(
      name: 'Period 9',
      startTime: '15:10',
      endTime: '15:50',
    ),
    PeriodInfo(
      name: 'Period 10',
      startTime: '15:50',
      endTime: '16:30',
    ),
    PeriodInfo(name: 'ES', startTime: '16:30', endTime: '17:30'),
  ];

  /// Special periods that always exist in the timetable
  static List<PeriodInfo> get specialPeriods => [
    PeriodInfo(
      name: 'periods.formTime',
      startTime: '07:50',
      endTime: '08:00',
    ),
    PeriodInfo(
      name: 'periods.lunch',
      startTime: '12:40',
      endTime: '13:10',
    ),
    PeriodInfo(
      name: 'periods.pastoral',
      startTime: '13:10',
      endTime: '13:30',
    ),
  ];

  static List<String> get monthNames => [
    'months.january',
    'months.february',
    'months.march',
    'months.april',
    'months.may',
    'months.june',
    'months.july',
    'months.august',
    'months.september',
    'months.october',
    'months.november',
    'months.december',
  ];

  static List<String> get weekdayNames => [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static List<String> get weekdayShortNames => [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static String formatDate(DateTime date) {
    final weekday = weekdayNames[date.weekday - 1];
    final month = monthNames[date.month - 1];
    return '$weekday, $month ${date.day}, ${date.year}';
  }

  static PeriodInfo? getPeriodInfoByTime(DateTime time) {
    final timeFormat = DateFormat.Hm();
    int periodIndex = periods.indexWhere(
      (period) =>
          time.isAfter(timeFormat.parse(period.startTime)) &&
          time.isBefore(timeFormat.parse(period.endTime)),
    );
    if (periodIndex != -1) {
      return periods[periodIndex];
    }
    periodIndex = attendancePeriods.indexWhere(
      (period) =>
          time.isAfter(timeFormat.parse(period.startTime)) &&
          time.isBefore(timeFormat.parse(period.endTime)),
    );
    if (periodIndex != -1) {
      return attendancePeriods[periodIndex];
    }
    return null;
  }

  static String getGreeting(DateTime dt) {
    int hour = dt.hour;

    if (hour >= 5 && hour < 8) {
      return 'Rise And Shine';
    } else if (hour >= 8 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 14) {
      return 'Good Noon';
    } else if (hour >= 14 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 19) {
      return 'Good Early Evening';
    } else if (hour >= 19 && hour < 21) {
      return 'Good Late Evening';
    } else if (hour >= 21 && hour < 23) {
      return 'Good Night';
    } else if (hour >= 23 || hour < 5) {
      return 'Sweet Dreams';
    } else {
      return 'Hello'; // fallback
    }
  }

  /// Check if a period name is a special period
  static bool isSpecialPeriod(String periodName) {
    return specialPeriods.any((period) => period.name == periodName);
  }

  /// Get all special period names
  static List<String> getSpecialPeriodNames() {
    return specialPeriods.map((period) => period.name).toList();
  }

  /// Get special period info by name
  static PeriodInfo? getSpecialPeriod(String periodName) {
    try {
      return specialPeriods.firstWhere((period) => period.name == periodName);
    } catch (e) {
      return null;
    }
  }

  /// Get period info by index
  static PeriodInfo? getPeriodInfo(int index) {
    if (index >= 0 && index < periods.length) {
      return periods[index];
    }
    return null;
  }

  /// Generate time span for merged periods
  static String getTimeSpan(int startPeriod, int endPeriod) {
    final startInfo = getPeriodInfo(startPeriod);
    final endInfo = getPeriodInfo(endPeriod);

    if (startInfo == null || endInfo == null) {
      return '';
    }

    return '${startInfo.startTime} - ${endInfo.endTime}';
  }

  /// Generate academic years from 2019-2020 to 2025-2026
  static List<AcademicYear> getAcademicYears() {
    final List<AcademicYear> years = [];
    final now = DateTime.now();
    final startYear = now.month < 8 ? now.year - 1 : now.year;

    for (int year = startYear; year >= 2019; year--) {
      years.add(
        AcademicYear(
          year: year,
          displayName: '$year-${(year + 1).toString().substring(2)}',
        ),
      );
    }
    return years;
  }
}

class PeriodInfo {
  final String name;
  final String startTime;
  final String endTime;

  const PeriodInfo({
    // required this.index,
    required this.name,
    required this.startTime,
    required this.endTime,
  });
}

class AcademicYear {
  final int year;
  final String displayName;

  const AcademicYear({required this.year, required this.displayName});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AcademicYear &&
        other.year == year &&
        other.displayName == displayName;
  }

  @override
  int get hashCode => Object.hash(year, displayName);

  @override
  String toString() => 'AcademicYear(year: $year, displayName: $displayName)';
}
