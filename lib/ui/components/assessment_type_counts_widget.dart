import 'package:flutter/material.dart';
import '../../data/models/assessment/assessment_response.dart';
import '../../services/theme/theme_services.dart';

class AssessmentTypeCountsWidget extends StatelessWidget {
  final List<Assessment> assessments;
  final ThemeNotifier themeNotifier;

  const AssessmentTypeCountsWidget({
    super.key,
    required this.assessments,
    required this.themeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final testCount = assessments.where((a) => a.isTestOrExam).length;
    final projectCount = assessments.where((a) => a.isProject).length;
    final homeworkCount = assessments.where((a) => a.isHomework).length;
    final practicalCount = assessments.where((a) => a.isPractical).length;
    final formativeCount = assessments.where((a) => a.isFormative).length;

    return Row(
      children: [
        if (testCount > 0) ...[
          _buildTypeChip(context, 'test', testCount, 'Test'),
          const SizedBox(width: 4),
        ],
        if (projectCount > 0) ...[
          _buildTypeChip(context, 'project', projectCount, 'Project'),
          const SizedBox(width: 4),
        ],
        if (homeworkCount > 0) ...[
          _buildTypeChip(context, 'homework', homeworkCount, 'HW'),
          const SizedBox(width: 4),
        ],
        if (practicalCount > 0) ...[
          _buildTypeChip(context, 'practical', practicalCount, 'Practical'),
          const SizedBox(width: 4),
        ],
        if (formativeCount > 0) ...[
          _buildTypeChip(context, 'formative', formativeCount, 'Formative'),
        ],
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context, String type, int count, String displayName) {
    final color = _getAssessmentTypeColor(type);
    final isPlural = count > 1;
    final suffix = isPlural ? 's' : '';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: themeNotifier.getBorderRadiusAll(999),
      ),
      child: Text(
        '$count $displayName$suffix',
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
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
