import 'package:flutter/material.dart';
import '../../models/reports.dart';
import '../../../shared/views/views/refreshable_page.dart';
import 'report_detail_content.dart';

class ReportDetailView extends StatefulWidget {
  final Exam exam;

  const ReportDetailView({super.key, required this.exam});

  @override
  State<ReportDetailView> createState() => _ReportDetailViewState();
}

class _ReportDetailViewState extends RefreshablePage<ReportDetailView> {
  @override
  String get skinKey => 'reports';

  @override
  String get appBarTitle => 'Report Detail';

  @override
  Future<void> fetchData({bool refresh = false}) async {
    // No need to fetch data here as it's handled by the content widget
  }

  @override
  Widget buildPageContent(BuildContext context, ThemeNotifier themeNotifier) {
    return ReportDetailContent(exam: widget.exam, isWideScreen: false);
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    return buildPageContent(context, themeNotifier);
  }

  @override
  bool get isEmpty => false; // Content widget handles empty state

  @override
  String get errorTitle => 'Error loading report details';
}
