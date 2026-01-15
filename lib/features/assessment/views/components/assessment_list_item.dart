import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../models/assessment_models.dart';
import '../../utils/assessment_utils.dart';
import '../../../theme/services/theme_services.dart';
import 'assessment_weight_control.dart';

class AssessmentListItem extends StatelessWidget {
  final Assessment assessment;
  final ThemeNotifier themeNotifier;
  final SubjectAssessment subject;
  final bool showWeights;

  const AssessmentListItem({
    super.key,
    required this.assessment,
    required this.themeNotifier,
    required this.subject,
    this.showWeights = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidScore = assessment.percentageScore != null;
    final scoreColor = hasValidScore
        ? AssessmentUtils.getScoreColor(assessment.percentageScore!)
        : Colors.grey;
    final gradeColor = AssessmentUtils.getGradeColor(assessment.mark);

    return Container(
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
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
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
                                color: AssessmentUtils.getAssessmentTypeColor(
                                  assessment.kind,
                                ).withValues(alpha: 0.2),
                                borderRadius: themeNotifier.getBorderRadiusAll(
                                  999,
                                ),
                              ),
                              child: Text(
                                assessment.kind,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AssessmentUtils.getAssessmentTypeColor(
                                    assessment.kind,
                                  ),
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
                                  borderRadius: themeNotifier
                                      .getBorderRadiusAll(999),
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
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: hasValidScore
                                ? assessment.percentageScore! / 100
                                : 0,
                          ),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                scoreColor,
                              ),
                              trackGap: 10,
                            );
                          },
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            assessment.mark.isNotEmpty
                                ? assessment.mark
                                : 'N/A',
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
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: showWeights
                  ? AssessmentWeightControl(
                      subject: subject,
                      assessment: assessment,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
