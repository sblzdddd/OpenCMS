import '../auth/auth_service.dart';
import '../shared/http_service.dart';
import 'student_led_events_parser.dart';
import 'student_unstaffed_events_parser.dart';
import '../../data/models/events/student_event.dart';

/// Service to fetch and parse events HTML from legacy CMS
class EventsService {
  static final EventsService _instance = EventsService._internal();
  factory EventsService() => _instance;
  EventsService._internal();

  final AuthService _authService = AuthService();
  final HttpService _httpService = HttpService();

  /// Fetch student-led events from legacy CMS
  Future<List<StudentEvent>> fetchStudentLedEvents({
    bool refresh = false,
  }) async {
    final username = await _authService.fetchCurrentUsername();
    if (username.isEmpty) {
      throw Exception('Missing username. Please login again.');
    }

    final endpoint = '/$username/sl_event/list/';

    final response = await _httpService.getLegacy(
      endpoint,
      refresh: refresh,
    );

    if (response.statusCode != 200 && response.statusCode != 304) {
      throw Exception('Failed to fetch student-led events: ${response.statusCode}');
    }

    return StudentLedEventsParser.parseHtml(response.data);
  }

  /// Fetch student-unstaffed events from legacy CMS
  Future<List<StudentEvent>> fetchStudentUnstaffedEvents({
    bool refresh = false,
  }) async {
    final username = await _authService.fetchCurrentUsername();
    if (username.isEmpty) {
      throw Exception('Missing username. Please login again.');
    }

    final endpoint = '/$username/su_event/list/';

    final response = await _httpService.getLegacy(
      endpoint,
      refresh: refresh,
    );

    if (response.statusCode != 200 && response.statusCode != 304) {
      throw Exception('Failed to fetch student-unstaffed events: ${response.statusCode}');
    }

    return StudentUnstaffedEventsParser.parseHtml(response.data);
  }
}
