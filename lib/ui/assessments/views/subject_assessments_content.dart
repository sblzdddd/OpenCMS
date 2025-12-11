import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../data/constants/periods.dart';
import '../../../data/models/assessment/assessment_response.dart';
import '../../../services/assessment/assessment_service.dart';
import '../../../services/theme/theme_services.dart';
import '../../components/assessment_type_counts_widget.dart';
import '../widgets/assessment_chart_widget.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';

class SubjectAssessmentsContent extends StatefulWidget {
  final SubjectAssessment subject;
  final AcademicYear academicYear;
  final bool isWideScreen;
  final VoidCallback? onRefresh;

  const SubjectAssessmentsContent({
    super.key,
    required this.subject,
    required this.academicYear,
    this.isWideScreen = false,
    this.onRefresh,
  });

  @override
  State<SubjectAssessmentsContent> createState() =>
      _SubjectAssessmentsContentState();
}

class _SubjectAssessmentsContentState extends State<SubjectAssessmentsContent> {
  late SubjectAssessment _currentSubject;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentSubject = widget.subject;
  }

  @override
  void didUpdateWidget(SubjectAssessmentsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subject.id != widget.subject.id) {
      _currentSubject = widget.subject;
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final assessments = await AssessmentService().getAssessmentsBySubject(
        year: widget.academicYear.year,
        subjectName: _currentSubject.subject,
        refresh: true,
      );

      setState(() {
        _currentSubject = SubjectAssessment(
          id: _currentSubject.id,
          name: _currentSubject.name,
          subject: _currentSubject.subject,
          assessments: assessments,
        );
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

    final content = CustomChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(themeNotifier),
          _buildPerformanceSummary(themeNotifier),
          _buildAssessmentsList(themeNotifier),
        ],
      ),
    );

    // Only wrap with RefreshIndicator in mobile mode
    // In wide screen mode, let the parent page handle refresh
    if (widget.isWideScreen) {
      return content;
    } else {
      return RefreshIndicator(onRefresh: _refreshData, child: content);
    }
  }

  Widget _buildHeader(ThemeNotifier themeNotifier) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: themeNotifier.needTransparentBG
              ? (!themeNotifier.isDarkMode
                    ? Theme.of(
                        context,
                      ).colorScheme.surfaceBright.withValues(alpha: 0.5)
                    : Theme.of(
                        context,
                      ).colorScheme.surfaceContainer.withValues(alpha: 0.8))
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: themeNotifier.getBorderRadiusAll(0.75),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_currentSubject.name.split('.')[0]} ${_currentSubject.subject}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Symbols.school_rounded, size: 16),
                const SizedBox(width: 4),
                Text(
                  _currentSubject.name,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                Icon(Symbols.calendar_month_rounded, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${widget.academicYear.year}-${widget.academicYear.year + 1}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AssessmentTypeCountsWidget(
              assessments: _currentSubject.assessments,
              themeNotifier: themeNotifier,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSummary(ThemeNotifier themeNotifier) {
    final validAssessments = _currentSubject.assessments
        .where((a) => a.percentageScore != null)
        .toList();

    if (validAssessments.isEmpty) {
      return const SizedBox.shrink();
    }

    final scores = validAssessments.map((a) => a.percentageScore!).toList();
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;
    final highestScore = scores.reduce((a, b) => a > b ? a : b);
    final lowestScore = scores.reduce((a, b) => a < b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Performance Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: themeNotifier.needTransparentBG
              ? (!themeNotifier.isDarkMode
                    ? Theme.of(
                        context,
                      ).colorScheme.surfaceBright.withValues(alpha: 0.5)
                    : Theme.of(
                        context,
                      ).colorScheme.surfaceContainer.withValues(alpha: 0.8))
              : Theme.of(context).colorScheme.surfaceContainer,
          elevation: 0,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Average',
                      '${averageScore.toStringAsFixed(1)}%',
                      _getScoreColor(averageScore),
                      themeNotifier,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryCard(
                      'Highest',
                      '${highestScore.toStringAsFixed(1)}%',
                      _getScoreColor(highestScore),
                      themeNotifier,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryCard(
                      'Lowest',
                      '${lowestScore.toStringAsFixed(1)}%',
                      _getScoreColor(lowestScore),
                      themeNotifier,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AssessmentChartWidget(
                    assessments: _currentSubject.assessments,
                    subjectName: _currentSubject.subject,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    Color color,
    ThemeNotifier themeNotifier,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1),
      ),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentsList(ThemeNotifier themeNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Assessments',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _currentSubject.assessments.length,
          itemBuilder: (context, index) {
            final assessment = _currentSubject.assessments.reversed
                .toList()[index];
            return _buildAssessmentItem(assessment, themeNotifier);
          },
        ),
      ],
    );
  }

  Widget _buildAssessmentItem(
    Assessment assessment,
    ThemeNotifier themeNotifier,
  ) {
    final hasValidScore = assessment.percentageScore != null;
    final scoreColor = hasValidScore
        ? _getScoreColor(assessment.percentageScore!)
        : Colors.grey;
    final gradeColor = _getGradeColor(assessment.mark);

    return Card(
      color: themeNotifier.needTransparentBG
          ? (!themeNotifier.isDarkMode
                ? Theme.of(
                    context,
                  ).colorScheme.surfaceBright.withValues(alpha: 0.5)
                : Theme.of(
                    context,
                  ).colorScheme.surfaceContainer.withValues(alpha: 0.8))
          : Theme.of(context).colorScheme.surfaceContainer,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assessment.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getAssessmentTypeColor(
                              assessment.kind,
                            ).withValues(alpha: 0.2),
                            borderRadius: themeNotifier.getBorderRadiusAll(999),
                          ),
                          child: Text(
                            assessment.kind,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getAssessmentTypeColor(assessment.kind),
                            ),
                          ),
                        ),
                      ),
                      if (assessment.teacher.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer
                                  .withValues(alpha: 0.3),
                              borderRadius: themeNotifier.getBorderRadiusAll(
                                999,
                              ),
                            ),
                            child: Text(
                              assessment.teacher,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Symbols.calendar_today_rounded,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        assessment.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (assessment.average.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Symbols.people_rounded,
                          size: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Class Avg: ${assessment.average}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Circular Progress Indicator
            SizedBox(
              height: 80,
              width: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: CircularProgressIndicator(
                      value: hasValidScore
                          ? assessment.percentageScore! / 100
                          : 0,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      trackGap: 10,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        assessment.mark.isNotEmpty ? assessment.mark : 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: gradeColor,
                        ),
                      ),
                      if (assessment.outOf.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Out of ${assessment.outOf}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.yellow.shade700;
    return Colors.red;
  }

  Color _getGradeColor(String grade) {
    final upperGrade = grade.toUpperCase();
    if (upperGrade == 'A') return Colors.green;
    if (upperGrade == 'B') return Colors.blue;
    if (upperGrade == 'C') return Colors.orange;
    if (upperGrade == 'D') return Colors.yellow.shade700;
    if (upperGrade == 'E' || upperGrade == 'F' || upperGrade == 'U') {
      return Colors.red;
    }
    return Colors.grey;
  }

  Color _getAssessmentTypeColor(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('test') || lowerType.contains('exam')) {
      return Colors.red;
    }
    if (lowerType.contains('project')) return Colors.blue;
    if (lowerType.contains('homework')) return Colors.green;
    if (lowerType.contains('practical')) return Colors.orange;
    if (lowerType.contains('formative')) return Colors.purple;
    return Colors.grey;
  }
}
