import 'package:flutter/foundation.dart';
import '../../data/constants/api_endpoints.dart';
import '../../data/models/attendance/course_stats_response.dart';
import '../shared/http_service.dart';

class CourseStatsService {
  static final CourseStatsService _instance = CourseStatsService._internal();
  factory CourseStatsService() => _instance;
  CourseStatsService._internal();

  final HttpService _httpService = HttpService();

  /// Fetch course info and attendance statistics for a specific academic year
  /// 
  /// [year] - Academic year (e.g., 2025 for 2025-2026)
  Future<List<CourseStats>> fetchCourseStats({
    required int year,
    bool refresh = false,
  }) async {
    try {
      debugPrint('CourseTimetableService: Fetching course stats for year $year');
      
      final url = '${ApiConstants.courseStatsUrl}?year=$year';
      
      final response = await _httpService.get(url, refresh: refresh);

      try {
        final jsonData = response.data;
        if (jsonData is List) {
          final List<CourseStats> stats = [];
          for (final item in jsonData) {
            stats.add(CourseStats.fromJson(item as Map<String, dynamic>));
          }
          return stats;
        } else {
          throw Exception('Invalid response format: expected List');
        }
      } catch (e) {
        throw Exception('Failed to parse JSON response: $e');
      }
    } catch (e) {
      debugPrint('CourseTimetableService: Error fetching course stats: $e');
      rethrow;
    }
  }
}