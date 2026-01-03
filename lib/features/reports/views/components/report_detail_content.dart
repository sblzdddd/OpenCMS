import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silky_scroll/silky_scroll.dart';
import '../../services/reports_service.dart';
import '../../models/reports.dart';
import '../../../theme/services/theme_services.dart';
import 'mark_components_view.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/shared/constants/subject_icons.dart';
import 'package:opencms/features/theme/views/widgets/skin_icon_widget.dart';

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
      final detail = await _reportsService.fetchReportDetail(
        widget.exam.id,
        refresh: false,
      );
      setState(() {
        _reportDetail = detail;
      });
    } catch (e) {
      setState(() {
        _reportDetail = null;
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load report details',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    List<Widget> items = [
      _buildHeader(themeNotifier),
      _buildCourseMarks(themeNotifier),
      _buildPSatScores(themeNotifier),
      MarkComponentsView(
        markComponents: _reportDetail?.markComponent ?? [],
      ),
      const SizedBox(height: 32),
    ];

    final content = SilkyScroll(
      scrollSpeed: 2,
      builder: (context, controller, physics) {
        return ListView.builder(
          controller: controller,
          physics: physics,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          itemCount: items.length,
          itemBuilder: (context, index) => items[index],
        );
      },
    );
    if (widget.isWideScreen) {
      return content;
    } else {
      return RefreshIndicator(onRefresh: _loadReportDetail, child: content);
    }
  }

  Widget _buildHeader(ThemeNotifier themeNotifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: themeNotifier.getBorderRadiusAll(1),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.exam.name, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            '${widget.exam.year}-${widget.exam.year + 1} • ${widget.exam.month}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
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
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _reportDetail!.courseMark.length,
          itemBuilder: (context, index) {
            final course = _reportDetail!.courseMark[index];
            final subjectIcon = SubjectIconConstants.getCategoryForSubject(
              subjectName: course.courseName,
              code: course.courseName,
            );
            final altSubjectIcon = SubjectIconConstants.getIconForCategory(
              category: subjectIcon,
            );
            return Container(
              decoration: BoxDecoration(
                borderRadius: themeNotifier.getBorderRadiusAll(1),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.01),
                    blurRadius: 8,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
                color: themeNotifier.needTransparentBG
                    ? (!themeNotifier.isDarkMode
                          ? Theme.of(
                              context,
                            ).colorScheme.surfaceBright.withValues(alpha: 0.5)
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainer.withValues(alpha: 0.8))
                    : Theme.of(context).colorScheme.surfaceContainer,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.15,
                      child: SkinIcon(
                        imageKey: 'subjectIcons.$subjectIcon',
                        fallbackIcon: altSubjectIcon,
                        fallbackIconColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        fallbackIconBackgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                        size: 75,
                        iconSize: 56,
                      ),
                    ),
                  ),
                  Padding(
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
                              course.mark.isEmpty
                                  ? course.grade
                                  : '${course.grade} (${course.mark})',
                              style: TextStyle(
                                fontSize: 20,
                                color: course.mark.isEmpty
                                    ? _getGradeColor(course.grade)
                                    : _getMarkColor(course.mark),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (course.average.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Avg: ${course.average}'),
                        ],
                        if (course.teacherName != null && course.teacherName!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Teacher(s): ${course.teacherName}'),
                        ],
                        if (course.comment.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withValues(alpha: 0.5),
                              borderRadius: themeNotifier.getBorderRadiusAll(
                              0.5,
                              ),
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
                        if (course.average.isEmpty &&
                            course.comment.isEmpty &&
                            (course.teacherName == null || course.teacherName!.isEmpty)) ...[
                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                ],
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
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
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
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          score,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
