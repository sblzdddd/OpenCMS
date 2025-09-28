import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../services/theme/theme_services.dart';
import '../../../data/constants/periods.dart';
import '../../../data/models/attendance/course_stats_response.dart';
import '../../../services/attendance/course_stats_service.dart';
import '../../shared/views/refreshable_view.dart';
import '../widgets/course_stats_card_content.dart';
import '../../shared/academic_year_dropdown.dart';

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
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _courseStats!.length,
            itemBuilder: (context, index) {
              return _buildCourseCard(_courseStats![index]);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget buildEmptyWidget(BuildContext context, ThemeNotifier themeNotifier) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Symbols.school_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No course statistics available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Try selecting a different academic year',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
            onChanged: (year) => {setState(() => _selectedYear = year!), fetchData(refresh: true)},
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCourseCard(CourseStats stats) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: themeNotifier.needTransparentBG ? (!themeNotifier.isDarkMode
          ? Theme.of(context).colorScheme.surfaceBright.withValues(alpha: 0.5)
          : Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.8))
      : Theme.of(context).colorScheme.surfaceContainer,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1),
      ),
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
