import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../data/constants/periods.dart';
import '../../data/models/assessment/assessment_response.dart';
import '../../services/theme/theme_services.dart';
import '../shared/scaled_ink_well.dart';
import '../shared/views/adaptive_list_detail_layout.dart';
import 'subject_assessments_content.dart';

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
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);

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

    return Material(
      color: Colors.transparent,
      child: ScaledInkWell(
        background: (inkWell) => Material(
          color: isSelected
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : themeNotifier.needTransparentBG && !themeNotifier.isDarkMode
              ? Theme.of(context).colorScheme.surfaceBright.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.8),
          borderRadius: themeNotifier.getBorderRadiusAll(1),
          child: inkWell,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        onTap: () => onSubjectSelected(subject),
        borderRadius: themeNotifier.getBorderRadiusAll(1),

        child: Container(
          decoration: BoxDecoration(
            borderRadius: themeNotifier.getBorderRadiusAll(1),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0),
              width: 1,
            ),
          ),
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
}
