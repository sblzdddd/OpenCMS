import 'package:flutter/material.dart';
import '../components/reports_list_view.dart';
import '../components/gpa_view.dart';
import '../../../shared/views/views/tabbed_page_base.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key, this.initialTabIndex = 0});
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return TabbedPageBase(
      title: 'Reports',
      skinKey: ['reports', 'gpa'],
      initialTabIndex: initialTabIndex,
      tabs: const [
        Tab(text: 'Reports'),
        Tab(text: 'GPA'),
      ],
      tabViews: const [ReportsListView(), MyGpaView()],
    );
  }
}
