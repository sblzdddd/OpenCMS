import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../models/assessment_models.dart';
import 'package:opencms/di/locator.dart';
import '../../services/weighted_average_service.dart';

class AssessmentWeightControl extends StatelessWidget {
  final SubjectAssessment subject;
  final Assessment assessment;

  const AssessmentWeightControl({
    super.key,
    required this.subject,
    required this.assessment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
