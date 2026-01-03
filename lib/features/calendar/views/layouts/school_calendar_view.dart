import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../services/calendar_service.dart';
import '../../models/calendar.dart';
import '../../../shared/views/widgets/custom_app_bar.dart';
import '../../../shared/views/widgets/custom_scaffold.dart';
import '../components/school_calendar_body.dart';
import '../components/event_detail_dialog.dart';
import '../../utils/calendar_utils.dart';

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
    return CustomScaffold(
      skinKey: 'calendar',
      appBar: CustomAppBar(
        title: const Text('School Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh_rounded),
            onPressed: () => _loadCalendar(
              _calendarController.displayDate ?? DateTime.now(),
              refresh: true,
            ),
          ),
        ],
      ),
      body: _buildCalendarBody(),
    );
  }

  Widget _buildCalendarBody() {
    final events = CalendarUtils.buildCalendarEvents(
      _currentCalendar,
      _eventColors,
      _getColorForEvent,
    );

    return SchoolCalendarBody(
      calendarController: _calendarController,
      events: events,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      onRetry: () => _loadCalendar(DateTime.now()),
      onViewChanged: _onViewChanged,
      onEventTap: (appointment) => _showEventDetailDialog(appointment),
    );
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
        _eventColors[eventKey] = palette[_nextColorIndex].withValues(
          alpha: 0.5,
        );
        _nextColorIndex++;
      } else {
        final int colorIndex = _nextColorIndex % palette.length;
        _eventColors[eventKey] = palette[colorIndex].withValues(alpha: 0.5);
        _nextColorIndex++;
      }
    }

    return _eventColors[eventKey]!;
  }

  Future<void> _showEventDetailDialog(
    SchoolCalendarAppointment appointment,
  ) async {
    await EventDetailDialog.show(context, appointment, _calendarService);
  }
}
