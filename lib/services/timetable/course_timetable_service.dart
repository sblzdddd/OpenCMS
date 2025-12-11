import '../../features/core/networking/http_service.dart';
import '../../data/constants/api_endpoints.dart';
import '../../data/models/timetable/timetable_response.dart';
import '../../data/models/timetable/course_merged_event.dart';
import 'package:flutter/foundation.dart';

/// Service for fetching course timetable and course statistics
class CourseTimetableService {
  static final CourseTimetableService _instance =
      CourseTimetableService._internal();
  factory CourseTimetableService() => _instance;
  CourseTimetableService._internal();

  final HttpService _httpService = HttpService();

  /// Fetch course timetable for a specific academic year and date
  ///
  /// [year] - Academic year (e.g., 2025 for 2025-2026)
  /// [date] - Date in yyyy-mm-dd format (e.g., 2025-08-14)
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

      final response = await _httpService.get(url, refresh: refresh);

      final assemblyResponse = await _httpService.get(
        API.assemblyInfoUrl,
        refresh: refresh,
      );

      final data = response.data;
      final assemblyData = assemblyResponse.data;
      if (data != null) {
        return TimetableResponse.fromJson(
          data,
          year,
          assemblyJson: assemblyData,
        );
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

  /// Get current and next class information for a specific date
  Future<Map<String, CourseMergedEvent?>> getCurrentAndNextClassForDate({
    required int year,
    required String date,
    bool refresh = false,
  }) async {
    try {
      final timetable = await fetchCourseTimetable(
        year: year,
        date: date,
        refresh: refresh,
      );

      return timetable.getCurrentAndNextClass();
    } catch (e) {
      debugPrint(
        '[CourseTimetableService] Error getting current and next class for date: $e',
      );
      rethrow;
    }
  }
}
