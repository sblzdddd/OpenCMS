import 'package:flutter/material.dart';
import '../../../services/theme/theme_services.dart';
import '../../../services/reports/reports_service.dart';
import '../../../data/models/reports/reports.dart';
import '../../shared/views/refreshable_view.dart';
import 'report_detail_view.dart';
import '../layouts/adaptive_reports_layout.dart';

class ReportsListView extends StatefulWidget {
  const ReportsListView({super.key});

  @override
  State<ReportsListView> createState() => _ReportsListViewState();
}

class _ReportsListViewState extends RefreshableView<ReportsListView> {
  final ReportsService _reportsService = ReportsService();
  ReportsListResponse? _reportsData;
  Exam? _selectedExam;

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final reports = await _reportsService.fetchReportsList(refresh: refresh);
    setState(() {
      _reportsData = reports;
    });
  }

  @override
  String get errorTitle => 'Error loading reports';

  @override
  bool get isEmpty => _reportsData == null || _reportsData!.gradeGroups.isEmpty;

  void _onExamSelected(Exam exam) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 800.0;
    
    if (isWideScreen) {
      setState(() {
        _selectedExam = exam;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportDetailView(exam: exam),
        ),
      );
    }
  }

  List<Exam> get _allExams {
    if (_reportsData == null) return [];
    return _reportsData!.gradeGroups.expand((group) => group.exams).toList();
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    return AdaptiveReportsLayout(
      exams: _allExams,
      onExamSelected: _onExamSelected,
      selectedExam: _selectedExam,
    );
  }

  @override
  String get emptyTitle => 'No reports available';
}
