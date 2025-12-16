import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../theme/services/theme_services.dart';
import '../../models/course_stats_models.dart';
import 'attendance_proportion_chart.dart';

class CourseStatsCardContent extends StatelessWidget {
  final CourseStats stats;

  const CourseStatsCardContent({super.key, required this.stats});

  double _computeAbsentRatePercent(CourseStats stats) {
    if (stats.lessons == 0) return 0.0;
    return (stats.absent / stats.lessons) * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final theme = Theme.of(context);
    final absentRate = _computeAbsentRatePercent(stats);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats grid
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                'Students',
                stats.studentCount.toString(),
                Symbols.people_rounded,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                context,
                'Lessons',
                stats.lessons.toString(),
                Symbols.school_rounded,
              ),
            ),
          ],
        ),
        // Absent rate
        if (stats.lessons > 0) ...[
          const SizedBox(height: 16),
          AttendanceProportionChart(stats: stats),
          const Divider(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: absentRate >= 10
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.tertiaryContainer,
              borderRadius: themeNotifier.getBorderRadiusAll(0.5),
              border: Border.all(
                color: absentRate >= 10
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.tertiaryContainer,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  absentRate >= 10
                      ? Symbols.warning_rounded
                      : Symbols.check_circle_rounded,
                  size: 16,
                  color: absentRate >= 10
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : Theme.of(context).colorScheme.onTertiaryContainer,
                ),
                Text(
                  'Absent rate: ${absentRate.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: absentRate >= 10
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color:
              color ??
              Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color:
                color ??
                Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
