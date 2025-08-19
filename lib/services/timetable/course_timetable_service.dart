import '../shared/http_service.dart';
import '../../data/constants/api_constants.dart';
import '../../data/models/timetable/timetable_response.dart';

/// Service for fetching course timetable and course statistics
class CourseTimetableService {
  static final CourseTimetableService _instance = CourseTimetableService._internal();
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
  }) async {
    try {
      print('CourseTimetableService: Fetching timetable for year $year, date $date');
      
      final url = '${ApiConstants.courseTimetableUrl}?year=$year&date=$date';
      
      final response = await _httpService.get(
        url,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          return TimetableResponse.fromJson(data);
        } else {
          throw Exception('Invalid response format: null data');
        }
      } else {
        throw Exception('Failed to fetch timetable: ${response.statusCode}');
      }
    } catch (e) {
      print('CourseTimetableService: Error fetching timetable: $e');
      rethrow;
    }
  }
}