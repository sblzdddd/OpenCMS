import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../services/theme/theme_services.dart';
import '../../../data/models/attendance/attendance_response.dart';
import '../../../services/attendance/attendance_service.dart';
import '../../shared/dialog/course_detail_dialog.dart';
import '../../../data/models/attendance/course_stats_response.dart';
import '../../../services/attendance/course_stats_service.dart';
import 'attendance_cards_view.dart';
import 'attendance_table_view.dart';
import '../../shared/views/refreshable_view.dart';
import '../../shared/widgets/custom_scaffold.dart';

class AttendancePageView extends StatefulWidget {
  const AttendancePageView({super.key});

  @override
  State<AttendancePageView> createState() => _AttendancePageViewState();
}

class _AttendancePageViewState extends RefreshableView<AttendancePageView> {
  final AttendanceService _attendanceService = AttendanceService();
  final CourseStatsService _courseStatsService = CourseStatsService();
  AttendanceResponse? _data;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isTableView = false;
  bool _showSettings = false;
  final Set<int> _selectedCourseIds = <int>{};
  List<RecordOfDay>? _sortedDaysCache;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = DateTime(_endDate!.year - 1, 8, 1);
    if(_endDate!.month >= 8 && _endDate!.day >= 1) {
      _startDate = DateTime(_endDate!.year, 8, 1);
    }
  }

  @override
  Future<void> fetchData({bool refresh = false}) async {
    try {
      final resp = await _attendanceService.fetchAttendance(
        startDate: _startDate,
        endDate: _endDate,
        refresh: refresh,
      );
      if (!mounted) return;
      
      // Update data without setState - RefreshableView handles the state
      _data = resp;
      // Build and cache sorted days once per load
      _sortedDaysCache = [...resp.recordOfDays]
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    final data = _data;
    if (data == null || data.recordOfDays.isEmpty) {
      return const Center(child: Text('No attendance records'));
    }

    // Use cached sorted days to avoid re-sorting on every rebuild
    final List<RecordOfDay> days = _sortedDaysCache ??
        ([...data.recordOfDays]..sort((a, b) => b.date.compareTo(a.date)));

    // Compute filtered days depending on view mode and selected courses
    List<RecordOfDay> filteredDays;
    if (_selectedCourseIds.isEmpty) {
      filteredDays = days;
    } else if (_isTableView) {
      // Keep only days that contain at least one absent record for selected courses
      filteredDays = days
          .where(
            (day) => day.attendances.any(
              (e) => e.kind != 0 && _selectedCourseIds.contains(e.courseId),
            ),
          )
          .map((day) {
            final mapped = day.attendances.map((e) {
              if (e.kind == 0) {
                return e; // keep presents
              }
              if (_selectedCourseIds.contains(e.courseId)) {
                return e; // keep selected-course absences
              }
              // Hide other absences by rendering an empty cell
              return AttendanceEntry(
                courseId: 0,
                courseName: '',
                kind: 0,
                reason: '',
                grade: '',
              );
            }).toList();
            return RecordOfDay(
              date: day.date,
              attendances: mapped,
              absentCount: day.absentCount,
              student: day.student,
            );
          })
          .toList();
    } else {
      // Cards view: keep days that have selected-course absences, but zero-out other absence entries
      filteredDays = days
          .where(
            (day) => day.attendances.any(
              (e) => e.kind != 0 && _selectedCourseIds.contains(e.courseId),
            ),
          )
          .map((day) {
            final mapped = day.attendances.map((e) {
              if (e.kind != 0 && !_selectedCourseIds.contains(e.courseId)) {
                // Convert unmatched absence to present so it won't render as a card
                return AttendanceEntry(
                  courseId: e.courseId,
                  courseName: e.courseName,
                  kind: 0,
                  reason: e.reason,
                  grade: e.grade,
                );
              }
              return e;
            }).toList();
            return RecordOfDay(
              date: day.date,
              attendances: mapped,
              absentCount: day.absentCount,
              student: day.student,
            );
          })
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_startDate?.year}-${_endDate?.year} Attendance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              if (_selectedCourseIds.isNotEmpty)
                Text(
                  'Filtered by ${_selectedCourseIds.length} course(s)',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _showSettings ? 0.125 : 0.0, // 45 degrees rotation
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: IconButton(
                  tooltip: 'Toggle settings',
                  icon: Icon(
                    Symbols.settings_rounded,
                    fill: _showSettings ? 1 : 0,
                  ),
                  onPressed: () {
                    setState(() {
                      _showSettings = !_showSettings;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: child,
              );
            },
            child: _showSettings
                ? Column(
                    children: [
                      _buildDatePickers(context),
                      const SizedBox(height: 12),
                      _buildCourseFilter(days),
                      const SizedBox(height: 12),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: _isTableView
                ? AttendanceTableView(
                    days: filteredDays,
                    onEventTap: _onEventTap,
                  )
                : AttendanceCardsView(
                    days: days,
                    onEventTap: _onEventTap,
                    selectedCourseIds: _selectedCourseIds,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  bool get isEmpty => _data?.recordOfDays.isEmpty ?? true;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isTransparent: true,
      body: super.build(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isTableView = !_isTableView;
          });
        },
        tooltip: _isTableView ? 'Switch to Cards View' : 'Switch to Table View',
        child: Icon(
          _isTableView ? Symbols.view_agenda_rounded : Symbols.table_chart_rounded,
        ),
      ),
    );
  }

  @override
  String get errorTitle => 'Failed to load attendance';

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  // Kind text mapping is provided by AttendanceConstants.kindText

  Widget _buildDatePickers(BuildContext context) {
    final String startLabel = _startDate != null
        ? _formatDate(_startDate!)
        : 'Start Date';
    final String endLabel = _endDate != null
        ? _formatDate(_endDate!)
        : 'End Date';
    return Row(
      children: [
        Text('Date Range:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () async {
            final DateTime today = DateTime.now();
            final firstDate = DateTime(today.year - 5, 1, 1);
            final lastDate = DateTime(today.year + 1, 12, 31);
            final picked = await showDatePicker(
              context: context,
              initialDate: _startDate ?? today,
              firstDate: firstDate,
              lastDate: lastDate,
              helpText: 'Select start date',
            );
            if (picked != null && mounted) {
              setState(() {
                _startDate = picked;
              });
              await loadData();
            }
          },
          child: Text(startLabel),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () async {
            final DateTime today = DateTime.now();
            final firstDate = DateTime(today.year - 5, 1, 1);
            final lastDate = DateTime(today.year + 1, 12, 31);
            final picked = await showDatePicker(
              context: context,
              initialDate: _endDate ?? today,
              firstDate: firstDate,
              lastDate: lastDate,
              helpText: 'Select end date',
            );
            if (picked != null && mounted) {
              setState(() {
                _endDate = picked;
              });
              await loadData();
            }
          },
          child: Text(endLabel),
        ),
      ],
    );
  }

  Widget _buildCourseFilter(List<RecordOfDay> days) {
    // Collect unique absent courses from provided days
    final Map<int, String> courseNames = {};
    for (final day in days) {
      for (final e in day.attendances) {
        if (e.kind != 0 && e.courseId != 0 && e.courseName.isNotEmpty) {
          courseNames[e.courseId] = e.subjectName;
        }
      }
    }
    courseNames[0] = "Others";
    final List<MapEntry<int, String>> courses = courseNames.entries.toList()
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Course Filter:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCourseIds.clear();
                });
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in courses)
              FilterChip(
                label: Text(entry.value),
                selected: _selectedCourseIds.contains(entry.key),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedCourseIds.add(entry.key);
                    } else {
                      _selectedCourseIds.remove(entry.key);
                    }
                  });
                },
              ),
            if (courses.isEmpty) const Text('No absent courses in range'),
          ],
        ),
      ],
    );
  }


  Future<void> _onEventTap(AttendanceEntry entry, DateTime date) async {
    debugPrint('AttendancePageView: onEventTap: $entry, ${date.year}');
    if (entry.courseId == 0 || entry.courseName == '') {
      return;
    }
    final title = entry.courseName;

    await CourseDetailDialog.show(
      context: context,
      title: title,
      initialSubtitle: entry.grade,
      loader: () async {
        // Try to find stats across two academic years: [date.year - 1, date.year]
        final int currentYear = date.year;
        final Set<int> neededYears = {currentYear - 1, currentYear};

        final results = <CourseStats>[];

        for (final year in neededYears) {
          final res = await _courseStatsService.fetchCourseStats(year: year);
          results.addAll(res);
        }

        final statsForCourse = results.firstWhere(
          (s) => s.id == entry.courseId,
          orElse: () => throw Exception(
            'Course stats not found for course id ${entry.courseId}.',
          ),
        );
        // Return both stats and the full teacher name from the API
        return (
          stats: statsForCourse,
          subtitle: statsForCourse.teachers,
        );
      },
    );
  }
}

