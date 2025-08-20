import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import '../../../data/constants/period_constants.dart';
import '../../../data/models/timetable/timetable_response.dart';
import '../../../services/timetable/course_timetable_service.dart';
import '../../../ui/timetable/components/day_tabs.dart';
// import '../../../ui/timetable/components/timetable_table_view.dart';
import '../../../ui/timetable/components/timetable_mobile_view.dart';
import '../../../services/attendance/course_stats_service.dart';
import '../../../data/models/attendance/course_stats_response.dart';
import '../../../ui/shared/course_detail_dialog.dart';
import '../../../ui/shared/error_placeholder.dart';

class CourseTimetablePage extends StatefulWidget {
  final AcademicYear selectedYear;

  const CourseTimetablePage({super.key, required this.selectedYear});

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
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(
      renderObject,
    );
    final RevealedOffset revealed = viewport.getOffsetToReveal(
      renderObject,
      0.0,
    );
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
      final dateString = DateFormat('yyyy-MM-dd').format(today);

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
    _dayDates = List.generate(
      5,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ErrorPlaceholder(
        title: 'Failed to load timetable',
        errorMessage: _errorMessage!,
        onRetry: _loadTimetable,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            DayTabs(
              controller: _dayTabController,
              onTap: _onTabTapped,
              labels: PeriodConstants.weekdayShortNames.sublist(0, 5),
              todayIndex: _todayIndex,
            ),
            Expanded(
              child: TimetableMobileView(
                scrollController: _scrollController,
                dayDates: _dayDates,
                todayIndex: _todayIndex,
                selectedDayIndex: _selectedDayIndex,
                dayKeys: _dayKeys,
                timetableData: _timetableData,
                onEventTap: _onEventTap,
              ),
            ),
          ],
        );
      },
    );
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
        _cachedCourseStats ??= await _courseStatsService.fetchCourseStats(
          year: widget.selectedYear.year,
        );
        final statsForCourse = _cachedCourseStats!.firstWhere(
          (s) => s.id == event.id,
          orElse: () => throw Exception(
            'Course stats not found for course id ${event.id}.',
          ),
        );
        return statsForCourse;
      },
    );
  }
}
