import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/di/locator.dart';
import '../../services/weighted_average_service.dart';
import '../../models/assessment_models.dart';
import '../../../shared/constants/period_constants.dart';
import '../../views/components/assessment_counts.dart';
import '../../../theme/services/theme_services.dart';

class SubjectAssessmentHeader extends StatelessWidget {
  final SubjectAssessment subject;
  final AcademicYear academicYear;
  final ThemeNotifier themeNotifier;

  const SubjectAssessmentHeader({
    super.key,
    required this.subject,
    required this.academicYear,
    required this.themeNotifier,
  });

  @override
  Widget build(BuildContext context) {
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
            Text(
              '${subject.name.split('.')[0]} ${subject.subject}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 28,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Symbols.school_rounded, size: 16),
                const SizedBox(width: 4),
                Text(subject.name, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                const Icon(Symbols.calendar_month_rounded, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${academicYear.year}-${academicYear.year + 1}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AssessmentCounts(
              assessments: subject.assessments,
              themeNotifier: themeNotifier,
            ),
            ListenableBuilder(
              listenable: di<WeightedAverageService>(),
              builder: (context, _) {
                return FutureBuilder<double?>(
                  future: di<WeightedAverageService>().calculateWeightedAverage(subject),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final wAvg = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.balance_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Weighted Average: ${wAvg.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
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
}
