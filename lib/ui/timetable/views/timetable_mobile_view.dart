import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/constants/periods.dart';
import '../../../data/models/timetable/timetable_response.dart';
import '../../../data/models/timetable/course_merged_event.dart';
import '../../shared/timetable_card.dart';
import '../components/day_header.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';
import '../../shared/widgets/staggered_animation_item.dart';

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

class _TimetableMobileViewState extends State<TimetableMobileView> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {  
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    if (isWideScreen) {
      // Calculate column width with minimum constraint
      const double minColumnWidth = 300.0; // Minimum width for each column
      const double columnSpacing = 24.0;
      final double availableWidth = screenWidth - 32; // Account for horizontal padding
      final double calculatedWidth = (availableWidth - (4 * columnSpacing)) / 5; // 4 spacings between 5 columns
      final double columnWidth = calculatedWidth > minColumnWidth ? calculatedWidth : minColumnWidth;

      return CustomChildScrollView(
        controller: widget.scrollController,
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int dayIndex = 0; dayIndex < 5; dayIndex++) ...[
                SizedBox(
                  width: columnWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DayHeader(
                        key: widget.dayKeys[dayIndex],
                        title: PeriodConstants.weekdayNames[dayIndex],
                        dateText: (widget.dayDates.isNotEmpty && dayIndex < widget.dayDates.length)
                            ? _formatYmd(widget.dayDates[dayIndex])
                            : '',
                        isActive: dayIndex == widget.todayIndex,
                        isToday: dayIndex == widget.todayIndex,
                      ),
                      const SizedBox(height: 16),
                      ..._buildDayEvents(dayIndex),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                if (dayIndex != 4) const SizedBox(width: columnSpacing),
              ],
            ],
          ),
        ),
      );
    }

    // Default vertical layout for smaller screens
    return CustomChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            const SizedBox(height: 8),
            if (dayIndex != 4) const Divider(height: 16),
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
    final mergedEvents = CourseMergedEvent.mergeEventsForDay(weekday);
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
      for (int eventIndex = 0; eventIndex < mergedEvents.length; eventIndex++) ...[
        StaggeredAnimationItem(
          animationController: _animationController,
          index: (dayIndex * 2) + eventIndex,
          delayMultiplier: 0.06,
          animationFraction: 0.5,
          child: TimetableCard(
            subject: mergedEvents[eventIndex].event.subject,
            code: mergedEvents[eventIndex].event.code,
            room: mergedEvents[eventIndex].event.room.isNotEmpty ? mergedEvents[eventIndex].event.room : 'TBA',
            extraInfo: mergedEvents[eventIndex].event.teacher.isNotEmpty ? mergedEvents[eventIndex].event.teacher : '',
            timespan: mergedEvents[eventIndex].timeSpan,
            periodText: mergedEvents[eventIndex].periodText,
            onTap: () {
              widget.onEventTap(mergedEvents[eventIndex].event);
            },
          ),
        ),
        const SizedBox(height: 20),
      ]
    ];
  }
}
