import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/constants/periods.dart';
import '../../../data/models/assessment/assessment_response.dart';
import '../../shared/selectable_item_wrapper.dart';
import '../../shared/views/adaptive_list_detail_layout.dart';
import '../views/subject_assessments_content.dart';

class AdaptiveAssessmentLayout extends StatelessWidget {
  final List<SubjectAssessment> subjects;
  final AcademicYear selectedYear;
  final Function(AcademicYear?) onYearChanged;
  final Function(SubjectAssessment) onSubjectSelected;
  final SubjectAssessment? selectedSubject;
  final double breakpoint;

  const AdaptiveAssessmentLayout({
    super.key,
    required this.subjects,
    required this.selectedYear,
    required this.onYearChanged,
    required this.onSubjectSelected,
    this.selectedSubject,
    this.breakpoint = 800.0,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveListDetailLayout<SubjectAssessment>(
      items: subjects,
      selectedItem: selectedSubject,
      onItemSelected: onSubjectSelected,
      breakpoint: breakpoint,
      itemBuilder: (subject, isSelected) =>
          _buildSubjectItem(subject, isSelected, context),
      detailBuilder: (subject) => SubjectAssessmentsContent(
        key: ValueKey(subject.id),
        subject: subject,
        academicYear: selectedYear,
        isWideScreen: true,
      ),
    );
  }

  Widget _buildSubjectItem(
    SubjectAssessment subject,
    bool isSelected,
    BuildContext context,
  ) {
    // themeNotifier no longer needed directly; wrapper handles theme.

    // Calculate performance statistics
    final validAssessments = subject.assessments
        .where((a) => a.percentageScore != null)
        .toList();
    final averageScore = validAssessments.isNotEmpty
        ? validAssessments
                  .map((a) => a.percentageScore!)
                  .reduce((a, b) => a + b) /
              validAssessments.length
        : 0.0;

    return SelectableItemWrapper(
      isSelected: isSelected,
      onTap: () => onSubjectSelected(subject),
      child: ListTile(
        mouseCursor: SystemMouseCursors.click,
        title: Text(
          '${subject.name.split('.')[0]} ${subject.subject}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Symbols.school_rounded, size: 16),
                const SizedBox(width: 4),
                Text(
                  subject.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (validAssessments.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Icon(Symbols.avg_pace_rounded, size: 16),
                  const SizedBox(width: 2),
                  Text(
                    'Average: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '${averageScore.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getScoreColor(averageScore),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Symbols.arrow_forward_ios_rounded, size: 16),
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
}
