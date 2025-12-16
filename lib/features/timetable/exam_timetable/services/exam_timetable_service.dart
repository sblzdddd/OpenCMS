import 'package:opencms/features/shared/constants/api_endpoints.dart';
import 'package:opencms/di/locator.dart';

import '../../../API/networking/http_service.dart';
import '../models/exam_timetable_models.dart';

/// Service to fetch and parse exam timetable HTML from legacy CMS
class ExamTimetableService {
  static final ExamTimetableService _instance =
      ExamTimetableService._internal();
  factory ExamTimetableService() => _instance;
  ExamTimetableService._internal();

  Future<List<ExamTimetableEntry>> fetchExamTimetable({
    required int year,
    bool refresh = false,
  }) async {
    final response = await di<HttpService>().get('${API.examTimetableUrl}?year=$year', refresh: refresh);

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
