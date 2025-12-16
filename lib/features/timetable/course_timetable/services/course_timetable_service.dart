import 'package:opencms/di/locator.dart';

import '../../../API/networking/http_service.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../models/course_timetable_models.dart';
import '../models/course_merged_event.dart';
import 'package:flutter/foundation.dart';

/// Service for fetching course timetable and course statistics
class CourseTimetableService {
  static final CourseTimetableService _instance =
      CourseTimetableService._internal();
  factory CourseTimetableService() => _instance;
  CourseTimetableService._internal();

  /// Fetch course timetable for a specific academic year and date
  Future<TimetableResponse> fetchCourseTimetable({
    required int year,
    required String date,
    bool refresh = false,
  }) async {
    try {
      debugPrint(
        '[CourseTimetableService] Fetching timetable for year $year, date $date',
      );

      final url = '${API.courseTimetableUrl}?year=$year&date=$date';

      final response = await di<HttpService>().get(url, refresh: refresh);

      final data = response.data;
      if (data != null) {
        return TimetableResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format: null data');
      }
    } catch (e) {
      debugPrint('[CourseTimetableService] Error fetching timetable: $e');
      rethrow;
    }
  }

  /// Get current and next class information for today
  Future<Map<String, CourseMergedEvent?>> getCurrentAndNextClass({
    required int year,
    bool refresh = false,
  }) async {
    try {
      final today = DateTime.now();
      final dateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final timetable = await fetchCourseTimetable(
        year: year,
        date: dateString,
        refresh: refresh,
      );

      return timetable.getCurrentAndNextClass();
    } catch (e) {
      debugPrint(
        '[CourseTimetableService] Error getting current and next class: $e',
      );
      rethrow;
    }
  }
}
