import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/constants/period_constants.dart';
import '../../../data/models/timetable/timetable_response.dart';
import '../../../data/models/timetable/course_merged_event.dart';
import '../../../services/timetable/course_timetable_service.dart';
import 'dart:async';
import 'base_dashboard_widget.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Widget that displays either the next class or current class information
/// Shows next class if not in class, or current class with progress bar if in class
class NextClassWidget extends StatefulWidget {
  final VoidCallback? onRefresh;
  final int? refreshTick;
  
  const NextClassWidget({super.key, this.onRefresh, this.refreshTick});

  @override
  State<NextClassWidget> createState() => _NextClassWidgetState();
}

class _NextClassWidgetState extends State<NextClassWidget> 
    with AutomaticKeepAliveClientMixin, BaseDashboardWidgetMixin {
  
  @override
  bool get wantKeepAlive => true;
  
  TimetableResponse? _timetableData;
  CourseMergedEvent? _currentClass;
  CourseMergedEvent? _nextClass;
  
  final CourseTimetableService _timetableService = CourseTimetableService();

  @override
  void initState() {
    super.initState();
    initializeWidget();
    startTimer();
  }

  @override
  void didUpdateWidget(covariant NextClassWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTick != null && widget.refreshTick != oldWidget.refreshTick) {
      print('NextClassWidget: refreshTick changed -> refreshing with refresh=true');
      refresh();
    }
  }

  @override
  void dispose() {
    disposeMixin();
    super.dispose();
  }

  @override
  Future<void> initializeWidget() async {
    await _fetchTimetable();
  }

  @override
  void startTimer() {
    // Update every minute to refresh class status and UI
    setCustomTimer(const Duration(minutes: 1));
  }

  @override
  Future<void> refreshData() async {
    await _fetchTimetable(refresh: true);
    // Call the parent refresh callback if provided
    widget.onRefresh?.call();
  }

  Future<void> _fetchTimetable({bool refresh = false}) async {
    try {
      setLoading(true);
      setError(false);

      final today = DateTime.now();
      final dateString = DateFormat('yyyy-MM-dd').format(today);
      
      final timetable = await _timetableService.fetchCourseTimetable(
        year: PeriodConstants.getAcademicYears().first.year,
        date: dateString,
        refresh: refresh,
      );

      if (mounted) {
        setState(() {
          _timetableData = timetable;
          _updateClassStatus();
        });
        setLoading(false);
      }
    } catch (e) {
      if (mounted) {
        setLoading(false);
        setError(true);
      }
      print('NextClassWidget: Error fetching timetable: $e');
    }
  }

  void _updateClassStatus() {
    if (_timetableData == null) return;
    
    final classInfo = _timetableData!.getCurrentAndNextClass();
    _currentClass = classInfo['current'];
    _nextClass = classInfo['next'];
  }
  
  DateTime? _parseTime(String timeString) {
    try {
      return DateFormat('HH:mm').parse(timeString);
    } catch (e) {
      return null;
    }
  }

  double _getClassProgress() {
    if (_currentClass == null) return 0.0;
    
    final now = DateTime.now();
    final startTime = _parseTime(PeriodConstants.getPeriodInfo(_currentClass!.startPeriod)?.startTime ?? '');
    final endTime = _parseTime(PeriodConstants.getPeriodInfo(_currentClass!.endPeriod)?.endTime ?? '');
    
    if (startTime == null || endTime == null) return 0.0;
    
    final currentTime = _parseTime('${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
    if (currentTime == null) return 0.0;
    
    final totalDuration = endTime.difference(startTime).inMinutes;
    final elapsedDuration = currentTime.difference(startTime).inMinutes;
    
    if (totalDuration <= 0) return 0.0;
    
    final progress = elapsedDuration / totalDuration;
    return progress.clamp(0.0, 1.0);
  }

  String _getTimeUntilNextClass() {
    if (_nextClass == null) return '';
    
    final now = DateTime.now();
    final startTime = _parseTime(PeriodConstants.getPeriodInfo(_nextClass!.startPeriod)?.startTime ?? '');
    
    if (startTime == null) return '';
    
    final nextClassTime = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
    final difference = nextClassTime.difference(now);
    
    if (difference.isNegative) return '';
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    if (hours > 0) {
      return 'in ${hours}h ${minutes}m';
    } else {
      return 'in ${minutes}m';
    }
  }

  String _getTitleText() {
    final bool hasCurrentClass = _currentClass != null;
    final event = hasCurrentClass ? _currentClass! : _nextClass;
    
    if (event == null) return 'Next Class';
    
    return '${event.event.subject}-${event.event.code}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Update class status before building to ensure latest data
    _updateClassStatus();
    
    // Use the base layout
    return buildCommonLayout();
  }

  @override
  Widget? getExtraContent(BuildContext context) {
    final bool hasCurrentClass = _currentClass != null;
    if (!hasCurrentClass) return null;
    
    return LinearProgressIndicator(
      value: _getClassProgress(),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary,
      ),
      borderRadius: BorderRadius.circular(4),
    );
  }

  @override
  String getWidgetTitle() => _getTitleText();

  @override
  String getRightSideText() {
    final bool hasCurrentClass = _currentClass != null;
    final event = hasCurrentClass ? _currentClass! : _nextClass;
    
    if (event == null) return '';
    
    return event.timeSpan;
  }
  
  @override
  String getWidgetSubtitle() {
    final bool hasCurrentClass = _currentClass != null;
    final event = hasCurrentClass ? _currentClass! : _nextClass;
    
    if (event == null) return '';
    
    return '${event.periodText} (${event.periodCount} periods)\n';
  }

  @override
  String getBottomText() {
    final bool hasCurrentClass = _currentClass != null;
    final event = hasCurrentClass ? _currentClass! : _nextClass;
    
    return event != null && hasWidgetData() ? event.event.teacher : 'Enjoy your free time!';
  }

  @override
  String? getBottomRightText() {
    final bool hasCurrentClass = _currentClass != null;
    final bool hasNextClass = _nextClass != null;
    final event = hasCurrentClass ? _currentClass! : _nextClass;
    
    if (event == null) return null;
    
    return hasCurrentClass 
        ? event.event.room
        : hasNextClass 
            ? _getTimeUntilNextClass().isNotEmpty 
                ? '${_getTimeUntilNextClass()}, ${event.event.room}'
                : event.event.room
            : null;
  }

  @override
  String getLoadingText() => 'Loading timetable...';

  @override
  String getErrorText() => 'Failed to load timetable';

  @override
  String getNoDataText() => 'No more classes today';

  @override
  bool hasWidgetData() => _currentClass != null || _nextClass != null;

  @override
  String getActionId() => 'timetable';

  @override
  IconData getWidgetIcon() => Symbols.calendar_view_day_rounded;
}
