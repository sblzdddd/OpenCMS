import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/constants/period_constants.dart';
import '../../../data/models/timetable/timetable_response.dart';
import '../../../data/models/timetable/course_merged_event.dart';
import '../../../ui/shared/timetable_card.dart';
import 'day_header.dart';

class TimetableMobileView extends StatefulWidget {
  final ScrollController scrollController;
  final List<DateTime> dayDates;
  final int todayIndex;
  final int selectedDayIndex;
  final List<GlobalKey> dayKeys;
  final TimetableResponse? timetableData;
  final Function(TimetableEvent) onEventTap;

  const TimetableMobileView({
    super.key,
    required this.scrollController,
    required this.dayDates,
    required this.todayIndex,
    required this.selectedDayIndex,
    required this.dayKeys,
    required this.timetableData,
    required this.onEventTap,
  });

  @override
  State<TimetableMobileView> createState() => _TimetableMobileViewState();
}

class _TimetableMobileViewState extends State<TimetableMobileView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int dayIndex = 0; dayIndex < 5; dayIndex++) ...[
            DayHeader(
              key: widget.dayKeys[dayIndex],
              title: PeriodConstants.weekdayNames[dayIndex],
              dateText: (widget.dayDates.isNotEmpty && dayIndex < widget.dayDates.length)
                  ? _formatYmd(widget.dayDates[dayIndex])
                  : '',
              isActive: dayIndex == widget.selectedDayIndex,
              isToday: dayIndex == widget.todayIndex,
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

  String _formatYmd(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString();
    final d = date.day.toString();
    return '$y-$m-$d';
  }

  List<CourseMergedEvent> _getCourseMergedEventsForDay(int dayIndex) {
    if (widget.timetableData == null || 
        dayIndex >= widget.timetableData!.weekdays.length) {
      return [];
    }

    final weekday = widget.timetableData!.weekdays[dayIndex];
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

  List<Widget> _buildDayEvents(int dayIndex) {
    final mergedEvents = _getCourseMergedEventsForDay(dayIndex);
    if (mergedEvents.isEmpty) {
      return [
        Builder(
          builder: (context) {
            return Row(
              children: [
                Icon(
                  Symbols.calendar_today_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'No classes scheduled',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            );
          },
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
            widget.onEventTap(mergedEvent.event);
          },
        ),
        const SizedBox(height: 12),
      ]
    ];
  }
}
