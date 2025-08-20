import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/models/attendance/course_stats_response.dart';
import '../../../services/attendance/course_stats_service.dart';
import '../../../ui/shared/course_detail_dialog.dart';
import '../../../ui/shared/error_placeholder.dart';

class CourseStatsPage extends StatefulWidget {
  const CourseStatsPage({super.key});

  @override
  State<CourseStatsPage> createState() => _CourseStatsPageState();
}

class _CourseStatsPageState extends State<CourseStatsPage> {
  final CourseStatsService _courseStatsService = CourseStatsService();

  List<CourseStats>? _courseStats;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _fetchCourseStats();
  }

  Future<void> _fetchCourseStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await _courseStatsService.fetchCourseStats(
        year: _selectedYear,
      );
      setState(() {
        _courseStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  double _computeAbsentRatePercent(CourseStats stats) {
    if (stats.lessons == 0) return 0.0;
    return (stats.absent / stats.lessons) * 100.0;
  }

  Future<CourseStats> _loadCourseDetail(CourseStats stats) async {
    // Return the stats directly since we already have all the data
    return stats;
  }

  void _showCourseDetail(CourseStats stats) {
    CourseDetailDialog.show(
      context: context,
      title: stats.name,
      subtitle: stats.teachers.isEmpty
          ? 'No teachers assigned'
          : stats.teachers,
      loader: () => _loadCourseDetail(stats),
    );
  }

  Widget _buildYearSelector() {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        children: [
          Text(
            'Academic Year: ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedYear,
              isExpanded: false,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              items: years.map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text('$year-${year + 1}'),
                );
              }).toList(),
              onChanged: (year) {
                if (year != null && year != _selectedYear) {
                  setState(() {
                    _selectedYear = year;
                  });
                  _fetchCourseStats();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(CourseStats stats) {
    final absentRate = _computeAbsentRatePercent(stats);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showCourseDetail(stats),
        borderRadius: BorderRadius.circular(8),
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

              // Stats grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Students',
                      stats.studentCount.toString(),
                      Symbols.people_rounded,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Lessons',
                      stats.lessons.toString(),
                      Symbols.school_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Absent',
                      stats.absent.toString(),
                      Symbols.cancel_rounded,
                      color: stats.absent > 0 ? Colors.red : null,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Late',
                      stats.late.toString(),
                      Symbols.schedule_rounded,
                      color: stats.late > 0 ? Colors.orange : null,
                    ),
                  ),
                ],
              ),

              // Absent rate
              if (stats.lessons > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: absentRate >= 10 ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(4),
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
                        absentRate >= 10 ? Symbols.warning_rounded : Symbols.check_circle_rounded,
                        size: 16,
                        color: absentRate >= 10 ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 4),
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
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(color: color ?? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildYearSelector(),

        if (_isLoading)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading course statistics...'),
                ],
              ),
            ),
          )
        else if (_errorMessage != null)
          Expanded(
            child: Center(
              child: ErrorPlaceholder(
                title: 'Failed to load course statistics',
                errorMessage: _errorMessage!,
                onRetry: _fetchCourseStats,
              ),
            ),
          )
        else if (_courseStats?.isEmpty ?? true)
          const Expanded(
            child: Center(
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
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _courseStats!.length,
              itemBuilder: (context, index) {
                return _buildCourseCard(_courseStats![index]);
              },
            ),
          ),
      ],
    );
  }
}
