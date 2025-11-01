import 'package:flutter/material.dart';
import '../../ui/reports/views/reports_list_view.dart';
import '../../ui/reports/views/gpa_view.dart';
import '../../ui/shared/views/tabbed_page_base.dart';

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
