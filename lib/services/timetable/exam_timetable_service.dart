import '../auth/auth_service.dart';
import '../shared/http_service.dart';
import 'exam_timetable_parser.dart';
import '../../data/models/timetable/exam_timetable_entry.dart';

/// Service to fetch and parse exam timetable HTML from legacy CMS
class ExamTimetableService {
  static final ExamTimetableService _instance =
      ExamTimetableService._internal();
  factory ExamTimetableService() => _instance;
  ExamTimetableService._internal();

  final AuthService _authService = AuthService();
  final HttpService _httpService = HttpService();

  Future<List<ExamTimetableEntry>> fetchExamTimetable({
    required int year,
    required int month,
    bool refresh = false,
  }) async {
    final username = await _authService.fetchCurrentUsername();
    if (username.isEmpty) {
      throw Exception('Missing username. Please login again.');
    }

    // Note the double ampersand (as per provided endpoint)
    final endpoint = '/$username/view/examtimetable/?y=$year&&m=$month';

    final response = await _httpService.getLegacy(endpoint, refresh: refresh);

    if (response.statusCode != 200 && response.statusCode != 304) {
      throw Exception('Failed to fetch exam timetable: ${response.statusCode}');
    }

    return parseExamHtml(response.data);
  }
}
