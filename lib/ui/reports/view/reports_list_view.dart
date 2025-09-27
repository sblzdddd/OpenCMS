import 'package:flutter/material.dart';
import '../../../services/theme/theme_services.dart';
import '../../../services/reports/reports_service.dart';
import '../../../data/models/reports/reports.dart';
import '../../shared/views/refreshable_view.dart';
import 'report_detail_view.dart';
import 'adaptive_reports_layout.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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
  Widget buildEmptyWidget(BuildContext context, ThemeNotifier themeNotifier) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.description_rounded,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No reports available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
