import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/theme/theme_services.dart';
import '../../../data/models/attendance/course_stats_response.dart';
import '../../attendance/widgets/course_stats_card_content.dart';
import '../error/error_placeholder.dart';

/// Dialog to display course details and attendance statistics
class CourseDetailDialog extends StatelessWidget {
  final String title;
  final String initialSubtitle;
  final Future<({CourseStats stats, String subtitle})> future;

  const CourseDetailDialog({
    super.key,
    required this.title,
    required this.initialSubtitle,
    required this.future,
  });

  /// Show the course detail dialog immediately, rendering a loader while fetching
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String initialSubtitle,
    required Future<({CourseStats stats, String subtitle})> Function() loader,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => CourseDetailDialog(
        title: title,
        initialSubtitle: initialSubtitle,
        future: loader(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return FutureBuilder<({CourseStats stats, String subtitle})>(
      future: future,
      builder: (context, snapshot) {
        // Use dynamic subtitle if data is loaded, otherwise use initial subtitle
        final currentSubtitle = snapshot.hasData 
            ? snapshot.data!.subtitle 
            : initialSubtitle;
            
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: themeNotifier.getBorderRadiusAll(1.5),
          ),
          clipBehavior: Clip.antiAlias,
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
              Text(currentSubtitle, style: textTheme.bodySmall),
            ],
          ),
          content: Builder(
            builder: (context) {
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
              final data = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visual summary using the extracted component
                  CourseStatsCardContent(
                    stats: data.stats,
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
      },
    );
  }
}
