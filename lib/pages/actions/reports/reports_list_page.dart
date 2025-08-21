import 'package:flutter/material.dart';
import '../../../services/reports/reports_service.dart';
import '../../../data/models/reports/reports.dart';
import '../../../ui/shared/error_placeholder.dart';
import 'report_detail_page.dart';

class ReportsListPage extends StatefulWidget {
  const ReportsListPage({super.key});

  @override
  State<ReportsListPage> createState() => _ReportsListPageState();
}

class _ReportsListPageState extends State<ReportsListPage> {
  final ReportsService _reportsService = ReportsService();
  ReportsListResponse? _reportsData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final reports = await _reportsService.fetchReportsList();
      setState(() {
        _reportsData = reports;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      if(!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToReportDetail(Exam exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailPage(exam: exam),
      ),
    );
  }

  Widget _buildReportItem(Exam exam) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
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
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    exam.grade,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    exam.examType,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${exam.year}-${exam.semester} • ${exam.month}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToReportDetail(exam),
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
        ...gradeGroup.exams.map(_buildReportItem).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return ErrorPlaceholder(
        title: 'Error loading reports',
        errorMessage: _error!,
        onRetry: _loadReports,
      );
    }

    if (_reportsData == null || _reportsData!.gradeGroups.isEmpty) {
      return const Center(
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
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        itemCount: _reportsData!.gradeGroups.length,
        itemBuilder: (context, index) {
          return _buildGradeSection(_reportsData!.gradeGroups[index]);
        },
      ),
    );
  }
}
