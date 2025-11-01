import 'package:flutter/material.dart';
import '../../data/constants/periods.dart';
import '../../ui/shared/academic_year_dropdown.dart';
import '../../ui/timetable/views/course_timetable_view.dart';
import '../../ui/timetable/views/exam_timetable_view.dart';
import '../../ui/shared/views/tabbed_page_base.dart';

class TimetablePage extends StatefulWidget {
  final int initialTabIndex;
  final bool isTransparent;
  const TimetablePage({
    super.key,
    this.initialTabIndex = 0,
    this.isTransparent = false,
  });

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late AcademicYear _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear =
        PeriodConstants.getAcademicYears().first; // Default to current year
  }

  void _onYearChanged(AcademicYear? newYear) {
    if (newYear != null) {
      setState(() {
        _selectedYear = newYear;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabbedPageBase(
      isTransparent: widget.isTransparent,
      title: 'Timetable',
      skinKey: ['timetable', 'exam'],
      initialTabIndex: widget.initialTabIndex,
      actions: [
        AcademicYearDropdown(
          selectedYear: _selectedYear,
          onChanged: _onYearChanged,
        ),
      ],
      tabs: const [
        Tab(text: 'Course Timetable'),
        Tab(text: 'Exam Timetable'),
      ],
      tabViews: [
        CourseTimetableView(selectedYear: _selectedYear),
        ExamTimetableView(selectedYear: _selectedYear),
      ],
    );
  }
}
