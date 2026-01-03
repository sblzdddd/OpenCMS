import 'package:opencms/di/locator.dart';
import '../../shared/constants/api_endpoints.dart';
import '../models/course_stats_models.dart';
import '../../API/networking/http_service.dart';
import 'package:logging/logging.dart';

final logger = Logger('CourseStatsService');

class CourseStatsService {
  static final CourseStatsService _instance = CourseStatsService._internal();
  factory CourseStatsService() => _instance;
  CourseStatsService._internal();

  /// Fetch course info and attendance statistics for a specific academic year
  Future<List<CourseStats>> fetchCourseStats({
    required int year,
    bool refresh = false,
  }) async {
    try {
      logger.info('Fetching course stats for year $year');

      final url = '${API.courseStatsUrl}?year=$year';

      final response = await di<HttpService>().get(url, refresh: refresh);

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
      logger.severe('Error fetching course stats: $e');
      rethrow;
    }
  }
}
