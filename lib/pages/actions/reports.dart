import 'package:flutter/material.dart';
import 'reports/reports_list_page.dart';
import 'reports/gpa_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, this.initialTabIndex = 0});
  final int initialTabIndex;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
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
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Reports'),
            Tab(text: 'GPA'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ReportsListPage(),
          GpaPage(),
        ],
      ),
    );
  }
}
