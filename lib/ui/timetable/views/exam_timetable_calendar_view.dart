import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../services/theme/theme_services.dart';
import '../../../data/models/timetable/exam_timetable_entry.dart';

class ExamTimetableCalendarView extends StatefulWidget {
  final List<ExamTimetableEntry> exams;
  final Function(ExamTimetableEntry) onExamTap;
  final int selectedMonth;
  final int selectedYear;

  const ExamTimetableCalendarView({
    super.key,
    required this.exams,
    required this.onExamTap,
    required this.selectedMonth,
    required this.selectedYear,
  });

  @override
  State<ExamTimetableCalendarView> createState() => _ExamTimetableCalendarViewState();
}

class _ExamTimetableCalendarViewState extends State<ExamTimetableCalendarView> {
  // Track unique courses and their assigned colors
  final Map<String, Color> _courseColors = {};
  int _nextColorIndex = 0;
  late CalendarController _calendarController;
  late DateTime _currentDisplayDate;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _currentDisplayDate = DateTime(widget.selectedYear, widget.selectedMonth, 1);
  }

  @override
  void didUpdateWidget(ExamTimetableCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Navigate to the selected month when it changes
    if (oldWidget.selectedMonth != widget.selectedMonth || 
        oldWidget.selectedYear != widget.selectedYear) {
      _currentDisplayDate = DateTime(widget.selectedYear, widget.selectedMonth, 1);
      _calendarController.displayDate = _currentDisplayDate;
    }
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courses = _buildCourses();

    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            const Text('No exams scheduled for this month'),
          ],
        ),
      );
    }

    return SfCalendar(
      controller: _calendarController,
      allowedViews: [CalendarView.month, CalendarView.workWeek],
      view: CalendarView.month,
      firstDayOfWeek: 1,
      dataSource: _ExamDataSource(courses),
      showCurrentTimeIndicator: true,
      initialDisplayDate: _currentDisplayDate,
      monthViewSettings: const MonthViewSettings(
        showAgenda: true,
        appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
        agendaViewHeight: 200,
        agendaItemHeight: 60,
        showTrailingAndLeadingDates: true,
      ),
      timeSlotViewSettings: TimeSlotViewSettings(
        startHour: 7.5, // 07:30
        endHour: 18.5, // 18:30
        nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday],
        timeIntervalHeight: 60,
        timeRulerSize: 100,
        minimumAppointmentDuration: Duration(minutes: 30),
      ),
      appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
        final ExamCourse course = details.appointments.first as ExamCourse;
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
                  '${course.location} • ${course.seat}',
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
          final ExamCourse tapped = details.appointments!.first as ExamCourse;
          widget.onExamTap(tapped.sourceExam);
        }
      },
    );
  }

  List<ExamCourse> _buildCourses() {
    final List<ExamCourse> courses = <ExamCourse>[];
    
    for (final exam in widget.exams) {
      final DateTime startDate = _parseExamDateTime(exam.date, exam.startTime);
      final DateTime endDate = _parseExamDateTime(exam.date, exam.endTime);
      
      if (startDate != DateTime.now() && endDate != DateTime.now()) {
        final Color color = _colorForExam(exam);
        courses.add(
          ExamCourse(
            subject: exam.subject.isNotEmpty ? exam.subject : (exam.code.isNotEmpty ? exam.code : 'Exam'),
            location: exam.room.isNotEmpty ? exam.room : 'TBA',
            from: startDate,
            to: endDate,
            color: color,
            isAllDay: false,
            sourceExam: exam,
            seat: exam.seat.isNotEmpty ? exam.seat : 'TBA',
            code: exam.code,
          ),
        );
      }
    }

    return courses;
  }

  DateTime _parseExamDateTime(String date, String time) {
    final dateParts = date.split('-');
    final timeParts = time.split(':');
    
    if (dateParts.length == 3 && timeParts.length == 2) {
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      return DateTime(year, month, day, hour, minute);
    }
    
    return DateTime.now();
  }

  Color _colorForExam(ExamTimetableEntry exam) {
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
    
    // Use exam code as the key for consistent coloring
    final String examKey = exam.code.isNotEmpty ? exam.code : exam.subject;
    
    // If we haven't assigned a color to this exam yet, assign the next available color
    if (!_courseColors.containsKey(examKey)) {
      if (_nextColorIndex < palette.length) {
        _courseColors[examKey] = palette[_nextColorIndex].withValues(alpha: 0.9);
        _nextColorIndex++;
      } else {
        // If we've used all palette colors, cycle back to the beginning
        final int colorIndex = _nextColorIndex % palette.length;
        _courseColors[examKey] = palette[colorIndex].withValues(alpha: 0.9);
        _nextColorIndex++;
      }
    }
    
    return _courseColors[examKey]!;
  }
}

class ExamCourse {
  final String subject;
  final String location;
  final DateTime from;
  final DateTime to;
  final Color color;
  final bool isAllDay;
  final ExamTimetableEntry sourceExam;
  final String code;
  final String seat;

  ExamCourse({
    required this.subject,
    required this.location,
    required this.from,
    required this.to,
    required this.color,
    required this.isAllDay,
    required this.sourceExam,
    required this.code,
    required this.seat,
  });
}

class _ExamDataSource extends CalendarDataSource {
  _ExamDataSource(List<ExamCourse> source) {
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
}
