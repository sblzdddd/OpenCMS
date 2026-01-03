import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../theme/services/theme_services.dart';
import '../../../../shared/constants/period_constants.dart';
import '../../models/course_timetable_models.dart';
import '../../models/course_merged_event.dart';
import '../../services/course_timetable_service.dart';
import 'dart:async';
import '../../../../home/views/widgets/base_dashboard_widget.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:logging/logging.dart';

final logger = Logger('NextClassWidget');

/// Widget that displays either the next class or current class information
class NextClassWidget extends StatefulWidget {
  final VoidCallback? onRefresh;
  final int? refreshTick;

  const NextClassWidget({super.key, this.onRefresh, this.refreshTick});

  @override
  State<NextClassWidget> createState() => _NextClassWidgetState();
}

class _NextClassWidgetState extends State<NextClassWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  TimetableResponse? _timetableData;
  CourseMergedEvent? _currentClass;
  CourseMergedEvent? _nextClass;
  final CourseTimetableService _timetableService = CourseTimetableService();
  bool _isLoading = true;
  bool _hasError = false;

  Future<void> _fetchWidgetData({bool refresh = false}) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      }

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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      logger.severe('NextClassWidget: Error fetching timetable: $e', e, StackTrace.current);
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
    final startTime = _parseTime(
      PeriodConstants.getPeriodInfo(_currentClass!.startPeriod)?.startTime ??
          '',
    );
    final endTime = _parseTime(
      PeriodConstants.getPeriodInfo(_currentClass!.endPeriod)?.endTime ?? '',
    );

    if (startTime == null || endTime == null) return 0.0;

    final currentTime = _parseTime(
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    );
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
    final startTime = _parseTime(
      PeriodConstants.getPeriodInfo(_nextClass!.startPeriod)?.startTime ?? '',
    );

    if (startTime == null) return '';

    final nextClassTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );
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

  Widget? _getExtraContent(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final bool hasCurrentClass = _currentClass != null;
    if (!hasCurrentClass) return null;

    return LinearProgressIndicator(
      value: _getClassProgress(),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary,
      ),
      borderRadius: themeNotifier.getBorderRadiusAll(0.25),
    );
  }

  String _getRightSideText() {
    final bool hasCurrentClass = _currentClass != null;
    final event = hasCurrentClass ? _currentClass! : _nextClass;

    if (event == null) return '';

    return event.timeSpan;
  }

  String _getWidgetSubtitle() {
    final bool hasCurrentClass = _currentClass != null;
    final event = hasCurrentClass ? _currentClass! : _nextClass;

    if (event == null) return '';

    return '${event.periodText} (${event.periodCount} periods)\n';
  }

  String _getBottomText() {
    final bool hasCurrentClass = _currentClass != null;
    final event = hasCurrentClass ? _currentClass! : _nextClass;

    return event != null && _hasWidgetData()
        ? event.event.teacher
        : 'Enjoy your free time!';
  }

  String? _getBottomRightText() {
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

  bool _hasWidgetData() => _currentClass != null || _nextClass != null;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Update class status before building to ensure latest data
    _updateClassStatus();

    return BaseDashboardWidget(
      title: _getTitleText(),
      subtitle: _getWidgetSubtitle(),
      icon: Symbols.calendar_view_day_rounded,
      actionId: 'timetable',
      isLoading: _isLoading,
      hasError: _hasError,
      hasData: _hasWidgetData(),
      loadingText: 'Loading timetable...',
      errorText: 'Failed to load timetable',
      noDataText: 'No more classes today',
      rightSideText: _getRightSideText(),
      bottomText: _getBottomText(),
      bottomRightText: _getBottomRightText(),
      extraContent: _getExtraContent(context),
      onFetch: _fetchWidgetData,
      refreshTick: widget.refreshTick,
    );
  }
}
