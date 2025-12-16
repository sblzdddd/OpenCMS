import 'package:opencms/features/shared/constants/api_endpoints.dart';
import 'package:opencms/di/locator.dart';

import '../../API/networking/http_service.dart';
import 'student_led_events_parser.dart';
import 'student_unstaffed_events_parser.dart';
import '../models/student_event.dart';

/// Service to fetch and parse events HTML from legacy CMS
class EventsService {
  static final EventsService _instance = EventsService._internal();
  factory EventsService() => _instance;
  EventsService._internal();

  /// Fetch student-led events from legacy CMS
  Future<List<StudentEvent>> fetchStudentLedEvents({
    bool refresh = false,
  }) async {
    final response = await di<HttpService>().get(
      API.studentLedEventsUrl,
      refresh: refresh,
      legacy: true
    );
    return StudentLedEventsParser.parseHtml(response.data);
  }

  /// Fetch student-unstaffed events from legacy CMS
  Future<List<StudentEvent>> fetchStudentUnstaffedEvents({
    bool refresh = false,
  }) async {
    final response = await di<HttpService>().get(
      API.studentUnstaffedEventsUrl,
      refresh: refresh,
      legacy: true
    );
    return StudentUnstaffedEventsParser.parseHtml(response.data);
  }
}
