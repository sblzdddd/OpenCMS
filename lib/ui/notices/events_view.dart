import 'package:flutter/material.dart';
import '../../services/theme/theme_services.dart';
import '../../data/models/events/student_event.dart';
import '../../services/events/events_service.dart';
import '../shared/views/refreshable_view.dart';
import 'adaptive_events_layout.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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
      final ledEvents = await _eventsService.fetchStudentLedEvents(refresh: refresh);
      final unstaffedEvents = await _eventsService.fetchStudentUnstaffedEvents(refresh: refresh);
      
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
  Widget buildEmptyWidget(BuildContext context, ThemeNotifier themeNotifier) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.event_note_rounded,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No events available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Check back later for new events',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  String get errorTitle => 'Error loading events';

  @override
  bool get isEmpty => 
      (_studentLedEvents == null || _studentLedEvents!.isEmpty) &&
      (_studentUnstaffedEvents == null || _studentUnstaffedEvents!.isEmpty);
}
