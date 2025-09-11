/// Data models for calendar API response
library;

class CalendarResponse {
  final int rows;
  final int days;
  final String userType;
  final String psid;
  final String thisMonth;
  final String thisYear;
  final String preMonth;
  final String preYear;
  final String nextMonth;
  final String nextYear;
  final String fromPeriod;
  final String? todaySpanId;
  final Map<String, CalendarDay> calendarDays;

  CalendarResponse({
    required this.rows,
    required this.days,
    required this.userType,
    required this.psid,
    required this.thisMonth,
    required this.thisYear,
    required this.preMonth,
    required this.preYear,
    required this.nextMonth,
    required this.nextYear,
    required this.fromPeriod,
    this.todaySpanId,
    required this.calendarDays,
  });

  factory CalendarResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, CalendarDay> calendarDays = {};
    
    // Parse calendar days from the response
    for (final key in json.keys) {
      if (key.startsWith('td') && key.endsWith('kind')) {
        final dayKey = key.substring(2, key.length - 4); // Remove 'td' prefix and 'kind' suffix
        final dateKey = '${dayKey}date';
        final dayKeyStr = '${dayKey}day';
        final contentKey = dayKey;
        
        if (json.containsKey(dateKey) && json.containsKey(dayKeyStr)) {
          final date = json[dateKey]?.toString() ?? '';
          final day = json[dayKeyStr]?.toString() ?? '';
          final content = json[contentKey]?.toString() ?? '';
          final kind = json[key]?.toString() ?? '';
          
          if (date.isNotEmpty) {
            calendarDays[dayKey] = CalendarDay(
              dayKey: dayKey,
              date: date,
              day: day,
              content: content,
              kind: kind,
              events: _parseEvents(content),
            );
          }
        }
      }
    }

    return CalendarResponse(
      rows: (json['rows'] as num?)?.toInt() ?? 0,
      days: (json['days'] as num?)?.toInt() ?? 0,
      userType: json['usertype']?.toString() ?? '',
      psid: json['psid']?.toString() ?? '',
      thisMonth: json['thismonth']?.toString() ?? '',
      thisYear: json['thisyear']?.toString() ?? '',
      preMonth: json['premonth']?.toString() ?? '',
      preYear: json['preyear']?.toString() ?? '',
      nextMonth: json['nextmonth']?.toString() ?? '',
      nextYear: json['nextyear']?.toString() ?? '',
      fromPeriod: json['fromperiod']?.toString() ?? '',
      todaySpanId: json['todayspanid']?.toString(),
      calendarDays: calendarDays,
    );
  }

  static List<CalendarEvent> _parseEvents(String content) {
    if (content.isEmpty || content.trim() == ' || || || ') {
      return [];
    }

    final List<CalendarEvent> events = [];
    final eventStrings = content.split(' || ');
    
    for (final eventString in eventStrings) {
      if (eventString.trim().isEmpty) continue;
      
      final parts = eventString.split('|');
      if (parts.length >= 6) {
        events.add(CalendarEvent(
          id: parts[0],
          ctype: parts[1],
          title: parts[2],
          kind: parts[3],
          cat: parts[4],
          postponeStatus: parts[5],
        ));
      }
    }
    
    return events;
  }
}

class CalendarDay {
  final String dayKey;
  final String date;
  final String day;
  final String content;
  final String kind;
  final List<CalendarEvent> events;

  CalendarDay({
    required this.dayKey,
    required this.date,
    required this.day,
    required this.content,
    required this.kind,
    required this.events,
  });

  /// Check if this is a current month day
  bool get isCurrentMonth => day != '0';
  
  /// Check if this day has events
  bool get hasEvents => events.isNotEmpty;
  
  /// Get formatted date
  DateTime? get dateTime {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }
}

class CalendarEvent {
  final String id;
  final String ctype;
  final String title;
  final String kind;
  final String cat;
  final String postponeStatus;

  CalendarEvent({
    required this.id,
    required this.ctype,
    required this.title,
    required this.kind,
    required this.cat,
    required this.postponeStatus,
  });

  /// Check if this event is postponed
  bool get isPostponed => postponeStatus == '1';
  
  /// Get event type description
  String get eventType {
    switch (kind) {
      case 'calendar':
        return 'Calendar Event';
      case 'fieldtrip':
        return 'Field Trip';
      case 'fixture':
        return 'Fixture';
      case 'visit_event':
        return 'Visit Event';
      case 'sl_event':
        return 'Student-Led Event';
      case 'su_event':
        return 'Student Unstaffed Event';
      case 'examtimetable':
        return 'Exam';
      default:
        return 'Unknown';
    }
  }
  
  /// Get category color class
  String get colorClass {
    if (kind == 'calendar') {
      return 'cal_color_$cat';
    } else if (kind == 'examtimetable') {
      return 'cal_color_$kind';
    } else if (kind == 'fieldtrip' || kind == 'fixture' || kind == 'visit_event') {
      return 'cal_color_4';
    } else if (kind == 'sl_event' || kind == 'su_event') {
      return 'cal_color_4_sl';
    }
    return 'cal_color_none';
  }
}
