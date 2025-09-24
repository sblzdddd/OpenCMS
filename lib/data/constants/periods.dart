/// Constants for timetable periods and their time spans
library;
import 'package:intl/intl.dart';

class PeriodConstants {
  static const List<PeriodInfo> periods = [
    PeriodInfo(name: 'Form Time', startTime: '07:50', endTime: '08:00'),
    PeriodInfo(name: 'Period 1',  startTime: '08:10', endTime: '08:50'),
    PeriodInfo(name: 'Period 2',  startTime: '08:50', endTime: '09:30'),
    PeriodInfo(name: 'Period 3',  startTime: '09:40', endTime: '10:20'),
    PeriodInfo(name: 'Period 4',  startTime: '10:20', endTime: '11:00'),
    PeriodInfo(name: 'Period 5',  startTime: '11:20', endTime: '12:00'),
    PeriodInfo(name: 'Period 6',  startTime: '12:00', endTime: '12:40'),
    PeriodInfo(name: 'Lunch',     startTime: '12:40', endTime: '13:10'),
    PeriodInfo(name: 'Pastoral',  startTime: '13:10', endTime: '13:30'),
    PeriodInfo(name: 'Period 7',  startTime: '13:40', endTime: '14:20'),
    PeriodInfo(name: 'Period 8',  startTime: '14:20', endTime: '15:00'),
    PeriodInfo(name: 'Period 9',  startTime: '15:10', endTime: '15:50'),
    PeriodInfo(name: 'Period 10', startTime: '15:50', endTime: '16:30'),
    PeriodInfo(name: 'Period 11', startTime: '16:30', endTime: '17:30'),
    PeriodInfo(name: 'Period 12', startTime: '17:30', endTime: '18:30'),
    PeriodInfo(name: 'Period 13', startTime: '19:00', endTime: '20:00'),
    PeriodInfo(name: 'Period 14', startTime: '20:00', endTime: '21:00'),
  ];

  static const List<PeriodInfo> attendancePeriods = [
    PeriodInfo(name: 'MR', startTime: '07:50', endTime: '08:00'),
    PeriodInfo(name: 'Period 1',  startTime: '08:10', endTime: '08:50'),
    PeriodInfo(name: 'Period 2',  startTime: '08:50', endTime: '09:30'),
    PeriodInfo(name: 'Period 3',  startTime: '09:40', endTime: '10:20'),
    PeriodInfo(name: 'Period 4',  startTime: '10:20', endTime: '11:00'),
    PeriodInfo(name: 'Period 5',  startTime: '11:20', endTime: '12:00'),
    PeriodInfo(name: 'Period 6',  startTime: '12:00', endTime: '12:40'),
    PeriodInfo(name: 'Pastoral',  startTime: '13:10', endTime: '13:30'),
    PeriodInfo(name: 'Period 7',  startTime: '13:40', endTime: '14:20'),
    PeriodInfo(name: 'Period 8',  startTime: '14:20', endTime: '15:00'),
    PeriodInfo(name: 'Period 9',  startTime: '15:10', endTime: '15:50'),
    PeriodInfo(name: 'Period 10', startTime: '15:50', endTime: '16:30'),
    PeriodInfo(name: 'ES', startTime: '16:30', endTime: '17:30'),
  ];


  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> weekdayNames = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> weekdayShortNames = [
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
    int periodIndex = periods.indexWhere((period) => time.isAfter(DateFormat.Hm().parse(period.startTime)) && time.isBefore(DateFormat.Hm().parse(period.endTime)));
    if (periodIndex != -1) {
      return periods[periodIndex];
    }
    periodIndex = attendancePeriods.indexWhere((period) => time.isAfter(DateFormat.Hm().parse(period.startTime)) && time.isBefore(DateFormat.Hm().parse(period.endTime)));
    if (periodIndex != -1) {
      return attendancePeriods[periodIndex];
    }
    return null;
  }

  static String getGreeting(DateTime dt) {
    int hour = dt.hour;

    if (hour >= 5 && hour < 8) {
      return "Rise and shine 🌅";
    } else if (hour >= 8 && hour < 12) {
      return "Good morning ☀️";
    } else if (hour >= 12 && hour < 14) {
      return "Good noon 🌞";
    } else if (hour >= 14 && hour < 17) {
      return "Good afternoon 🌤️";
    } else if (hour >= 17 && hour < 19) {
      return "Good evening 🌇";
    } else if (hour >= 19 && hour < 21) {
      return "Good evening 🌆";
    } else if (hour >= 21 && hour < 23) {
      return "Good night 🌙";
    } else if (hour >= 23 || hour < 5) {
      return "Sweet dreams 😴";
    } else {
      return "Hello 👋"; // fallback
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
    for (int year = 2025; year >= 2019; year--) {
      years.add(AcademicYear(
        year: year,
        displayName: '$year-${year + 1}',
      ));
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

  const AcademicYear({
    required this.year,
    required this.displayName,
  });

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
