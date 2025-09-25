import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../data/constants/periods.dart';
import '../../data/models/assessment/assessment_response.dart';
import '../../services/assessment/assessment_service.dart';
import '../shared/views/refreshable_page.dart';
import 'assessment_chart_widget.dart';
import '../components/assessment_type_counts_widget.dart';

class SubjectAssessmentsView extends StatefulWidget {
  final SubjectAssessment subject;
  final AcademicYear academicYear;

  const SubjectAssessmentsView({
    super.key,
    required this.subject,
    required this.academicYear,
  });

  @override
  State<SubjectAssessmentsView> createState() => _SubjectAssessmentsViewState();
}

class _SubjectAssessmentsViewState extends RefreshablePage<SubjectAssessmentsView> {
  late SubjectAssessment _currentSubject;
  
  @override
  void initState() {
    super.initState();
    _currentSubject = widget.subject;
  }
  
  @override
  String get appBarTitle => 'Assessments - ${_currentSubject.name.split('.')[0]} ${_currentSubject.subject}';

  @override
  Future<void> fetchData({bool refresh = false}) async {
    if (refresh) {
      final assessments = await AssessmentService().getAssessmentsBySubject(
        year: widget.academicYear.year,
        subjectName: _currentSubject.subject,
        refresh: true,
      );
      // Create a new SubjectAssessment instance with updated assessments
      _currentSubject = SubjectAssessment(
        id: _currentSubject.id,
        name: _currentSubject.name,
        subject: _currentSubject.subject,
        assessments: assessments,
      );
      setState(() {});
    }
  }

  @override
  Widget buildPageContent(BuildContext context, ThemeNotifier themeNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildPerformanceSummary(),
        _buildChartSection(),
        _buildAssessmentsList(),
      ],
    );
  }

  @override
  bool get isEmpty => _currentSubject.assessments.isEmpty;

  @override
  String get errorTitle => 'Error loading assessments';

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
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
    );
  }

  Widget _buildPerformanceSummary() {
    final validAssessments = _currentSubject.assessments.where((a) => a.percentageScore != null).toList();
    
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
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text(
          'Performance Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard('Average', '${averageScore.toStringAsFixed(1)}%', _getScoreColor(averageScore)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard('Highest', '${highestScore.toStringAsFixed(1)}%', _getScoreColor(highestScore)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard('Lowest', '${lowestScore.toStringAsFixed(1)}%', _getScoreColor(lowestScore)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1),
      ),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AssessmentChartWidget(
          assessments: _currentSubject.assessments,
          subjectName: _currentSubject.subject,
        ),
      ],
    );
  }

  Widget _buildAssessmentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text(
            'Assessments',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _currentSubject.assessments.length,
          itemBuilder: (context, index) {
            final assessment = _currentSubject.assessments.reversed.toList()[index];
            return _buildAssessmentItem(assessment);
          },
        ),
      ],
    );
  }

  Widget _buildAssessmentItem(Assessment assessment) {
    final hasValidScore = assessment.percentageScore != null;
    final scoreColor = hasValidScore ? _getScoreColor(assessment.percentageScore!) : Colors.grey;
    final gradeColor = _getGradeColor(assessment.mark);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getAssessmentTypeColor(assessment.kind).withValues(alpha: 0.2),
                          borderRadius: themeNotifier.getBorderRadiusAll(999),
                        ),
                        child: Text(
                          assessment.kind,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getAssessmentTypeColor(assessment.kind),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (assessment.teacher.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                            borderRadius: themeNotifier.getBorderRadiusAll(999),
                          ),
                          child: Text(
                            assessment.teacher,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        assessment.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (assessment.average.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Class Avg: ${assessment.average}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                      value: hasValidScore ? assessment.percentageScore! / 100 : 0,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      trackGap: 10,
                    )
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
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
    if (upperGrade == 'E' || upperGrade == 'F' || upperGrade == 'U') return Colors.red;
    return Colors.grey;
  }

  Color _getAssessmentTypeColor(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('test') || lowerType.contains('exam')) return Colors.red;
    if (lowerType.contains('project')) return Colors.blue;
    if (lowerType.contains('homework')) return Colors.green;
    if (lowerType.contains('practical')) return Colors.orange;
    if (lowerType.contains('formative')) return Colors.purple;
    return Colors.grey;
  }
}
