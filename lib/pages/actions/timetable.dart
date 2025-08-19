import 'package:flutter/material.dart';
import '../../data/constants/period_constants.dart';
import 'timetable/course_timetable_page.dart';
import 'timetable/exam_timetable_page.dart';

class TimetablePage extends StatefulWidget {
  final int initialTabIndex;
  const TimetablePage({super.key, this.initialTabIndex = 0});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AcademicYear _selectedYear;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _selectedYear =
        PeriodConstants.getAcademicYears().first; // Default to current year
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
	        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: DropdownButton<AcademicYear>(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              value: _selectedYear,
              onChanged: _onYearChanged,
              items: PeriodConstants.getAcademicYears()
                  .map(
                    (year) => DropdownMenuItem(
                      value: year,
                      child: Text(year.displayName),
                    ),
                  )
                  .toList(),
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down),
            ),
          ),
        ],
	        bottom: TabBar(
            
	          controller: _tabController,
	          tabs: const [
	            Tab(text: 'Course Timetable'),
	            Tab(text: 'Exam Timetable'),
	          ],
	        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CourseTimetablePage(selectedYear: _selectedYear),
          ExamTimetablePage(selectedYear: _selectedYear),
        ],
      ),
    );
  }
}
