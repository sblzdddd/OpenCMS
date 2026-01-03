library;

import 'package:json_annotation/json_annotation.dart';

part 'calendar_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CalendarResponse {
  final int rows;
  final int days;
  @JsonKey(name: 'usertype')
  final String userType;
  final String psid;
  @JsonKey(name: 'thismonth')
  final String thisMonth;
  @JsonKey(name: 'thisyear')
  final String thisYear;
  @JsonKey(name: 'premonth')
  final String preMonth;
  @JsonKey(name: 'preyear')
  final String preYear;
  @JsonKey(name: 'nextmonth')
  final String nextMonth;
  @JsonKey(name: 'nextyear')
  final String nextYear;
  @JsonKey(name: 'fromperiod')
  final int fromPeriod;
  @JsonKey(name: 'todayspanid')
  final String? todaySpanId;
  @JsonKey(includeFromJson: false)
  Map<String, CalendarDay> calendarDays;

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
    this.calendarDays = const {},
  });

  Map<String, dynamic> toJson() => _$CalendarResponseToJson(this);

  factory CalendarResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, CalendarDay> calendarDays = {};

    for (final key in json.keys) {
      if (!key.endsWith('date')) continue;

      final String base = key.substring(
        0,
        key.length - 4,
      ); // strip trailing 'date'
      final RegExp pageSuffixRegex = RegExp(r'_page_\d+$');
      final String root = base.replaceAll(pageSuffixRegex, ''); // e.g., Sat06
      final String? pageSuffix = pageSuffixRegex.hasMatch(base)
          ? pageSuffixRegex.firstMatch(base)!.group(0)
          : null; // e.g., _page_1

      final String date = json[key]?.toString() ?? '';
      if (date.isEmpty) continue;

      // Find day string. Try multiple key shapes observed in payloads
      final List<String> dayKeyCandidates = <String>[
        if (pageSuffix != null) '${root}day$pageSuffix', // Sat06day_page_1
        '${base}day', // Sat06_page_1day
        '${root}day', // Sat06day
      ];
      String day = '';
      for (final candidate in dayKeyCandidates) {
        if (json.containsKey(candidate)) {
          day = json[candidate]?.toString() ?? '';
          if (day.isNotEmpty) break;
        }
      }

      // Pick best available content: prefer unsuffixed root first, then base
      String content = '';
      if (json.containsKey(root)) {
        content = json[root]?.toString() ?? '';
      }
      if (content.isEmpty && json.containsKey(base)) {
        content = json[base]?.toString() ?? '';
      }

      // Kind may be under td<root>kind or td<base>kind
      String kind = '';
      final List<String> kindKeyCandidates = <String>[
        'td${root}kind',
        'td${base}kind',
      ];
      for (final candidate in kindKeyCandidates) {
        if (json.containsKey(candidate)) {
          kind = json[candidate]?.toString() ?? '';
          break;
        }
      }

      // Merge entries for the same root key (same calendar day) if seen multiple times
      final List<CalendarEvent> parsedEvents = _parseEvents(content);
      if (calendarDays.containsKey(root)) {
        final existing = calendarDays[root]!;
        final Map<String, CalendarEvent> mergedById = {
          for (final e in existing.events) e.id: e,
        };
        for (final e in parsedEvents) {
          mergedById[e.id] = e;
        }
        calendarDays[root] = CalendarDay(
          dayKey: existing.dayKey,
          date: existing.date.isNotEmpty ? existing.date : date,
          day: existing.day.isNotEmpty ? existing.day : day,
          content: existing.content.isNotEmpty ? existing.content : content,
          kind: existing.kind.isNotEmpty ? existing.kind : kind,
          events: mergedById.values.toList(),
        );
      } else {
        calendarDays[root] = CalendarDay(
          dayKey: root,
          date: date,
          day: day,
          content: content,
          kind: kind,
          events: parsedEvents,
        );
      }
    }

    final response = _$CalendarResponseFromJson(json);
    response.calendarDays = calendarDays;
    return response;
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
        events.add(
          CalendarEvent(
            id: parts[0],
            ctype: parts[1],
            title: parts[2],
            kind: parts[3],
            cat: parts[4],
            postponeStatus: parts[5],
          ),
        );
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

  bool get isCurrentMonth => day != '0';

  bool get hasEvents => events.isNotEmpty;

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
    } else if (kind == 'fieldtrip' ||
        kind == 'fixture' ||
        kind == 'visit_event') {
      return 'cal_color_4';
    } else if (kind == 'sl_event' || kind == 'su_event') {
      return 'cal_color_4_sl';
    }
    return 'cal_color_none';
  }
}
