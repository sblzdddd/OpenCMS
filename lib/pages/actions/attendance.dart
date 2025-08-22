import 'package:flutter/material.dart';
import '../../ui/attendance/views/attendance_page_view.dart';
import '../../ui/attendance/views/course_stats_view.dart';
import '../../ui/shared/views/tabbed_page_base.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key, required this.initialTabIndex});
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return TabbedPageBase(
      title: 'Attendance',
      initialTabIndex: initialTabIndex,
      tabs: const [
        Tab(text: 'Attendance'),
        Tab(text: 'Course Statistics'),
      ],
      tabViews: const [
        AttendancePageView(),
        CourseStatsView(),
      ],
    );
  }
}
