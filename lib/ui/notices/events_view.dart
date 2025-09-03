import 'package:flutter/material.dart';
import '../../data/models/events/student_event.dart';
import '../../services/events/events_service.dart';
import '../../services/auth/auth_service.dart';
import '../shared/views/refreshable_view.dart';
import '../../pages/actions/web_cms.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends RefreshableView<EventsView> {
  final EventsService _eventsService = EventsService();
  final AuthService _authService = AuthService();
  List<StudentEvent>? _studentLedEvents;
  List<StudentEvent>? _studentUnstaffedEvents;

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

  Future<void> _navigateToEventDetail(StudentEvent event) async {
    final username = await _authService.fetchCurrentUsername();
    if (username.isEmpty) {
      throw Exception('Missing username. Please login again.');
    }

    String detailUrl;
    if (event.type == StudentEventType.led) {
      detailUrl = 'https://www.a''l''eve''l.co''m.cn/user/$username/sl_event/view/${event.id}/';
    } else {
      detailUrl = 'https://www.a''l''eve''l.co''m.cn/user/$username/su_event/view/${event.id}/';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebCmsPage(
          initialUrl: detailUrl,
          windowTitle: event.title,
        ),
      ),
    );
  }

  Widget _buildEventItem(StudentEvent event) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: event.type == StudentEventType.led 
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    event.applicant,
                    style: TextStyle(
                      fontSize: 12, 
                      color: event.type == StudentEventType.led 
                        ? Colors.blue
                        : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    event.dateTime,
                    style: TextStyle(
                      fontSize: 12, 
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToEventDetail(event),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    if (_studentLedEvents == null || _studentUnstaffedEvents == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final allEvents = <Widget>[];
    
    // Add Student-Led Events section
    if (_studentLedEvents!.isNotEmpty) {
      allEvents.add(_buildSectionTitle('Student-Led Events'));
      for (final event in _studentLedEvents!) {
        allEvents.add(_buildEventItem(event));
      }
    }
    
    // Add Student-Unstaffed Events section
    if (_studentUnstaffedEvents!.isNotEmpty) {
      allEvents.add(_buildSectionTitle('Student-Unstaffed Events'));
      for (final event in _studentUnstaffedEvents!) {
        allEvents.add(_buildEventItem(event));
      }
    }
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      children: allEvents,
    );
  }

  @override
  Widget buildEmptyWidget(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_note_outlined,
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
