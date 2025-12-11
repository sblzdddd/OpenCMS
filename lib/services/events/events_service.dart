import 'package:opencms/features/auth/login_state.dart';
import 'package:opencms/features/core/di/locator.dart';

import '../../features/core/networking/http_service.dart';
import 'student_led_events_parser.dart';
import 'student_unstaffed_events_parser.dart';
import '../../data/models/events/student_event.dart';

/// Service to fetch and parse events HTML from legacy CMS
class EventsService {
  static final EventsService _instance = EventsService._internal();
  factory EventsService() => _instance;
  EventsService._internal();

  /// Fetch student-led events from legacy CMS
  Future<List<StudentEvent>> fetchStudentLedEvents({
    bool refresh = false,
  }) async {
    final username = di<LoginState>().currentUsername;
    if (username.isEmpty) {
      throw Exception('Missing username. Please login again.');
    }

    final endpoint = '/$username/sl_event/list/';

    final response = await di<HttpService>().get(endpoint, refresh: refresh, legacy: true);

    if (response.statusCode != 200 && response.statusCode != 304) {
      throw Exception(
        'Failed to fetch student-led events: ${response.statusCode}',
      );
    }

    return StudentLedEventsParser.parseHtml(response.data);
  }

  /// Fetch student-unstaffed events from legacy CMS
  Future<List<StudentEvent>> fetchStudentUnstaffedEvents({
    bool refresh = false,
  }) async {
    final username = di<LoginState>().currentUsername;
    if (username.isEmpty) {
      throw Exception('Missing username. Please login again.');
    }

    final endpoint = '/$username/su_event/list/';

    final response = await di<HttpService>().get(endpoint, refresh: refresh, legacy: true);

    if (response.statusCode != 200 && response.statusCode != 304) {
      throw Exception(
        'Failed to fetch student-unstaffed events: ${response.statusCode}',
      );
    }

    return StudentUnstaffedEventsParser.parseHtml(response.data);
  }
}
