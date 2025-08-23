import 'package:flutter/material.dart';
import '../../../data/models/attendance/course_stats_response.dart';
import '../../attendance/widgets/course_stats_card_content.dart';
import '../error/error_placeholder.dart';

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
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual summary using the extracted component
              CourseStatsCardContent(
                stats: stats,
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
}
