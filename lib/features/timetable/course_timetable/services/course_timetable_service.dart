import 'package:opencms/di/locator.dart';
import 'package:opencms/features/auth/services/login_state.dart';

import '../../../API/networking/http_service.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../models/course_timetable_models.dart';
import '../models/course_merged_event.dart';
import 'package:logging/logging.dart';

final logger = Logger('CourseTimetableService');

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
      logger.info(
        'Fetching timetable for year $year, date $date',
      );

      final url = '${API.courseTimetableUrl}?year=$year&date=${di<LoginState>().isMock ? '2026-01-05' : date}';

      final response = await di<HttpService>().get(url, refresh: refresh);

      final data = response.data;
      if (data != null) {
        return TimetableResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format: null data');
      }
    } catch (e, stackTrace) {
      logger.severe('Error fetching timetable: $e', e, stackTrace);
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
    } catch (e, stackTrace) {
      logger.severe('Error getting current and next class: $e', e, stackTrace);
      rethrow;
    }
  }
}
