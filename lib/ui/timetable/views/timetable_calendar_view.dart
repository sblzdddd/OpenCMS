import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../data/constants/period_constants.dart';
import '../../../data/models/timetable/timetable_response.dart';

class TimetableCalendarView extends StatefulWidget {
  final List<DateTime> dayDates;
  final TimetableResponse? timetableData;
  final void Function(TimetableEvent) onEventTap;

  const TimetableCalendarView({
    super.key,
    required this.dayDates,
    required this.timetableData,
    required this.onEventTap,
  });

  @override
  State<TimetableCalendarView> createState() => _TimetableCalendarViewState();
}

class _TimetableCalendarViewState extends State<TimetableCalendarView> {
  @override
  Widget build(BuildContext context) {
    final Courses = _buildCourses();

    final DateTime? minDate = widget.dayDates.isEmpty
        ? null
        : DateTime(
            widget.dayDates.first.year,
            widget.dayDates.first.month,
            widget.dayDates.first.day,
          );
    final DateTime? maxDate = widget.dayDates.isEmpty
        ? null
        : DateTime(
            widget.dayDates.last.year,
            widget.dayDates.last.month,
            widget.dayDates.last.day,
            23,
            59,
          );

    return SfCalendar(
      view: CalendarView.workWeek,
      firstDayOfWeek: 1,
      minDate: minDate,
      maxDate: maxDate,
      dataSource: _CourseDataSource(Courses),
      timeSlotViewSettings: const TimeSlotViewSettings(
        startHour: 7.5, // 07:30
        endHour: 18.5, // 18:30
        nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday],
      ),
      onTap: (details) {
        if (details.targetElement == CalendarElement.appointment &&
            details.appointments != null &&
            details.appointments!.isNotEmpty) {
          final Course tapped = details.appointments!.first as Course;
          widget.onEventTap(tapped.sourceEvent);
        }
      },
    );
  }

  List<Course> _buildCourses() {
    final List<Course> Courses = <Course>[];
    final data = widget.timetableData;
    if (data == null) return Courses;

    for (int dayIndex = 0; dayIndex < data.weekdays.length && dayIndex < 7; dayIndex++) {
      final weekDay = data.weekdays[dayIndex];
      final DateTime? date = _resolveDateForDayIndex(dayIndex);
      if (date == null) continue;

      int i = 0;
      while (i < weekDay.periods.length) {
        final period = weekDay.periods[i];
        if (period.events.isEmpty) {
          i++;
          continue;
        }
        final TimetableEvent event = period.events.first;
        int endPeriod = i;
        while (endPeriod + 1 < weekDay.periods.length) {
          final next = weekDay.periods[endPeriod + 1];
          if (next.events.isEmpty || next.events.first != event) break;
          endPeriod++;
        }

        final startInfo = PeriodConstants.getPeriodInfo(i);
        final endInfo = PeriodConstants.getPeriodInfo(endPeriod);
        if (startInfo != null && endInfo != null) {
          final DateTime start = _combine(date, startInfo.startTime);
          final DateTime end = _combine(date, endInfo.endTime);
          final Color color = _colorForEvent(event, dayIndex);
          Courses.add(
            Course(
              subject: event.subject,
              location: event.room.isNotEmpty ? event.room : (event.newRoom.isNotEmpty ? event.newRoom : 'TBA'),
              from: start,
              to: end,
              color: color,
              isAllDay: false,
              sourceEvent: event,
              note: event.teacher,
            ),
          );
        }

        i = endPeriod + 1;
      }
    }

    return Courses;
  }

  DateTime? _resolveDateForDayIndex(int index) {
    if (widget.dayDates.isNotEmpty && index < widget.dayDates.length) {
      return widget.dayDates[index];
    }
    // Fallback: try to parse monday from API and add days
    final mondayStr = widget.timetableData?.monday;
    if (mondayStr == null || mondayStr.isEmpty) return null;
    final parts = mondayStr.split('-');
    if (parts.length != 3) return null;
    final int? y = int.tryParse(parts[0]);
    final int? m = int.tryParse(parts[1]);
    final int? d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d).add(Duration(days: index));
  }

  DateTime _combine(DateTime date, String hhmm) {
    final segs = hhmm.split(':');
    int hh = int.parse(segs[0]);
    int mm = int.parse(segs[1]);
    return DateTime(date.year, date.month, date.day, hh, mm);
  }

  Color _colorForEvent(TimetableEvent event, int dayIndex) {
    // Simple deterministic color by day and event id
    final List<Color> palette = <Color>[
      Colors.blue,
      Colors.green,
      Colors.deepPurple,
      Colors.teal,
      Colors.indigo,
      Colors.orange,
      Colors.pink,
    ];
    final int hash = event.id.hashCode ^ event.name.hashCode ^ dayIndex.hashCode;
    return palette[hash.abs() % palette.length].withOpacity(0.9);
  }
}

class Course {
  final String subject;
  final String location;
  final DateTime from;
  final DateTime to;
  final Color color;
  final bool isAllDay;
  final TimetableEvent sourceEvent;
  final String note;

  Course({
    required this.subject,
    required this.location,
    required this.from,
    required this.to,
    required this.color,
    required this.isAllDay,
    required this.sourceEvent,
    required this.note,
  });
}

class _CourseDataSource extends CalendarDataSource {
  _CourseDataSource(List<Course> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].from as DateTime;

  @override
  DateTime getEndTime(int index) => appointments![index].to as DateTime;

  @override
  String getSubject(int index) => appointments![index].subject as String;

  @override
  String? getLocation(int index) => appointments![index].location as String;

  @override
  Color getColor(int index) => appointments![index].color as Color;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay as bool;

  @override
  String? getNotes(int index) => appointments![index].note as String;
}


