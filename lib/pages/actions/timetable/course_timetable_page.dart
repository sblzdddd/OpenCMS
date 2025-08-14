import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../data/constants/period_constants.dart';
import '../../../data/models/timetable/timetable_response.dart';
import '../../../services/timetable/course_timetable_service.dart';
import '../../../ui/shared/timetable_card.dart';
import '../../../data/models/timetable/course_merged_event.dart';
import 'widgets/day_tabs.dart';
import 'widgets/day_header.dart';
import '../../../services/attendance/course_stats_service.dart';
import '../../../data/models/attendance/course_stats_response.dart';
import '../../../ui/shared/course_detail_dialog.dart';

class CourseTimetablePage extends StatefulWidget {
  final AcademicYear selectedYear;

  const CourseTimetablePage({
    super.key,
    required this.selectedYear,
  });

  @override
  State<CourseTimetablePage> createState() => _CourseTimetablePageState();
}

class _CourseTimetablePageState extends State<CourseTimetablePage>
    with SingleTickerProviderStateMixin {
  late TabController _dayTabController;
  final CourseTimetableService _timetableService = CourseTimetableService();
  final CourseStatsService _courseStatsService = CourseStatsService();
  late final ScrollController _scrollController;
  final List<GlobalKey> _dayKeys = List.generate(5, (_) => GlobalKey());
  bool _isAnimatingToTab = false;
  
  TimetableResponse? _timetableData;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedDayIndex = 0;
  List<DateTime> _dayDates = const [];
  int _todayIndex = -1;
  List<CourseStats>? _cachedCourseStats;

  @override
  void initState() {
    super.initState();
    _dayTabController = TabController(length: 5, vsync: this);
    _dayTabController.addListener(_onDayTabChanged);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadTimetable();
  }

  @override
  void dispose() {
    _dayTabController.removeListener(_onDayTabChanged);
    _dayTabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CourseTimetablePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear.year != widget.selectedYear.year) {
      _cachedCourseStats = null;
      _loadTimetable();
    }
  }

  void _onDayTabChanged() {
    if (!mounted) return;
    if (!_dayTabController.indexIsChanging) {
      setState(() {
        _selectedDayIndex = _dayTabController.index;
      });
    }
  }

  void _onScroll() {
    if (!mounted) return;
    if (_isAnimatingToTab) return;
    if (!_scrollController.hasClients) return;

    const double triggerOffset = 32.0;
    final double currentOffset = _scrollController.offset;
    int newIndex = 0;

    for (int i = 0; i < _dayKeys.length; i++) {
      final headerOffset = _getHeaderOffset(i);
      if (headerOffset == null) continue;
      if (headerOffset - currentOffset <= triggerOffset) {
        newIndex = i;
      } else {
        break;
      }
    }

    if (newIndex != _selectedDayIndex) {
      setState(() {
        _selectedDayIndex = newIndex;
      });
      if (_dayTabController.index != newIndex) {
        _dayTabController.animateTo(newIndex);
      }
    }
  }

  double? _getHeaderOffset(int index) {
    if (index < 0 || index >= _dayKeys.length) return null;
    final ctx = _dayKeys[index].currentContext;
    if (ctx == null) return null;
    final RenderObject renderObject = ctx.findRenderObject()!;
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
    final RevealedOffset revealed = viewport.getOffsetToReveal(renderObject, 0.0);
    return revealed.offset;
  }

  Future<void> _onTabTapped(int index) async {
    if (index < 0 || index >= _dayKeys.length) return;
    if (mounted) {
      setState(() {
        _selectedDayIndex = index;
      });
    }
    _isAnimatingToTab = true;
    try {
      final headerOffset = _getHeaderOffset(index);
      if (headerOffset != null && _scrollController.hasClients) {
        await _scrollController.animateTo(
          headerOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          final offsetAfter = _getHeaderOffset(index);
          if (offsetAfter != null && _scrollController.hasClients) {
            await _scrollController.animateTo(
              offsetAfter,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    } finally {
      _isAnimatingToTab = false;
    }
  }

  Future<void> _loadTimetable() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use today's date for the API call
      final today = DateTime.now();
      final dateString = '${today.year.toString().padLeft(4, '0')}-'
          '${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';

      final timetable = await _timetableService.fetchCourseTimetable(
        year: widget.selectedYear.year,
        date: dateString,
      );

      if (!mounted) return;
      setState(() {
        _timetableData = timetable;
        _isLoading = false;
        _computeWeekDates();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  DateTime? _parseMondayDate(String mondayStr) {
    try {
      // Expect formats like yyyy-mm-dd or yyyy-m-d
      final parts = mondayStr.split('-');
      if (parts.length != 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  void _computeWeekDates() {
    _dayDates = const [];
    _todayIndex = -1;
    final data = _timetableData;
    if (data == null) return;
    final monday = _parseMondayDate(data.monday);
    if (monday == null) return;
    _dayDates = List.generate(5, (i) => DateTime(monday.year, monday.month, monday.day + i));
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    for (int i = 0; i < _dayDates.length; i++) {
      final d = _dayDates[i];
      final dOnly = DateTime(d.year, d.month, d.day);
      if (dOnly == todayDateOnly) {
        _todayIndex = i;
        break;
      }
    }
  }

  String _formatYmd(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString();
    final d = date.day.toString();
    return '$y-$m-$d';
  }

  List<CourseMergedEvent> _getCourseMergedEventsForDay(int dayIndex) {
    if (_timetableData == null || 
        dayIndex >= _timetableData!.weekdays.length) {
      return [];
    }

    final weekday = _timetableData!.weekdays[dayIndex];
    final List<CourseMergedEvent> mergedEvents = [];
    
    int i = 0;
    while (i < weekday.periods.length) {
      final period = weekday.periods[i];
      
      if (period.events.isEmpty) {
        i++;
        continue;
      }

      final event = period.events.first;
      int endPeriod = i;
      
      // Find consecutive periods with the same event
      while (endPeriod + 1 < weekday.periods.length) {
        final nextPeriod = weekday.periods[endPeriod + 1];
        if (nextPeriod.events.isEmpty || 
            nextPeriod.events.first != event) {
          break;
        }
        endPeriod++;
      }

      mergedEvents.add(CourseMergedEvent(
        event: event,
        startPeriod: i,
        endPeriod: endPeriod,
      ));

      i = endPeriod + 1;
    }

    return mergedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DayTabs(
          controller: _dayTabController,
          onTap: _onTabTapped,
          labels: PeriodConstants.weekdayShortNames,
          todayIndex: _todayIndex,
        ),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
            const SizedBox(height: 16),
            Text(
              'Failed to load timetable',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTimetable,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int dayIndex = 0; dayIndex < 5; dayIndex++) ...[
            DayHeader(
              key: _dayKeys[dayIndex],
              title: PeriodConstants.weekdayNames[dayIndex],
              dateText: (_dayDates.isNotEmpty && dayIndex < _dayDates.length)
                  ? _formatYmd(_dayDates[dayIndex])
                  : '',
              isActive: dayIndex == _selectedDayIndex,
              isToday: _todayIndex == dayIndex,
            ),
            const SizedBox(height: 8),
            ..._buildDayEvents(dayIndex),
            const SizedBox(height: 16),
            if (dayIndex != 4) const Divider(height: 32),
            if (dayIndex != 4) const SizedBox(height: 8),
          ],
          const SizedBox(height: 400),
        ],
      ),
    );
  }

  List<Widget> _buildDayEvents(int dayIndex) {
    final mergedEvents = _getCourseMergedEventsForDay(dayIndex);
    if (mergedEvents.isEmpty) {
      return [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              'No classes scheduled',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        )
      ];
    }
    return [
      for (final mergedEvent in mergedEvents) ...[
        TimetableCard(
          subject: mergedEvent.event.subject,
          code: mergedEvent.event.code,
          room: mergedEvent.event.room.isNotEmpty ? mergedEvent.event.room : 'TBA',
          extraInfo: mergedEvent.event.teacher.isNotEmpty ? mergedEvent.event.teacher : '',
          timespan: mergedEvent.timeSpan,
          periodText: mergedEvent.periodText,
          onTap: () {
            _onEventTap(mergedEvent.event);
          },
        ),
        const SizedBox(height: 12),
      ]
    ];
  }

  Future<void> _onEventTap(TimetableEvent event) async {
    if (event.type != 1) {
      // TODO: show ECA details and other info
      return;
    }

    final title = event.subject;
    final subtitle = event.code;

    await CourseDetailDialog.show(
      context: context,
      title: title,
      subtitle: subtitle,
      loader: () async {
        _cachedCourseStats ??= await _courseStatsService.fetchCourseStats(year: widget.selectedYear.year);
        final statsForCourse = _cachedCourseStats!.firstWhere(
          (s) => s.id == event.id,
          orElse: () => throw Exception('Course stats not found for course id ${event.id}.'),
        );
        return statsForCourse;
      },
    );
  }
}
