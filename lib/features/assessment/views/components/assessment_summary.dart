import 'package:flutter/material.dart';
import '../../models/assessment_models.dart';
import '../../utils/assessment_utils.dart';
import 'package:opencms/di/locator.dart';
import '../../services/weighted_average_service.dart';
import 'assessment_chart.dart';
import '../../../theme/services/theme_services.dart';

class AssessmentSummary extends StatelessWidget {
  final SubjectAssessment subject;
  final ThemeNotifier themeNotifier;

  const AssessmentSummary({
    super.key,
    required this.subject,
    required this.themeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final validAssessments = subject.assessments
        .where((a) => a.percentageScore != null)
        .toList();

    if (validAssessments.isEmpty) {
      return const SizedBox.shrink();
    }

    final scores = validAssessments.map((a) => a.percentageScore!).toList();
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;
    final highestScore = scores.reduce((a, b) => a > b ? a : b);
    final lowestScore = scores.reduce((a, b) => a < b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: themeNotifier.getBorderRadiusAll(1),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.01),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.02),
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
        child: Column(
          children: [
            ListenableBuilder(
              listenable: di<WeightedAverageService>(),
              builder: (context, _) {
                return FutureBuilder<double?>(
                  future: di<WeightedAverageService>().calculateWeightedAverage(
                    subject,
                  ),
                  builder: (context, snapshot) {
                    final weightedAvg = snapshot.data;

                    return Row(
                      children: [
                        if (weightedAvg != null)
                          Expanded(
                            child: _buildSummaryCard(
                              context,
                              'Weighted Avg',
                              '${weightedAvg.toStringAsFixed(1)}%',
                              AssessmentUtils.getScoreColor(weightedAvg),
                              icon: Icons.scale_rounded,
                            ),
                          )
                        else
                          Expanded(
                            child: _buildSummaryCard(
                              context,
                              'Average',
                              '${averageScore.toStringAsFixed(1)}%',
                              AssessmentUtils.getScoreColor(averageScore),
                            ),
                          ),
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            'Highest',
                            '${highestScore.toStringAsFixed(1)}%',
                            AssessmentUtils.getScoreColor(highestScore),
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            'Lowest',
                            '${lowestScore.toStringAsFixed(1)}%',
                            AssessmentUtils.getScoreColor(lowestScore),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssessmentChart(
                  assessments: subject.assessments,
                  subjectName: subject.subject,
                  subjectId: subject.id,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    Color color, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              if (icon != null) const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
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
    );
  }
}
