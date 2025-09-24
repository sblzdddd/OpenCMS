import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/theme/theme_services.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../data/constants/periods.dart';
import '../../../data/models/timetable/timetable_response.dart';
import '../../../data/models/timetable/course_merged_event.dart';

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
  // Track unique courses and their assigned colors
  final Map<String, Color> _courseColors = {};
  int _nextColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final courses = _buildCourses();

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
      headerHeight: 0,
      dataSource: _CourseDataSource(courses),
      showCurrentTimeIndicator: true,
      timeSlotViewSettings: const TimeSlotViewSettings(
        startHour: 8, // 07:30
        endHour: 18, // 18:30
        nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday],
        timeIntervalHeight: 86,
        minimumAppointmentDuration: Duration(minutes: 30),
      ),
      specialRegions: _getTimeRegions(),
      appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
        final Course course = details.appointments.first as Course;
        final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: course.color,
            borderRadius: themeNotifier.getBorderRadiusAll(0.25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                course.subject,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
                Text(
                  course.code,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (course.location.isNotEmpty && course.location != 'TBA') ...[
                const Spacer(),
                Text(
                  course.location,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        );
      },
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

  List<TimeRegion> _getTimeRegions() {
    final List<TimeRegion> regions = <TimeRegion>[];
    regions.add(TimeRegion(
        startTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 8, 0),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 8, 10),
        enablePointerInteraction: false,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
        textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 7),
        color: Colors.grey.withValues(alpha: 0.2),
        text: 'MR'));
    regions.add(TimeRegion(
        startTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 9, 30),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 9, 40),
        enablePointerInteraction: false,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
        textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 7),
        color: Colors.grey.withValues(alpha: 0.2),
        text: 'Break'));
    regions.add(TimeRegion(
        startTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 11, 0),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 11, 20),
        enablePointerInteraction: false,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
        textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 7),
        color: Colors.grey.withValues(alpha: 0.2),
        text: 'Break'));
    regions.add(TimeRegion(
        startTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 12, 40),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 13, 10),
        enablePointerInteraction: false,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
        textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 7),
        color: Colors.grey.withValues(alpha: 0.2),
        text: 'Lunch'));
    regions.add(TimeRegion(
        startTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 13, 10),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 13, 40),
        enablePointerInteraction: false,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
        textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 7),
        color: Colors.grey.withValues(alpha: 0.2),
        text: 'Pastoral'));
    regions.add(TimeRegion(
        startTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 15, 0),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 15, 10),
        enablePointerInteraction: false,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
        textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 7),
        color: Colors.grey.withValues(alpha: 0.2),
        text: 'Break'));

    return regions;
  }

  List<Course> _buildCourses() {
    final List<Course> courses = <Course>[];
    final data = widget.timetableData;
    if (data == null) return courses;

    for (int dayIndex = 0; dayIndex < data.weekdays.length && dayIndex < 7; dayIndex++) {
      final weekDay = data.weekdays[dayIndex];
      final DateTime? date = _resolveDateForDayIndex(dayIndex);
      if (date == null) continue;

      final mergedEvents = CourseMergedEvent.mergeEventsForDay(weekDay);
      
      for (final mergedEvent in mergedEvents) {
        final startInfo = PeriodConstants.getPeriodInfo(mergedEvent.startPeriod);
        final endInfo = PeriodConstants.getPeriodInfo(mergedEvent.endPeriod);
        if (startInfo != null && endInfo != null) {
          final DateTime start = _combine(date, startInfo.startTime);
          final DateTime end = _combine(date, endInfo.endTime);
          final Color color = _colorForEvent(mergedEvent.event, dayIndex);
          courses.add(
            Course(
              subject: mergedEvent.event.subject,
              location: mergedEvent.event.room.isNotEmpty ? mergedEvent.event.room : mergedEvent.event.newRoom,
              from: start,
              to: end,
              color: color,
              isAllDay: false,
              sourceEvent: mergedEvent.event,
              note: mergedEvent.event.teacher,
              code: mergedEvent.event.code,
            ),
          );
        }
      }
    }

    return courses;
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
    final timeSegments = hhmm.split(':');
    int hh = int.parse(timeSegments[0]);
    int mm = int.parse(timeSegments[1]);
    return DateTime(date.year, date.month, date.day, hh, mm);
  }

  Color _colorForEvent(TimetableEvent event, int dayIndex) {
    // List-based color assignment that ensures unique colors for different courses
    final List<Color> palette = <Color>[
      Colors.blue,
      Colors.deepPurple,
      Colors.teal,
      Colors.indigo,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.brown,
      Colors.deepOrange,
      Colors.lightBlue,
      Colors.lightGreen,
    ];
    
    // Use course subject as the key for consistent coloring
    final String courseKey = event.id.toString();
    
    // If we haven't assigned a color to this course yet, assign the next available color
    if (!_courseColors.containsKey(courseKey)) {
      if (_nextColorIndex < palette.length) {
        _courseColors[courseKey] = palette[_nextColorIndex].withValues(alpha: 0.9);
        _nextColorIndex++;
      } else {
        // If we've used all palette colors, cycle back to the beginning
        final int colorIndex = _nextColorIndex % palette.length;
        _courseColors[courseKey] = palette[colorIndex].withValues(alpha: 0.9);
        _nextColorIndex++;
      }
    }
    
    return _courseColors[courseKey]!;
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
  final String code;

  Course({
    required this.subject,
    required this.location,
    required this.from,
    required this.to,
    required this.color,
    required this.isAllDay,
    required this.sourceEvent,
    required this.note,
    required this.code,
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


