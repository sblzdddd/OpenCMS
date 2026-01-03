import 'package:flutter/material.dart';
import 'package:silky_scroll/silky_scroll.dart';
import '../../../theme/services/theme_services.dart';
import '../../../shared/constants/period_constants.dart';
import '../../models/course_stats_models.dart';
import '../../services/course_stats_service.dart';
import '../../../shared/views/views/refreshable_view.dart';
import '../widgets/course_stats_card_content.dart';
import '../../../shared/views/academic_year_dropdown.dart';

class CourseStatsView extends StatefulWidget {
  const CourseStatsView({super.key});

  @override
  State<CourseStatsView> createState() => _CourseStatsViewState();
}

class _CourseStatsViewState extends RefreshableView<CourseStatsView> {
  final CourseStatsService _courseStatsService = CourseStatsService();

  List<CourseStats>? _courseStats;
  late AcademicYear _selectedYear;

  @override
  void initState() {
    _selectedYear =
        PeriodConstants.getAcademicYears().first; // Default to current year
    super.initState();
  }

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final stats = await _courseStatsService.fetchCourseStats(
      year: _selectedYear.year,
      refresh: refresh,
    );
    setState(() {
      _courseStats = stats;
    });
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    return Column(
      children: [
        _buildYearSelector(),
        Expanded(child: 
        SilkyScroll(
          scrollSpeed: 2,
          builder: (context, controller, physics) => ListView.builder(
            physics: physics,
            controller: controller,
            itemCount: _courseStats!.length,
            itemBuilder: (context, index) {
              return _buildCourseCard(_courseStats![index]);
            },
          ),
        )),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  String get emptyTitle => 'No course statistics available';

  @override
  String get errorTitle => 'Failed to load course statistics';

  @override
  bool get isEmpty => _courseStats?.isEmpty ?? true;

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AcademicYearDropdown(
            selectedYear: _selectedYear,
            onChanged: (year) => {
              setState(() => _selectedYear = year!),
              fetchData(refresh: true),
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCourseCard(CourseStats stats) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: themeNotifier.getBorderRadiusAll(1),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course name and teachers
            Text(
              stats.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (stats.teachers.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                stats.teachers,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
            const SizedBox(height: 12),
            CourseStatsCardContent(stats: stats),
          ],
        ),
      ),
    );
  }
}
