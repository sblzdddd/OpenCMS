import 'package:flutter/material.dart';
import '../../../data/constants/period_constants.dart';
import '../../../data/models/attendance/attendance_response.dart';
import '../../../services/attendance/attendance_service.dart';
import '../../../ui/shared/timetable_card.dart';
import '../../../data/constants/attendance_constants.dart';
import '../../../ui/shared/course_detail_dialog.dart';
import '../../../data/models/attendance/course_stats_response.dart';
import '../../../services/attendance/course_stats_service.dart';

class AttendancePageMain extends StatefulWidget {
  const AttendancePageMain({
    super.key,
  });

  @override
  State<AttendancePageMain> createState() => _AttendancePageMainState();
}

class _AttendancePageMainState extends State<AttendancePageMain> {
  final AttendanceService _attendanceService = AttendanceService();
  final CourseStatsService _courseStatsService = CourseStatsService();
  AttendanceResponse? _data;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _startDate;
  DateTime? _endDate;
  List<CourseStats>? _cachedCourseStats;
  final Set<int> _cachedCourseStatsYears = {};

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = DateTime(_endDate!.year - 1, _endDate!.month, _endDate!.day);
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final resp = await _attendanceService.fetchAttendance(
        startDate: _startDate,
        endDate: _endDate,
      );
      if (!mounted) return;
      setState(() {
        _data = resp;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  // Kind text mapping is provided by AttendanceConstants.kindText

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text('Failed to load attendance'),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadAttendance,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }
    final data = _data;
    if (data == null || data.recordOfDays.isEmpty) {
      return const Center(child: Text('No attendance records'));
    }

    // Sort days by date descending
    final days = [...data.recordOfDays]..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDatePickers(context),
          const SizedBox(height: 12),
          for (final day in days) ...[
            _buildDaySection(day),
            const SizedBox(height: 16),
            const Divider(height: 32),
            const SizedBox(height: 8),
          ]
        ],
      ),
    );
  }

  Widget _buildDatePickers(BuildContext context) {
    final String startLabel = _startDate != null ? _formatDate(_startDate!) : 'Start Date';
    final String endLabel = _endDate != null ? _formatDate(_endDate!) : 'End Date';
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
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
                await _loadAttendance();
              }
            },
            child: Text(startLabel),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
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
                await _loadAttendance();
              }
            },
            child: Text(endLabel),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySection(RecordOfDay day) {
    final periods = PeriodConstants.attendancePeriods;
    final atts = day.attendances;
    final int count = atts.length < periods.length ? atts.length : periods.length;

    final List<Widget> cards = [];
    int i = 0;
    while (i < count) {
      final startEntry = atts[i];
      if (startEntry.kind == 0) {
        i++;
        continue;
      }

      int endIndex = i;
      while (endIndex + 1 < count) {
        final nextEntry = atts[endIndex + 1];
        if (nextEntry.kind != 0 &&
            nextEntry.courseId == startEntry.courseId &&
            nextEntry.kind == startEntry.kind &&
            nextEntry.reason == startEntry.reason &&
            nextEntry.grade == startEntry.grade) {
          endIndex++;
          continue;
        }
        break;
      }

      final startP = periods[i];
      final endP = periods[endIndex];
      final String timespan = '${startP.startTime} - ${endP.endTime}';
      final String periodText = startP.name == endP.name ? startP.name : '${startP.name} - ${endP.name}';
      final String subject = startEntry.subjectName;
      final String code = startEntry.reason;
      final String room = AttendanceConstants.kindText[startEntry.kind] ?? 'Unknown';
      final String extra = startEntry.grade;

      cards.add(TimetableCard(
        subject: subject,
        code: code,
        room: room,
        extraInfo: extra,
        timespan: timespan,
        periodText: periodText,
        backgroundColor: AttendanceConstants.kindBackgroundColor[startEntry.kind],
        textColor: AttendanceConstants.kindTextColor[startEntry.kind],
        onTap: () {
          _onEventTap(startEntry, day.date);
        },
      ));
      cards.add(const SizedBox(height: 12));

      i = endIndex + 1;
    }

    if (cards.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(_formatDate(day.date), style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text('No attendance issues'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(day.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Text('${day.absentCount.toStringAsFixed(1)} day'),
          ],
        ),
        const SizedBox(height: 8),
        ...cards,
      ],
    );
  }

  
  Future<void> _onEventTap(AttendanceEntry entry, DateTime date) async {
    print('onEventTap: $entry, ${date.year}');
    if (entry.courseId == 0 || entry.courseName == '') {
      return;
    }
    final title = entry.courseName;
    final subtitle = entry.reason;

    await CourseDetailDialog.show(
      context: context,
      title: title,
      subtitle: subtitle,
      loader: () async {
        // Try to find stats across two academic years: [date.year - 1, date.year]
        final int currentYear = date.year;
        final Set<int> neededYears = {currentYear - 1, currentYear};

        // Initialize cache container if needed
        _cachedCourseStats ??= <CourseStats>[];

        // Determine which years are missing from cache
        final Set<int> missingYears = neededYears.difference(_cachedCourseStatsYears);

        if (missingYears.isNotEmpty) {
          // Fetch all missing years concurrently and merge into cache
          final results = await Future.wait(
            missingYears.map((y) => _courseStatsService.fetchCourseStats(year: y)),
          );
          _cachedCourseStats!.addAll(results.expand((e) => e));
          _cachedCourseStatsYears.addAll(missingYears);
        }

        final statsForCourse = _cachedCourseStats!.firstWhere(
          (s) => s.id == entry.courseId,
          orElse: () => throw Exception('Course stats not found for course id ${entry.courseId}.'),
        );
        return statsForCourse;
      },
    );
  }
}

