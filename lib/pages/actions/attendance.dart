import 'package:flutter/material.dart';
import 'attendance/attendance_page_main.dart';
import 'attendance/course_stats_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key, required this.initialTabIndex});
  final int initialTabIndex;

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Attendance'),
            Tab(text: 'Course Statistics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AttendancePageMain(),
          CourseStatsPage(),
        ],
      ),
    );
  }
}
