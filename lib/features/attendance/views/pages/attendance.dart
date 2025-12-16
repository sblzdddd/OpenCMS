import 'package:flutter/material.dart';
import '../layouts/attendance_page_view.dart';
import '../layouts/course_stats_view.dart';
import '../../../shared/views/views/tabbed_page_base.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key, required this.initialTabIndex});
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return TabbedPageBase(
      title: 'Attendance',
      skinKey: ['attendance', 'course_stats'],
      initialTabIndex: initialTabIndex,
      tabs: const [
        Tab(text: 'Attendance'),
        Tab(text: 'Course Statistics'),
      ],
      tabViews: const [AttendancePageView(), CourseStatsView()],
    );
  }
}
