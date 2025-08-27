import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/constants/period_constants.dart';
import '../../../data/models/timetable/timetable_response.dart';
import '../../../data/models/timetable/course_merged_event.dart';
import '../../../services/timetable/course_timetable_service.dart';
import 'dart:async';
import '../../../pages/actions.dart';

/// Widget that displays either the next class or current class information
/// Shows next class if not in class, or current class with progress bar if in class
class NextClassWidget extends StatefulWidget {
  final VoidCallback? onRefresh;
  final int? refreshTick;
  
  const NextClassWidget({super.key, this.onRefresh, this.refreshTick});

  @override
  State<NextClassWidget> createState() => _NextClassWidgetState();
}

class _NextClassWidgetState extends State<NextClassWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  TimetableResponse? _timetableData;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _updateTimer;
  
  CourseMergedEvent? _currentClass;
  CourseMergedEvent? _nextClass;
  
  final CourseTimetableService _timetableService = CourseTimetableService();

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
    _startTimer();
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
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Update every minute to refresh class status
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _updateClassStatus();
        });
      }
    });
  }

  /// Refresh the widget data
  Future<void> refresh() async {
    await _fetchTimetable(refresh: true);
    // Call the parent refresh callback if provided
    widget.onRefresh?.call();
  }

  Future<void> _fetchTimetable({bool refresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

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
          _isLoading = false;
          _updateClassStatus();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      print('NextClassWidget: Error fetching timetable: $e');
    }
  }

  void _updateClassStatus() {
    if (_timetableData == null || _timetableData!.weekdays.isEmpty) return;

    final now = DateTime.now();
    final today = now.weekday - 1; // Convert to 0-based index (Monday = 0)
    
    // Only show for weekdays (Monday = 1 to Friday = 5)
    if (today < 0 || today >= 5) {
      _currentClass = null;
      _nextClass = null;
      return;
    }

    final weekday = _timetableData!.weekdays[today];
    final mergedEvents = CourseMergedEvent.mergeEventsForDay(weekday);
    
    _currentClass = null;
    _nextClass = null;
    
    for (final event in mergedEvents) {
      final startTime = _parseTime(PeriodConstants.getPeriodInfo(event.startPeriod)?.startTime ?? '');
      final endTime = _parseTime(PeriodConstants.getPeriodInfo(event.endPeriod)?.endTime ?? '');
      
      if (startTime == null || endTime == null) continue;
      
      final currentTime = _parseTime('${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
      if (currentTime == null) continue;
      
      if (_isTimeInRange(currentTime, startTime, endTime)) {
        // Currently in this class
        _currentClass = event;
        break;
      } else if (_isTimeBefore(currentTime, startTime)) {
        // This is the next class
        _nextClass = event;
        break;
      }
    }
    
    // If no current class and no next class found, look for next class in remaining events
    if (_currentClass == null && _nextClass == null) {
      for (final event in mergedEvents) {
        final startTime = _parseTime(PeriodConstants.getPeriodInfo(event.startPeriod)?.startTime ?? '');
        final endTime = _parseTime(PeriodConstants.getPeriodInfo(event.endPeriod)?.endTime ?? '');
        
        if (startTime != null && endTime != null) {
          final currentTime = _parseTime('${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
          if (currentTime != null && _isTimeBefore(currentTime, startTime)) {
            // Only show as next class if it hasn't started yet (future class)
            _nextClass = event;
            break;
          }
        }
      }
    }
  }

  bool _isTimeInRange(DateTime time, DateTime start, DateTime end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return timeMinutes >= startMinutes && timeMinutes < endMinutes;
  }

  bool _isTimeBefore(DateTime time, DateTime other) {
    final timeMinutes = time.hour * 60 + time.minute;
    final otherMinutes = other.hour * 60 + other.minute;
    return timeMinutes < otherMinutes;
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => buildActionPage({
                'id': 'timetable',
                'title': 'Timetable',
              }),
            ),
          );
        });
      },
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: _buildUnifiedContent(),
      ),
    ));
  }

  Widget _buildUnifiedContent() {
    if (_isLoading) {
      return const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading timetable...'),
        ],
      );
    }
    
    if (_hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.error_outline_rounded,
            fill: 1.0,
            color: Theme.of(context).colorScheme.error,
            size: 18,
          ),
          Text(
            'Failed to load timetable',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const Spacer(),
          Text(
            'Swipe down to refresh',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    
    // Determine the state and extract common data
    final bool hasCurrentClass = _currentClass != null;
    final bool hasNextClass = _nextClass != null;
    final event = hasCurrentClass ? _currentClass! : _nextClass;
    
    // Title text
    final titleText = hasCurrentClass 
        ? '${event!.event.subject}-${event.event.code}'
        : hasNextClass 
            ? '${event!.event.subject}-${event.event.code}'
            : 'No more classes today';
    
    // Subtitle text
    final subtitleText = hasCurrentClass 
        ? event!.timeSpan
        : hasNextClass 
            ? '${event!.timeSpan} (${event.periodText})'
            : 'Enjoy your free time';
    
    // Right side text (room/time info)
    final rightText = hasCurrentClass 
        ? event!.event.room
        : hasNextClass 
            ? _getTimeUntilNextClass().isNotEmpty 
                ? '${_getTimeUntilNextClass()}, ${event!.event.room}'
                : event!.event.room
            : null;
    
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          children: [
            Icon(
              Symbols.schedule_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
              fill: 1,
            ),
            const Spacer(),
            if (rightText != null)
              Text(
                rightText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        if (hasNextClass) const SizedBox(width: 8),
        Text(
          titleText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        if(!hasCurrentClass) const Spacer(),
        if(hasCurrentClass) const SizedBox(height: 4),
        Text(
          subtitleText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
          ),
        ),
        if (hasCurrentClass) const Spacer(),
        if (hasCurrentClass) LinearProgressIndicator(
            value: _getClassProgress(),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
      ],
    );
  }
}
