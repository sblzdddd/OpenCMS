import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import '../../../data/constants/period_constants.dart';
import '../../../data/models/timetable/timetable_response.dart';
import '../../../services/timetable/course_timetable_service.dart';
import '../components/day_tabs.dart';
import 'timetable_mobile_view.dart';
import 'timetable_calendar_view.dart';
import '../../../services/attendance/course_stats_service.dart';
import '../../shared/dialog/course_detail_dialog.dart';
import '../../shared/views/refreshable_view.dart';

enum _TimetableViewMode { mobile, calendar }

class CourseTimetableView extends StatefulWidget {
  final AcademicYear selectedYear;

  const CourseTimetableView({super.key, required this.selectedYear});

  @override
  State<CourseTimetableView> createState() => _CourseTimetableViewState();
}

class _CourseTimetableViewState extends RefreshableView<CourseTimetableView>
    with SingleTickerProviderStateMixin {
  late TabController _dayTabController;
  final CourseTimetableService _timetableService = CourseTimetableService();
  final CourseStatsService _courseStatsService = CourseStatsService();
  late final ScrollController _scrollController;
  final List<GlobalKey> _dayKeys = List.generate(5, (_) => GlobalKey());
  bool _isAnimatingToTab = false;

  TimetableResponse? _timetableData;
  int _selectedDayIndex = 0;
  List<DateTime> _dayDates = const [];
  int _todayIndex = -1;
  _TimetableViewMode _viewMode = _TimetableViewMode.mobile;

  @override
  void initState() {
    super.initState();
    _dayTabController = TabController(length: 5, vsync: this);
    _dayTabController.addListener(_onDayTabChanged);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
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
  void didUpdateWidget(CourseTimetableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear.year != widget.selectedYear.year) {
      loadData();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToToday();
      });
    }
  }

  bool _areDayKeysReady() {
    return _dayKeys.every((key) => key.currentContext != null);
  }

  void _scrollToToday() {
    if (!mounted) {
      print('Warning: _scrollToToday called but widget is not mounted');
      return;
    }
    if (_todayIndex >= 0 && _todayIndex < _dayKeys.length) {
      // Ensure the widget tree is built before attempting to scroll
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _areDayKeysReady()) {
          _scrollToDay(_todayIndex, jump: true);
          _dayTabController.animateTo(_todayIndex);
        } else if (mounted) {
          // Retry after a short delay if keys aren't ready
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && _areDayKeysReady()) {
              _scrollToDay(_todayIndex, jump: true);
              _dayTabController.animateTo(_todayIndex);
            }
          });
        }
      });
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

    try {
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
    } catch (e) {
      print('Error in scroll listener: $e');
    }
  }

  double? _getHeaderOffset(int index) {
    if (index < 0 || index >= _dayKeys.length) return null;
    
    final ctx = _dayKeys[index].currentContext;
    if (ctx == null) return null;
    
    try {
      final RenderObject? renderObject = ctx.findRenderObject();
      if (renderObject == null) return null;
      
      final RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
      
      final RevealedOffset revealed = viewport.getOffsetToReveal(
        renderObject,
        0.0,
      );
      return revealed.offset;
    } catch (e) {
      print('Error getting header offset for index $index: $e');
      return null;
    }
  }

  Future<void> _scrollToDay(int index, {bool jump = false}) async {
    if (index < 0 || index >= _dayKeys.length) return;
    if (mounted) {
      setState(() {
        _selectedDayIndex = index;
      });
    }
    
    // Wait for the next frame to ensure the widget tree is built
    await Future.delayed(Duration.zero);
    
    // Check if day keys are ready
    if (!_areDayKeysReady()) {
      print('Day keys are not ready yet, skipping scroll');
      return;
    }
    
    _isAnimatingToTab = true;
    try {
      // Check if scroll controller has clients
      if (!_scrollController.hasClients) {
        print('Scroll controller has no clients, skipping scroll');
        return;
      }
      
      // Get header offset
      final headerOffset = _getHeaderOffset(index);
      if (headerOffset == null) {
        print('Header offset is null for index $index, skipping scroll');
        return;
      }
      
      // Perform the scroll
      if (jump) {
        _scrollController.jumpTo(headerOffset);
      } else {
        await _scrollController.animateTo(
          headerOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      print('Error scrolling to day $index: $e');
    } finally {
      _isAnimatingToTab = false;
    }
  }

  @override
  Future<void> fetchData({bool refresh = false}) async {
    // Use today's date for the API call
    final today = DateTime.now();
    final dateString = DateFormat('yyyy-MM-dd').format(today);

    final timetable = await _timetableService.fetchCourseTimetable(
      year: widget.selectedYear.year,
      date: dateString,
      refresh: refresh,
    );

    if (!mounted) return;
    setState(() {
      _timetableData = timetable;
      _computeWeekDates();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToToday();
        }
      });
    });
  }

  @override
  bool get isEmpty => _timetableData == null || _timetableData!.weekdays.isEmpty;

  @override
  String get errorTitle => 'Failed to load timetable';

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
  Widget buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            if (_viewMode == _TimetableViewMode.mobile)
              DayTabs(
                controller: _dayTabController,
                onTap: _scrollToDay,
                labels: PeriodConstants.weekdayShortNames.sublist(0, 5),
                todayIndex: _todayIndex,
              ),
            Expanded(
              child: _viewMode == _TimetableViewMode.mobile
                  ? TimetableMobileView(
                      scrollController: _scrollController,
                      dayDates: _dayDates,
                      todayIndex: _todayIndex,
                      selectedDayIndex: _selectedDayIndex,
                      dayKeys: _dayKeys,
                      timetableData: _timetableData,
                      onEventTap: _onEventTap,
                    )
                  : TimetableCalendarView(
                      dayDates: _dayDates,
                      timetableData: _timetableData,
                      onEventTap: _onEventTap,
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: super.build(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _viewMode = _viewMode == _TimetableViewMode.mobile
                ? _TimetableViewMode.calendar
                : _TimetableViewMode.mobile;
          });
        },
        tooltip: _viewMode == _TimetableViewMode.mobile
            ? 'Switch to Calendar View'
            : 'Switch to List View',
        child: Icon(
          _viewMode == _TimetableViewMode.mobile
              ? Icons.calendar_month_rounded
              : Icons.view_agenda_rounded,
        ),
      ),
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
        final results = await _courseStatsService.fetchCourseStats(
          year: widget.selectedYear.year,
        );
        final statsForCourse = results.firstWhere(
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
