import 'package:flutter/material.dart';
import 'package:opencms/utils/sfcalendar_theme.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../../../theme/services/theme_services.dart';
import '../../models/exam_timetable_models.dart';
import '../../services/exam_timetable_service.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ExamTimetableCalendarView extends StatefulWidget {
  final Function(ExamTimetableEntry) onExamTap;
  final int selectedYear;

  const ExamTimetableCalendarView({
    super.key,
    required this.onExamTap,
    required this.selectedYear,
  });

  @override
  State<ExamTimetableCalendarView> createState() =>
      _ExamTimetableCalendarViewState();
}

class _ExamTimetableCalendarViewState extends State<ExamTimetableCalendarView> {
  final ExamTimetableService _examService = ExamTimetableService();
  late CalendarController _calendarController;

  List<ExamTimetableEntry> _exams = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _loadedYear;

  // Track unique courses and their assigned colors
  final Map<String, Color> _courseColors = {};
  int _nextColorIndex = 0;

  // Calendar configuration
  final bool _showLeadingAndTrailingDates = true;
  final bool _showWeekNumber = false;
  final bool _showDatePickerButton = true;
  final ViewNavigationMode _viewNavigationMode = ViewNavigationMode.snap;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _loadExams(DateTime.now());
  }

  @override
  void didUpdateWidget(ExamTimetableCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Navigate to the selected year when it changes
    if (oldWidget.selectedYear != widget.selectedYear) {
      _loadExams(DateTime(widget.selectedYear, 1, 1));
    }
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  Future<void> _loadExams(DateTime date, {bool refresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final exams = await _examService.fetchExamTimetable(
        year: date.year,
        refresh: refresh,
      );

      if (!mounted) return;
      setState(() {
        _exams = exams;
        _loadedYear = date.year;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onViewChanged(ViewChangedDetails details) async {
    final List<DateTime> visible = details.visibleDates;
    final DateTime newDate = visible.isNotEmpty
        ? visible[visible.length ~/ 2]
        : DateTime.now();

    // Avoid reloading if already loading or year unchanged
    if (_isLoading == true) return;
    if (_loadedYear == newDate.year) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadExams(newDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildCalendarBody();
  }

  Widget _buildCalendarBody() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load exam timetable',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadExams(DateTime.now()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final courses = _buildCourses();
    return Column(
      children: [
        if (_isLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: SfCalendarTheme(
            data: themeData(context),
            child: SfCalendar(
              controller: _calendarController,
              allowedViews: [
                CalendarView.month,
                CalendarView.schedule,
                CalendarView.week,
                CalendarView.day,
                CalendarView.timelineDay,
                CalendarView.timelineWeek,
              ],
              view: CalendarView.month,
              firstDayOfWeek: 1,
              dataSource: _ExamDataSource(courses),
              showCurrentTimeIndicator: true,
              allowViewNavigation: true,
              showDatePickerButton: _showDatePickerButton,
              viewNavigationMode: _viewNavigationMode,
              showWeekNumber: _showWeekNumber,
              onViewChanged: _onViewChanged,
              monthViewSettings: MonthViewSettings(
                showAgenda: false,
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                showTrailingAndLeadingDates: _showLeadingAndTrailingDates,
              ),
              timeSlotViewSettings: TimeSlotViewSettings(
                startHour: 7, // 07:30
                endHour: 19, // 18:30
                nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday],
                timeIntervalHeight: 60,
                timeRulerSize: 50,
                minimumAppointmentDuration: Duration(minutes: 30),
              ),
              appointmentBuilder:
                  (BuildContext context, CalendarAppointmentDetails details) {
                    final ExamCourse course =
                        details.appointments.first as ExamCourse;
                    final CalendarView currentView =
                        _calendarController.view ?? CalendarView.month;

                    // Simplified layout for month view
                    if (currentView == CalendarView.month) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: course.color,
                          borderRadius: themeNotifier.getBorderRadiusAll(0.25),
                        ),
                        child: Text(
                          course.subject,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }

                    // Detailed layout for other views (week, workWeek, day)
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
                          if (course.location.isNotEmpty &&
                              course.location != 'TBA') ...[
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
                          ],
                        ],
                      ),
                    );
                  },
              onTap: (details) {
                if (details.targetElement == CalendarElement.appointment &&
                    details.appointments != null &&
                    details.appointments!.isNotEmpty) {
                  final ExamCourse tapped =
                      details.appointments!.first as ExamCourse;
                  widget.onExamTap(tapped.sourceExam);
                } else if (details.targetElement ==
                    CalendarElement.calendarCell) {
                  // Navigate to day view when tapping on a month cell
                  final DateTime tappedDate = details.date!;
                  _calendarController.view = CalendarView.week;
                  _calendarController.displayDate = tappedDate;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  List<ExamCourse> _buildCourses() {
    final List<ExamCourse> courses = <ExamCourse>[];

    for (final exam in _exams) {
      final DateTime startDate = _parseExamDateTime(exam.date, exam.startTime);
      final DateTime endDate = _parseExamDateTime(exam.date, exam.endTime);

      if (startDate != DateTime.now() && endDate != DateTime.now()) {
        final Color color = _colorForExam(exam);
        courses.add(
          ExamCourse(
            subject: exam.paper.isNotEmpty
                ? exam.paper
                : (exam.code.isNotEmpty ? exam.code : 'Exam'),
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
    final String examKey = exam.code.isNotEmpty ? exam.code : exam.paper;

    // If we haven't assigned a color to this exam yet, assign the next available color
    if (!_courseColors.containsKey(examKey)) {
      if (_nextColorIndex < palette.length) {
        _courseColors[examKey] = palette[_nextColorIndex].withValues(
          alpha: 0.5,
        );
        _nextColorIndex++;
      } else {
        // If we've used all palette colors, cycle back to the beginning
        final int colorIndex = _nextColorIndex % palette.length;
        _courseColors[examKey] = palette[colorIndex].withValues(alpha: 0.5);
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
