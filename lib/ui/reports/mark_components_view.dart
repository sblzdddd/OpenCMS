import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/theme/theme_services.dart';
import '../../data/models/reports/reports.dart';

class MarkComponentsView extends StatelessWidget {
  final List<MarkComponent> markComponents;

  const MarkComponentsView({
    super.key,
    required this.markComponents,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    if (markComponents.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group components by syllabus
    final Map<String, List<MarkComponent>> groupedBySyllabus = {};
    for (final component in markComponents) {
      final key = '${component.board} - ${component.syllabus}';
      groupedBySyllabus.putIfAbsent(key, () => []).add(component);
    }

    // Get totals from component with empty component name (total item)
    final Map<String, Map<String, dynamic>> syllabusTotals = {};
    for (final entry in groupedBySyllabus.entries) {
      final components = entry.value;
      final totalComponent = components.firstWhere(
        (component) => component.component.isEmpty,
        orElse: () => components.last, // fallback to last if no empty component found
      );
      
      syllabusTotals[entry.key] = {
        'totalMark': totalComponent.finalMark,
        'averageGrade': totalComponent.grade,
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Mark Components',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Syllabus Groups
        ...groupedBySyllabus.entries.map((entry) {
          final syllabusKey = entry.key;
          final components = entry.value;
          final firstComponent = components.first;
          final total = syllabusTotals[syllabusKey]!;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: themeNotifier.getBorderRadiusAll(0),
            ),
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Syllabus Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: themeNotifier.getBorderRadiusTop(0.75),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstComponent.syllabus,
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${firstComponent.board} - ${firstComponent.syllabusCode}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                       children: [
                         // Component
                         Expanded(
                           flex: 2,
                           child: Text(
                             'Component',
                             style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                             ),
                           ),
                         ),
                         // Paper Mark
                         Expanded(
                           flex: 1,
                           child: Text(
                             'Adjusted',
                             textAlign: TextAlign.center,
                             style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                             ),
                           ),
                         ),
                         // Weighted Mark
                         Expanded(
                           flex: 1,
                           child: Text(
                             'Final',
                             textAlign: TextAlign.center,
                             style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                             ),
                           ),
                         ),
                         // Grade
                         Expanded(
                           flex: 1,
                           child: Text(
                             'Grade',
                             textAlign: TextAlign.center,
                             style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                             ),
                           ),
                         ),
                       ],
                     ),
                    ],
                  ),
                ),
                                 // Components List (excluding the total item which has empty component name)
                 ...components.where((component) => component.component.isNotEmpty).map((component) {
                   return Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       border: Border(
                         bottom: BorderSide(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)),
                       ),
                     ),
                     child: Row(
                       children: [
                         // Component
                         Expanded(
                           flex: 2,
                           child: Text(
                             component.component,
                             style: const TextStyle(fontWeight: FontWeight.w500),
                           ),
                         ),
                         // Paper Mark
                         Expanded(
                           flex: 1,
                           child: Text(
                             component.adjustedMark,
                             textAlign: TextAlign.center,
                             style: const TextStyle(fontWeight: FontWeight.w500),
                           ),
                         ),
                         // Weighted Mark
                         Expanded(
                           flex: 1,
                           child: Text(
                             component.finalMark,
                             textAlign: TextAlign.center,
                             style: const TextStyle(fontWeight: FontWeight.w500),
                           ),
                         ),
                         // Grade
                         Expanded(
                           flex: 1,
                           child: Text(
                             component.grade,
                             textAlign: TextAlign.center,
                             style: const TextStyle(fontWeight: FontWeight.w500),
                           ),
                         ),
                       ],
                     ),
                   );
                 }),
                // Syllabus Total
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: themeNotifier.getBorderRadiusBottom(0.75),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Syllabus Total',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          total['totalMark']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          total['averageGrade']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}
