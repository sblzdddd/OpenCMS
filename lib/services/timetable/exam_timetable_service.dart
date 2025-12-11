import 'package:opencms/data/constants/api_endpoints.dart';
import 'package:opencms/features/auth/login_state.dart';
import 'package:opencms/features/core/di/locator.dart';

import '../../features/core/networking/http_service.dart';
import '../../data/models/timetable/exam_timetable_entry.dart';

/// Service to fetch and parse exam timetable HTML from legacy CMS
class ExamTimetableService {
  static final ExamTimetableService _instance =
      ExamTimetableService._internal();
  factory ExamTimetableService() => _instance;
  ExamTimetableService._internal();

  Future<List<ExamTimetableEntry>> fetchExamTimetable({
    required int year,
    required int month,
    bool refresh = false,
  }) async {
    final username = di<LoginState>().currentUsername;
    if (username.isEmpty) {
      throw Exception('Missing username. Please login again.');
    }

    final response = await di<HttpService>().get(API.examTimetableUrl, refresh: refresh);

    if (response.statusCode != 200 && response.statusCode != 304) {
      throw Exception('Failed to fetch exam timetable: ${response.statusCode}');
    }

    final List<ExamTimetableEntry> examEntries = [];
    final data = response.data;
    if (data is List) {
      for (var item in data) {
        if (item is Map<String, dynamic>) {
          final entry = ExamTimetableEntry.fromJson(item);
          examEntries.add(entry);
        }
      }
    } else {
      throw Exception('Invalid response format for exam timetable');
    }
    return examEntries;
  }
}
