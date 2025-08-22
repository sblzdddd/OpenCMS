import 'package:flutter/material.dart';
import '../../ui/homework/homework_page_main.dart';
import '../../ui/homework/teams_homework_page.dart';
import '../../ui/shared/views/tabbed_page_base.dart';

class HomeworkPage extends StatelessWidget {
  const HomeworkPage({super.key, this.initialTabIndex = 0});
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return TabbedPageBase(
      title: 'Homework',
      initialTabIndex: initialTabIndex,
      tabs: const [
        Tab(text: 'Homework'),
        Tab(text: 'Teams Assignments'),
      ],
      tabViews: const [
        HomeworkPageMain(),
        TeamsHomeworkPage(),
      ],
    );
  }
}
