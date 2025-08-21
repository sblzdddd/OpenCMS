import 'package:flutter/material.dart';
import '../../../services/reports/reports_service.dart';
import '../../../data/models/reports/reports.dart';
import '../../../ui/shared/error_placeholder.dart';

class ReportDetailPage extends StatefulWidget {
  final Exam exam;

  const ReportDetailPage({super.key, required this.exam});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  final ReportsService _reportsService = ReportsService();
  ReportDetail? _reportDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReportDetail();
  }

  Future<void> _loadReportDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final detail = await _reportsService.fetchReportDetail(widget.exam.id);
      setState(() {
        _reportDetail = detail;
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.exam.name, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(widget.exam.grade),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(widget.exam.examType),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.exam.year}-${widget.exam.semester} • ${widget.exam.month}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseMarks() {
    if (_reportDetail?.courseMark.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course Marks',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reportDetail!.courseMark.length,
          itemBuilder: (context, index) {
            final course = _reportDetail!.courseMark[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            course.courseName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${course.grade} (${course.mark})',
                          style: TextStyle(
                            fontSize: 20,
                            color: _getMarkColor(course.mark),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Avg: ${course.average}'),
                    if (course.teacherName.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Teacher(s): ${course.teacherName}'),
                    ],
                    if (course.comment.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          course.comment,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPSatScores() {
    if (_reportDetail?.pSat.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    final psat = _reportDetail!.pSat.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'PSAT Scores',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildScoreCard('Total', psat.total.toString(), '1600'),
                    _buildScoreCard('Math', psat.math.toString(), '800'),
                    _buildScoreCard(
                      'Reading/Writing',
                      psat.rw.toString(),
                      '800',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: psat.totalPercentage / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getPSatColor(psat.total),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${psat.totalPercentage.toStringAsFixed(1)}% of maximum score',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(String label, String score, String max) {
    return Column(
      children: [
        Text(
          score,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          '/ $max',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildMarkComponents() {
    if (_reportDetail?.markComponent.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Mark Components',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reportDetail!.markComponent.length,
          itemBuilder: (context, index) {
            final component = _reportDetail!.markComponent[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.component,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Board: ${component.board}'),
                        const SizedBox(width: 16),
                        Text('Syllabus: ${component.syllabus}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Adjusted: ${component.adjustedMark}'),
                        const SizedBox(width: 16),
                        Text('Final: ${component.finalMark}'),
                        const SizedBox(width: 16),
                        Text('Grade: ${component.grade}'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getMarkColor(String mark) {
    final markNum = double.tryParse(mark);
    if (markNum == null) return Colors.grey;

    if (markNum >= 90) return Colors.green;
    if (markNum >= 80) return Colors.blue;
    if (markNum >= 70) return Colors.orange;
    if (markNum >= 60) return Colors.yellow.shade700;
    return Colors.red;
  }

  Color _getPSatColor(int score) {
    if (score >= 1400) return Colors.green;
    if (score >= 1200) return Colors.blue;
    if (score >= 1000) return Colors.orange;
    if (score >= 800) return Colors.yellow.shade700;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportDetail,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? ErrorPlaceholder(
              title: 'Error loading report details',
              errorMessage: _error!,
              onRetry: _loadReportDetail,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildCourseMarks(),
                  const SizedBox(height: 24),
                  _buildPSatScores(),
                  const SizedBox(height: 24),
                  _buildMarkComponents(),
                ],
              ),
            ),
    );
  }
}
