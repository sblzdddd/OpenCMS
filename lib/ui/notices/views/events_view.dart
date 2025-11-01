import 'package:flutter/material.dart';
import '../../../services/theme/theme_services.dart';
import '../../../data/models/events/student_event.dart';
import '../../../services/events/events_service.dart';
import '../../shared/views/refreshable_view.dart';
import '../layouts/adaptive_events_layout.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends RefreshableView<EventsView> {
  final EventsService _eventsService = EventsService();
  List<StudentEvent>? _studentLedEvents;
  List<StudentEvent>? _studentUnstaffedEvents;
  StudentEvent? _selectedEvent;

  @override
  Future<void> fetchData({bool refresh = false}) async {
    try {
      final ledEvents = await _eventsService.fetchStudentLedEvents(
        refresh: refresh,
      );
      final unstaffedEvents = await _eventsService.fetchStudentUnstaffedEvents(
        refresh: refresh,
      );

      setState(() {
        _studentLedEvents = ledEvents;
        _studentUnstaffedEvents = unstaffedEvents;
      });
    } catch (e) {
      // Handle error - RefreshableView will show error state
      rethrow;
    }
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    if (_studentLedEvents == null || _studentUnstaffedEvents == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AdaptiveEventsLayout(
      studentLedEvents: _studentLedEvents!,
      studentUnstaffedEvents: _studentUnstaffedEvents!,
      selectedEvent: _selectedEvent,
      onEventSelected: (event) {
        setState(() {
          _selectedEvent = event;
        });
      },
    );
  }

  @override
  String get emptyTitle => 'No events available';

  @override
  String get errorTitle => 'Error loading events';

  @override
  bool get isEmpty =>
      (_studentLedEvents == null || _studentLedEvents!.isEmpty) &&
      (_studentUnstaffedEvents == null || _studentUnstaffedEvents!.isEmpty);
}
