import 'dart:convert';
import '../../data/constants/api_constants.dart';
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
  }) async {
    try {
      print('CourseTimetableService: Fetching course stats for year $year');
      
      final url = '${ApiConstants.courseStatsUrl}?year=$year';
      
      final response = await _httpService.get(
        url,
        headers: {
          'referer': ApiConstants.timetableReferer,
        },
      );

      if (response.isSuccess) {
        try {
          final jsonData = jsonDecode(response.body);
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
      } else {
        throw Exception('Failed to fetch course stats: ${response.statusCode}');
      }
    } catch (e) {
      print('CourseTimetableService: Error fetching course stats: $e');
      rethrow;
    }
  }
}