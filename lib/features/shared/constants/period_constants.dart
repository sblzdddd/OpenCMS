/// Constants for timetable periods and their time spans
library;

import 'package:easy_localization/easy_localization.dart';

class PeriodConstants {
  static List<PeriodInfo> get periods => [
    PeriodInfo(
      name: 'periods.formTime'.tr(),
      startTime: '07:50',
      endTime: '08:00',
    ),
    PeriodInfo(
      name: 'periods.period1'.tr(),
      startTime: '08:10',
      endTime: '08:50',
    ),
    PeriodInfo(
      name: 'periods.period2'.tr(),
      startTime: '08:50',
      endTime: '09:30',
    ),
    PeriodInfo(
      name: 'periods.period3'.tr(),
      startTime: '09:40',
      endTime: '10:20',
    ),
    PeriodInfo(
      name: 'periods.period4'.tr(),
      startTime: '10:20',
      endTime: '11:00',
    ),
    PeriodInfo(
      name: 'periods.period5'.tr(),
      startTime: '11:20',
      endTime: '12:00',
    ),
    PeriodInfo(
      name: 'periods.period6'.tr(),
      startTime: '12:00',
      endTime: '12:40',
    ),
    PeriodInfo(
      name: 'periods.lunch'.tr(),
      startTime: '12:40',
      endTime: '13:10',
    ),
    PeriodInfo(
      name: 'periods.pastoral'.tr(),
      startTime: '13:10',
      endTime: '13:30',
    ),
    PeriodInfo(
      name: 'periods.period7'.tr(),
      startTime: '13:40',
      endTime: '14:20',
    ),
    PeriodInfo(
      name: 'periods.period8'.tr(),
      startTime: '14:20',
      endTime: '15:00',
    ),
    PeriodInfo(
      name: 'periods.period9'.tr(),
      startTime: '15:10',
      endTime: '15:50',
    ),
    PeriodInfo(
      name: 'periods.period10'.tr(),
      startTime: '15:50',
      endTime: '16:30',
    ),
    PeriodInfo(
      name: 'periods.period11'.tr(),
      startTime: '16:30',
      endTime: '17:30',
    ),
    PeriodInfo(
      name: 'periods.period12'.tr(),
      startTime: '17:30',
      endTime: '18:30',
    ),
    PeriodInfo(
      name: 'periods.period13'.tr(),
      startTime: '19:00',
      endTime: '20:00',
    ),
    PeriodInfo(
      name: 'periods.period14'.tr(),
      startTime: '20:00',
      endTime: '21:00',
    ),
  ];

  static List<PeriodInfo> get attendancePeriods => [
    PeriodInfo(name: 'periods.mr'.tr(), startTime: '07:50', endTime: '08:00'),
    PeriodInfo(
      name: 'periods.period1'.tr(),
      startTime: '08:10',
      endTime: '08:50',
    ),
    PeriodInfo(
      name: 'periods.period2'.tr(),
      startTime: '08:50',
      endTime: '09:30',
    ),
    PeriodInfo(
      name: 'periods.period3'.tr(),
      startTime: '09:40',
      endTime: '10:20',
    ),
    PeriodInfo(
      name: 'periods.period4'.tr(),
      startTime: '10:20',
      endTime: '11:00',
    ),
    PeriodInfo(
      name: 'periods.period5'.tr(),
      startTime: '11:20',
      endTime: '12:00',
    ),
    PeriodInfo(
      name: 'periods.period6'.tr(),
      startTime: '12:00',
      endTime: '12:40',
    ),
    PeriodInfo(
      name: 'periods.pastoral'.tr(),
      startTime: '13:10',
      endTime: '13:30',
    ),
    PeriodInfo(
      name: 'periods.period7'.tr(),
      startTime: '13:40',
      endTime: '14:20',
    ),
    PeriodInfo(
      name: 'periods.period8'.tr(),
      startTime: '14:20',
      endTime: '15:00',
    ),
    PeriodInfo(
      name: 'periods.period9'.tr(),
      startTime: '15:10',
      endTime: '15:50',
    ),
    PeriodInfo(
      name: 'periods.period10'.tr(),
      startTime: '15:50',
      endTime: '16:30',
    ),
    PeriodInfo(name: 'periods.es'.tr(), startTime: '16:30', endTime: '17:30'),
  ];

  /// Special periods that always exist in the timetable
  static List<PeriodInfo> get specialPeriods => [
    PeriodInfo(
      name: 'periods.formTime'.tr(),
      startTime: '07:50',
      endTime: '08:00',
    ),
    PeriodInfo(
      name: 'periods.lunch'.tr(),
      startTime: '12:40',
      endTime: '13:10',
    ),
    PeriodInfo(
      name: 'periods.pastoral'.tr(),
      startTime: '13:10',
      endTime: '13:30',
    ),
  ];

  static List<String> get monthNames => [
    'months.january'.tr(),
    'months.february'.tr(),
    'months.march'.tr(),
    'months.april'.tr(),
    'months.may'.tr(),
    'months.june'.tr(),
    'months.july'.tr(),
    'months.august'.tr(),
    'months.september'.tr(),
    'months.october'.tr(),
    'months.november'.tr(),
    'months.december'.tr(),
  ];

  static List<String> get weekdayNames => [
    'weekdays.monday'.tr(),
    'weekdays.tuesday'.tr(),
    'weekdays.wednesday'.tr(),
    'weekdays.thursday'.tr(),
    'weekdays.friday'.tr(),
    'weekdays.saturday'.tr(),
    'weekdays.sunday'.tr(),
  ];

  static List<String> get weekdayShortNames => [
    'weekdays.mon'.tr(),
    'weekdays.tue'.tr(),
    'weekdays.wed'.tr(),
    'weekdays.thu'.tr(),
    'weekdays.fri'.tr(),
    'weekdays.sat'.tr(),
    'weekdays.sun'.tr(),
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
      return 'greetings.riseAndShine'.tr();
    } else if (hour >= 8 && hour < 12) {
      return 'greetings.goodMorning'.tr();
    } else if (hour >= 12 && hour < 14) {
      return 'greetings.goodNoon'.tr();
    } else if (hour >= 14 && hour < 17) {
      return 'greetings.goodAfternoon'.tr();
    } else if (hour >= 17 && hour < 19) {
      return 'greetings.goodEveningEarly'.tr();
    } else if (hour >= 19 && hour < 21) {
      return 'greetings.goodEveningLate'.tr();
    } else if (hour >= 21 && hour < 23) {
      return 'greetings.goodNight'.tr();
    } else if (hour >= 23 || hour < 5) {
      return 'greetings.sweetDreams'.tr();
    } else {
      return 'greetings.hello'.tr(); // fallback
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
    for (int year = DateTime.now().year; year >= 2019; year--) {
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
