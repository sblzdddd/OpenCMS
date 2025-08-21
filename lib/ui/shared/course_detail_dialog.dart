import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../data/models/attendance/course_stats_response.dart';
import 'error_placeholder.dart';

/// Dialog to display course details and attendance statistics
class CourseDetailDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final Future<CourseStats> future;

  const CourseDetailDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.future,
  });

  /// Show the course detail dialog immediately, rendering a loader while fetching
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Future<CourseStats> Function() loader,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => CourseDetailDialog(
        title: title,
        subtitle: subtitle,
        future: loader(),
      ),
    );
  }

  double _computeAbsentRatePercent(CourseStats s) {
    if (s.lessons == 0) return 0.0;
    return (s.absent / s.lessons) * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: textTheme.bodySmall),
        ],
      ),
      content: FutureBuilder<CourseStats>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: 240,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Loading course details...'),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return SizedBox(
              width: 300,
              child: ErrorPlaceholder(
                title: 'Failed to load course details',
                errorMessage: snapshot.error.toString(),
                onRetry: () => future,
              ),
            );
          }
          final stats = snapshot.data!;
          final absentRate = _computeAbsentRatePercent(stats);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow(
                'Teacher',
                stats.teachers.isEmpty ? '—' : stats.teachers,
                textTheme,
                context,
                icon: Symbols.person_book_rounded,
              ),
              _buildRow(
                'Students',
                stats.studentCount.toString(),
                textTheme,
                context,
                icon: Symbols.people_rounded,
              ),
              const SizedBox(height: 8),
              _buildRow(
                'Lessons',
                stats.lessons.toString(),
                textTheme,
                context,
                icon: Symbols.school_rounded,
              ),
              _buildRow('Absent', stats.absent.toString(), textTheme, context,
                icon: Symbols.person_remove,
              ),
              _buildRow(
                'Unapproved',
                stats.unapproved.toString(),
                textTheme,
                context,
                icon: Symbols.cancel_rounded,
              ),
              _buildRow('Late', stats.late.toString(), textTheme, context,
                icon: Symbols.schedule_rounded,
              ),
              _buildRow(
                'Approved',
                stats.approved.toString(),
                textTheme,
                context,
                icon: Symbols.person_add,
              ),
              _buildRow('Sick', stats.sick.toString(), textTheme, context,
                icon: Symbols.sick_rounded,
              ),
              _buildRow('School', stats.school.toString(), textTheme, context,
                icon: Symbols.school_rounded,
              ),
              const Divider(height: 16),
              _buildRow(
                'Absent rate',
                '${absentRate.toStringAsFixed(1)}%',
                textTheme,
                context,
                valueStyle: textTheme.bodyMedium?.copyWith(
                  color: absentRate >= 10 ? Theme.of(context).colorScheme.onErrorContainer : 
                  Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                icon: Symbols.percent_rounded,
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildRow(
    String label,
    String value,
    TextTheme textTheme,
    BuildContext context, {
    TextStyle? valueStyle,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(value, style: valueStyle ?? textTheme.bodyMedium),
        ],
      ),
    );
  }
}
