import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../../services/theme/theme_services.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../../services/calendar/calendar_service.dart';
import '../../../data/models/calendar/calendar.dart';
import '../../../ui/shared/widgets/custom_app_bar.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';

class SchoolCalendarView extends StatefulWidget {
  const SchoolCalendarView({super.key});

  @override
  State<SchoolCalendarView> createState() => _SchoolCalendarViewState();
}

class _SchoolCalendarViewState extends State<SchoolCalendarView> {
  final CalendarService _calendarService = CalendarService();
  late CalendarController _calendarController;
  
  CalendarResponse? _currentCalendar;
  bool _isLoading = false;
  String? _errorMessage;
  int? _loadedYear;
  int? _loadedMonth;
  
  // Track unique event types and their assigned colors
  final Map<String, Color> _eventColors = {};
  int _nextColorIndex = 0;
  
  // Calendar configuration
  final bool _showLeadingAndTrailingDates = true;
  final bool _showWeekNumber = false;
  final bool _showDatePickerButton = true;
  final ViewNavigationMode _viewNavigationMode = ViewNavigationMode.snap;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _loadCalendar(DateTime.now());
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  Future<void> _loadCalendar(DateTime date, {bool refresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final calendar = await _calendarService.getCalendar(
        year: date.year,
        month: date.month,
        refresh: refresh,
      );
      
      if (!mounted) return;
      setState(() {
        _currentCalendar = calendar;
        _loadedYear = date.year;
        _loadedMonth = date.month;
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

  Future<void> _onViewChanged(ViewChangedDetails details) async {
    final List<DateTime> visible = details.visibleDates;
    final DateTime newDate = visible.isNotEmpty
        ? visible[visible.length ~/ 2]
        : DateTime.now();

    // Avoid reloading if already loading or month/year unchanged
    if (_isLoading == true) return;
    if (_loadedYear == newDate.year && _loadedMonth == newDate.month) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadCalendar(newDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('School Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh_rounded),
            onPressed: () => _loadCalendar(_calendarController.displayDate ?? DateTime.now(), refresh: true),
          ),
        ],
      ),
      body: _buildCalendarBody(),
    );
  }

  Widget _buildCalendarBody() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load calendar',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadCalendar(DateTime.now()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_currentCalendar == null) {
      return const Center(
        child: Text('No calendar data available'),
      );
    }

    final events = _buildCalendarEvents();
    return Stack(
      children: [
        SfCalendarTheme(
          data: SfCalendarThemeData(
            backgroundColor: Theme.of(context).colorScheme.surface,
            headerBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            headerTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            todayHighlightColor: Theme.of(context).colorScheme.primary,
            viewHeaderBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
          child: SfCalendar(
            controller: _calendarController,
            allowedViews: [
              CalendarView.month,
              CalendarView.schedule,
              CalendarView.week,
              CalendarView.day,
            ],
            view: CalendarView.week,
            firstDayOfWeek: 7, // Sunday
            dataSource: _CalendarDataSource(events),
            showCurrentTimeIndicator: true,
            allowViewNavigation: true,
            showDatePickerButton: _showDatePickerButton,
            viewNavigationMode: _viewNavigationMode,
            showWeekNumber: _showWeekNumber,
            onViewChanged: _onViewChanged,
            monthViewSettings: MonthViewSettings(
              showAgenda: false,
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              showTrailingAndLeadingDates: _showLeadingAndTrailingDates,
            ),
            timeSlotViewSettings: const TimeSlotViewSettings(
              nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday],
              timeIntervalHeight: 60,
              timeRulerSize: 50,
              minimumAppointmentDuration: Duration(minutes: 30),
            ),
            appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
              final SchoolCalendarAppointment event = details.appointments.first as SchoolCalendarAppointment;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: themeNotifier.getBorderRadiusAll(0.25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
            onTap: (details) {
              if (details.targetElement == CalendarElement.appointment &&
                  details.appointments != null &&
                  details.appointments!.isNotEmpty) {
                final SchoolCalendarAppointment tapped = details.appointments!.first as SchoolCalendarAppointment;
                _showEventDetailDialog(tapped);
              } else if (details.targetElement == CalendarElement.calendarCell) {
                // Navigate to day view when tapping on a month cell
                final DateTime tappedDate = details.date!;
                _calendarController.view = CalendarView.week;
                _calendarController.displayDate = tappedDate;
              }
            },
          ),
        ),
        if (_isLoading)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  List<SchoolCalendarAppointment> _buildCalendarEvents() {
    final List<SchoolCalendarAppointment> events = <SchoolCalendarAppointment>[];
    
    if (_currentCalendar == null) return events;

    // Group source events by day to assign pseudo time slots
    final Map<DateTime, List<MapEntry<CalendarDay, CalendarEvent>>> eventsByDay = {};

    for (final dayEntry in _currentCalendar!.calendarDays.values) {
      if (!dayEntry.hasEvents) continue;

      final DateTime? eventDate = dayEntry.dateTime;
      if (eventDate == null) continue;

      for (final event in dayEntry.events) {
        eventsByDay.putIfAbsent(
          DateTime(eventDate.year, eventDate.month, eventDate.day),
          () => <MapEntry<CalendarDay, CalendarEvent>>[],
        );
        eventsByDay[DateTime(eventDate.year, eventDate.month, eventDate.day)]!
            .add(MapEntry<CalendarDay, CalendarEvent>(dayEntry, event));
      }
    }

    // Assign sequential 1-hour slots starting from 09:00 for each day
    const int startHour = 0;
    const int slotMinutes = 60;

    for (final entry in eventsByDay.entries) {
      final DateTime day = entry.key;
      final List<MapEntry<CalendarDay, CalendarEvent>> dayEvents = entry.value;

      // Stable ordering: by kind then title then id
      dayEvents.sort((a, b) {
        final int kindCmp = a.value.kind.compareTo(b.value.kind);
        if (kindCmp != 0) return kindCmp;
        final int titleCmp = a.value.title.compareTo(b.value.title);
        if (titleCmp != 0) return titleCmp;
        return a.value.id.compareTo(b.value.id);
      });

      for (int i = 0; i < dayEvents.length; i++) {
        final CalendarEvent event = dayEvents[i].value;
        final CalendarDay srcDay = dayEvents[i].key;
        final DateTime from = DateTime(day.year, day.month, day.day, startHour + i, 0);
        final DateTime to = from.add(const Duration(minutes: slotMinutes));
        final Color color = _getColorForEvent(event);

        events.add(
          SchoolCalendarAppointment(
            title: event.title,
            from: from,
            to: to,
            color: color,
            isAllDay: false,
            sourceEvent: event,
            sourceDay: srcDay,
          ),
        );
      }
    }

    return events;
  }

  Color _getColorForEvent(CalendarEvent event) {
    final String eventKey = event.kind;
    
    if (!_eventColors.containsKey(eventKey)) {
      final List<Color> palette = <Color>[
        Colors.blue,
        Colors.teal,
        Colors.orange,
        Colors.pink,
        Colors.purple,
      ];
      
      if (_nextColorIndex < palette.length) {
        _eventColors[eventKey] = palette[_nextColorIndex].withValues(alpha: 0.8);
        _nextColorIndex++;
      } else {
        final int colorIndex = _nextColorIndex % palette.length;
        _eventColors[eventKey] = palette[colorIndex].withValues(alpha: 0.8);
        _nextColorIndex++;
      }
    }
    
    return _eventColors[eventKey]!;
  }

  Future<void> _showEventDetailDialog(SchoolCalendarAppointment appointment) async {
    final event = appointment.sourceEvent;

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    // Try to fetch detailed information
    CalendarDetailResponse? detail;
    String? comment;
    
    try {
      detail = await _calendarService.getCalendarDetail(eventId: event.id);
      
      // Try to get comment based on event kind
      String commentKind = '';
      switch (event.kind) {
        case 'fieldtrip':
          commentKind = 'ft_title';
          break;
        case 'fixture':
          commentKind = 'fv_title';
          break;
        case 'visit_event':
          commentKind = 've_title';
          break;
        case 'sl_event':
          commentKind = 'sle_title';
          break;
        case 'su_event':
          commentKind = 'sue_title';
          break;
      }
      
      if (commentKind.isNotEmpty) {
        final commentResponse = await _calendarService.getCalendarComment(
          eventId: event.id,
          kind: commentKind,
        );
        comment = commentResponse.content;
      }
    } catch (e) {
      debugPrint('SchoolCalendarView: Failed to fetch event details: $e');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
        ),
        clipBehavior: Clip.antiAlias,
        title: Text(event.title),
        content: CustomChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', event.eventType),
              _buildDetailRow('Category', event.cat),
              _buildDetailRow('Date', appointment.from.toString().split(' ')[0]),
              if (event.isPostponed) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: themeNotifier.getBorderRadiusAll(0.25),
                  ),
                  child: const Row(
                    children: [
                      Icon(Symbols.schedule_rounded, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'This event has been postponed',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (detail != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                if (detail.location.isNotEmpty)
                  _buildDetailRow('Location', detail.location),
                if (detail.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(detail.content),
                ],
              ],
              if (comment != null && comment.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Additional Information:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(comment),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class SchoolCalendarAppointment {
  final String title;
  // final String eventType;
  final DateTime from;
  final DateTime to;
  final Color color;
  final bool isAllDay;
  final CalendarEvent sourceEvent;
  final CalendarDay sourceDay;

  SchoolCalendarAppointment({
    required this.title,
    // required this.eventType,
    required this.from,
    required this.to,
    required this.color,
    required this.isAllDay,
    required this.sourceEvent,
    required this.sourceDay,
  });
}

class _CalendarDataSource extends CalendarDataSource {
  _CalendarDataSource(List<SchoolCalendarAppointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].from as DateTime;

  @override
  DateTime getEndTime(int index) => appointments![index].to as DateTime;

  @override
  String getSubject(int index) => appointments![index].title as String;

  @override
  Color getColor(int index) => appointments![index].color as Color;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay as bool;
}
