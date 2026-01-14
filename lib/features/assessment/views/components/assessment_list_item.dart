import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../models/assessment_models.dart';
import '../../utils/assessment_utils.dart';
import '../../../theme/services/theme_services.dart';
import 'package:opencms/di/locator.dart';
import '../../services/weighted_average_service.dart';

class AssessmentListItem extends StatelessWidget {
  final Assessment assessment;
  final ThemeNotifier themeNotifier;
  final SubjectAssessment subject;

  const AssessmentListItem({
    super.key,
    required this.assessment,
    required this.themeNotifier,
    required this.subject,
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
            Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
              child: Divider(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            ListenableBuilder(
              listenable: di<WeightedAverageService>(),
              builder: (context, _) {
                return FutureBuilder<int>(
                  future: di<WeightedAverageService>().getWeight(
                    subject.id,
                    assessment,
                  ),
                  builder: (context, snapshot) {
                    final weight = snapshot.data ?? 0;
                    return InkWell(
                      onTap: () => _showWeightPicker(context, weight),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.scale_rounded,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Weight: $weight%",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Symbols.arrow_drop_down_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showWeightPicker(
    BuildContext context,
    int currentWeight,
  ) async {
    const allWeights = [0, 5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100];

    final totalUsed = await di<WeightedAverageService>().getTotalWeightUsed(
      subject,
    );
    final otherWeights = totalUsed - currentWeight;

    int maxAllowed = 100 - otherWeights;

    if (maxAllowed < 0) maxAllowed = 0;

    final weights = allWeights.where((w) => w <= maxAllowed).toList();
    if (weights.isEmpty) {
      if (maxAllowed < 0) {
        weights.add(0);
      }
    }

    if (!context.mounted) return;

    int initialIndex = weights.indexOf(currentWeight);
    if (initialIndex == -1) {
      initialIndex = weights.length - 1;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Select Weight (Max: $maxAllowed%)",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.3,
                    physics: const FixedExtentScrollPhysics(),
                    controller: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    onSelectedItemChanged: (index) {
                      di<WeightedAverageService>().setWeight(
                        subject.id,
                        assessment,
                        weights[index],
                      );
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: weights.length,
                      builder: (context, index) {
                        return Center(
                          child: Text(
                            "${weights[index]}%",
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
