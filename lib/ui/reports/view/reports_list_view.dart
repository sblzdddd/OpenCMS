import 'package:flutter/material.dart';
import '../../../services/theme/theme_services.dart';
import '../../../services/reports/reports_service.dart';
import '../../../data/models/reports/reports.dart';
import '../../shared/views/refreshable_view.dart';
import 'report_detail_view.dart';
import '../../shared/scaled_ink_well.dart';

class ReportsListView extends StatefulWidget {
  const ReportsListView({super.key});

  @override
  State<ReportsListView> createState() => _ReportsListViewState();
}

class _ReportsListViewState extends RefreshableView<ReportsListView> {
  final ReportsService _reportsService = ReportsService();
  ReportsListResponse? _reportsData;

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

  void _navigateToReportDetail(Exam exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailView(exam: exam),
      ),
    );
  }

  Widget _buildReportItem(Exam exam) {
    return ScaledInkWell(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      borderRadius: themeNotifier.getBorderRadiusAll(1),
      onTap: () => _navigateToReportDetail(exam),
      background: (inkWell) => Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: themeNotifier.getBorderRadiusAll(1),
        child: inkWell,
      ),
      child: ListTile(
        mouseCursor: SystemMouseCursors.click,
        title: Text(
          exam.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: themeNotifier.getBorderRadiusAll(999),
                  ),
                  child: Text(
                    exam.month,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: themeNotifier.getBorderRadiusAll(999),
                  ),
                  child: Text(
                    exam.examType,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildGradeSection(GradeGroup gradeGroup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Grade ${gradeGroup.grade}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...gradeGroup.exams.map(_buildReportItem),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    return ListView.builder(
      itemCount: _reportsData!.gradeGroups.length,
      itemBuilder: (context, index) {
        return _buildGradeSection(_reportsData!.gradeGroups[index]);
      },
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
                Icons.description_outlined,
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
