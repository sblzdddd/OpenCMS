import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../../../shared/constants/period_constants.dart';
import '../../models/exam_timetable_models.dart';
import '../../services/exam_timetable_service.dart';
import '../../../../shared/views/views/refreshable_view.dart';
import 'exam_timetable_list_view.dart';
import 'exam_timetable_calendar_view.dart';
import '../../../../theme/services/theme_services.dart';
import 'package:logging/logging.dart';

final logger = Logger('ExamTimetableView');

class ExamTimetableView extends StatefulWidget {
  final AcademicYear selectedYear;

  const ExamTimetableView({super.key, required this.selectedYear});

  @override
  State<ExamTimetableView> createState() => _ExamTimetableViewState();
}

class _ExamTimetableViewState extends RefreshableView<ExamTimetableView> {
  final ExamTimetableService _examService = ExamTimetableService();

  int _selectedYear = DateTime.now().year;
  List<ExamTimetableEntry> _exams = const [];
  bool _isCalendarView = false;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.selectedYear.year;
  }

  @override
  void didUpdateWidget(covariant ExamTimetableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear.year != widget.selectedYear.year) {
      setState(() {
        _selectedYear = widget.selectedYear.year;
      });
      loadData(refresh: false);
    }
  }

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final parsed = await _examService.fetchExamTimetable(
      year: widget.selectedYear.year,
      refresh: refresh,
    );

    if (mounted) {
      setState(() {
        _exams = parsed;
      });
    }
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    if (_isCalendarView) {
      return ExamTimetableCalendarView(
        onExamTap: (exam) => _showExamOptionsMenu(context, exam),
        selectedYear: _selectedYear,
      );
    } else {
      return ExamTimetableListView(
        exams: _exams,
        onExamTap: (exam) => _showExamOptionsMenu(context, exam),
      );
    }
  }

  @override
  String get emptyTitle => 'No exams scheduled for this year';

  @override
  String get errorTitle => 'Failed to load timetable';

  @override
  bool get isEmpty => _isCalendarView ? false : _exams.isEmpty;

  void _toggleView() {
    setState(() {
      _isCalendarView = !_isCalendarView;
    });
  }

  void _showExamOptionsMenu(BuildContext context, ExamTimetableEntry exam) {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      // TODO: Add schedule support for desktop platforms
      return;
    }
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final cardBox = context.findRenderObject() as RenderBox;
    final cardTopLeft = cardBox.localToGlobal(Offset.zero, ancestor: overlay);
    final cardBottomLeft = cardBox.localToGlobal(
      Offset(0, cardBox.size.height),
      ancestor: overlay,
    );
    const verticalOffset = -8.0;
    final left = cardTopLeft.dx;
    final top = cardBottomLeft.dy + verticalOffset;
    final position = RelativeRect.fromLTRB(
      left,
      top,
      overlay.size.width - left,
      overlay.size.height - top,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'add_to_calendar',
          child: Row(
            children: [
              Icon(Symbols.calendar_today_rounded, size: 20),
              const SizedBox(width: 8),
              Text('Add schedule in system calendar'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'add_to_calendar') {
        _addExamToCalendar(exam);
      }
    });
  }

  void _addExamToCalendar(ExamTimetableEntry exam) {
    // Parse the date and time from the exam entry
    final dateParts = exam.date.split('-');
    final timeParts = exam.startTime.split(':');
    final endTimeParts = exam.endTime.split(':');

    if (dateParts.length == 3 &&
        timeParts.length == 2 &&
        endTimeParts.length == 2) {
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      final startHour = int.parse(timeParts[0]);
      final startMinute = int.parse(timeParts[1]);
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

      final startDate = DateTime(year, month, day, startHour, startMinute);
      final endDate = DateTime(year, month, day, endHour, endMinute);

      final Event event = Event(
        title: exam.paper.isNotEmpty
            ? '${exam.paper} (${exam.code})'
            : (exam.code.isNotEmpty ? exam.code : 'Exam'),
        description:
            '${exam.code.isNotEmpty ? 'Code: ${exam.code}\n' : ''}Seat: ${exam.seat.isNotEmpty ? exam.seat : 'TBA'}',
        location: exam.room.isNotEmpty ? exam.room : 'TBA',
        startDate: startDate,
        endDate: endDate,
        iosParams: IOSParams(reminder: Duration(hours: 1)),
        androidParams: AndroidParams(emailInvites: []),
      );
      Add2Calendar.addEvent2Cal(event);
    } else {
      logger.warning('Invalid exam date: ${exam.date}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(child: super.build(context)),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _toggleView,
            heroTag: 'toggle_view',
            child: Icon(
              _isCalendarView
                  ? Symbols.list_rounded
                  : Symbols.calendar_month_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
