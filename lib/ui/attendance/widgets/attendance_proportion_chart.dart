import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/theme/theme_services.dart';
import '../../../data/models/attendance/course_stats_response.dart';
import '../../../data/constants/attendance_types.dart';

/// Widget to display attendance proportion chart
class AttendanceProportionChart extends StatelessWidget {
  final CourseStats stats;

  const AttendanceProportionChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final totalLessons = stats.lessons;
    if (totalLessons == 0) return const SizedBox.shrink();

    // Calculate attendance counts for each type
    final presentCount = totalLessons - stats.absent - stats.late;
    final unapprovedCount = stats.absent;
    final lateCount = stats.late;

    // Create segments for available data
    final segments = <_AttendanceSegment>[];

    if (presentCount > 0) {
      segments.add(
        _AttendanceSegment(
          count: presentCount,
          percentage: (presentCount / totalLessons) * 100,
          color: AttendanceConstants.kindBackgroundColor[0]!,
          label: 'Present',
        ),
      );
    }

    if (unapprovedCount > 0) {
      segments.add(
        _AttendanceSegment(
          count: unapprovedCount,
          percentage: (unapprovedCount / totalLessons) * 100,
          color: AttendanceConstants.kindBackgroundColor[2]!,
          label: 'Unapproved',
        ),
      );
    }

    if (lateCount > 0) {
      segments.add(
        _AttendanceSegment(
          count: lateCount,
          percentage: (lateCount / totalLessons) * 100,
          color: AttendanceConstants.kindBackgroundColor[1]!,
          label: 'Late',
        ),
      );
    }

    if (segments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: themeNotifier.getBorderRadiusAll(0.25),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            children: segments.map((segment) {
              return Expanded(
                flex: (segment.percentage * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: segment.color,
                    borderRadius: themeNotifier.getBorderRadiusAll(0.125),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: segments.map((segment) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: segment.color,
                    borderRadius: themeNotifier.getBorderRadiusAll(0.125),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${segment.label} (${segment.count})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Helper class to represent attendance segments for the proportion chart
class _AttendanceSegment {
  final int count;
  final double percentage;
  final Color color;
  final String label;

  const _AttendanceSegment({
    required this.count,
    required this.percentage,
    required this.color,
    required this.label,
  });
}
