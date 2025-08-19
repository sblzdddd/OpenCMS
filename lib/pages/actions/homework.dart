import 'package:flutter/material.dart';
import 'homework/homework_page_main.dart';
import 'homework/teams_homework_page.dart';

class HomeworkPage extends StatefulWidget {
  const HomeworkPage({super.key, required this.initialTabIndex});
  final int initialTabIndex;

  @override
  State<HomeworkPage> createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage>
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
        title: const Text('Homework'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Homework'),
            Tab(text: 'Teams Assignments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeworkPageMain(),
          TeamsHomeworkPage(),
        ],
      ),
    );
  }
}
