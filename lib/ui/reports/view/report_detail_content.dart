import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/reports/reports_service.dart';
import '../../../data/models/reports/reports.dart';
import '../../../services/theme/theme_services.dart';
import '../mark_components_view.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ReportDetailContent extends StatefulWidget {
  final Exam exam;
  final bool isWideScreen;

  const ReportDetailContent({
    super.key,
    required this.exam,
    this.isWideScreen = false,
  });

  @override
  State<ReportDetailContent> createState() => _ReportDetailContentState();
}

class _ReportDetailContentState extends State<ReportDetailContent> {
  final ReportsService _reportsService = ReportsService();
  ReportDetail? _reportDetail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReportDetail();
  }

  @override
  void didUpdateWidget(ReportDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exam.id != widget.exam.id) {
      _loadReportDetail();
    }
  }

  Future<void> _loadReportDetail() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final detail = await _reportsService.fetchReportDetail(widget.exam.id, refresh: false);
      setState(() {
        _reportDetail = detail;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reportDetail == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.error_outline_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load report details',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(themeNotifier),
          _buildCourseMarks(themeNotifier),
          _buildPSatScores(themeNotifier),
          MarkComponentsView(markComponents: _reportDetail?.markComponent ?? []),
        ],
      ),
    );

    // Only wrap with RefreshIndicator in mobile mode
    // In wide screen mode, let the parent page handle refresh
    if (widget.isWideScreen) {
      return content;
    } else {
      return RefreshIndicator(
        onRefresh: _loadReportDetail,
        child: content,
      );
    }
  }

  Widget _buildHeader(ThemeNotifier themeNotifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: themeNotifier.getBorderRadiusAll(0.75),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.exam.name, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            '${widget.exam.year}-${widget.exam.year+1} • ${widget.exam.month}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: themeNotifier.getBorderRadiusAll(999),
                ),
                child: Text(widget.exam.examType),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseMarks(ThemeNotifier themeNotifier) {
    if (_reportDetail?.courseMark.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: themeNotifier.getBorderRadiusAll(1),
              ),
              clipBehavior: Clip.antiAlias,
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
                          course.mark.isEmpty ? course.grade : '${course.grade} (${course.mark})',
                          style: TextStyle(
                            fontSize: 20,
                            color: course.mark.isEmpty ? _getGradeColor(course.grade) : _getMarkColor(course.mark),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (course.average.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Avg: ${course.average}'),
                    ],
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
                          borderRadius: themeNotifier.getBorderRadiusAll(0.5),
                        ),
                        child: Text(
                          course.comment,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
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

  Widget _buildPSatScores(ThemeNotifier themeNotifier) {
    if (_reportDetail?.pSat.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    final psat = _reportDetail!.pSat.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'PSAT Scores',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: themeNotifier.getBorderRadiusAll(1),
          ),
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
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
          label,
          style: TextStyle(
            fontSize: 12, 
            color: Theme.of(context).colorScheme.primary, 
            fontWeight: FontWeight.w500
          ),
        ),
        Text(
          score,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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

  Color _getGradeColor(String grade) {
    if (grade == 'A') return Colors.green;
    if (grade == 'B') return Colors.blue;
    if (grade == 'C') return Colors.orange;
    if (grade == 'D') return Colors.yellow.shade700;
    return Colors.red;
  }
}
