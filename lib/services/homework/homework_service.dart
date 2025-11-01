import '../../data/models/homework/homework_response.dart';
import '../shared/http_service.dart';
import '../../data/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

class HomeworkService {
  static final HomeworkService _instance = HomeworkService._internal();
  factory HomeworkService() => _instance;
  HomeworkService._internal();

  final HttpService _httpService = HttpService();

  /// Fetch homework for a specific academic year with optional filters
  ///
  /// [academicYear] - Academic year (e.g., 2025 for 2025-2026)
  Future<HomeworkResponse> fetchHomework({
    required int academicYear,
    bool refresh = false,
  }) async {
    try {
      debugPrint('[HomeworkService] Fetching homework for year $academicYear');

      // New API endpoint
      final endpoint = '${ApiConstants.homeworkUrl}?year=$academicYear';

      final response = await _httpService.get(endpoint, refresh: refresh);

      if (response.data != null) {
        return HomeworkResponse.fromJson(response.data as List<dynamic>);
      } else {
        throw Exception('Invalid response format: expected JSON array');
      }
    } catch (e) {
      debugPrint('[HomeworkService] Error fetching homework: $e');
      rethrow;
    }
  }

  /// Mark a homework item as completed
  /// Note: This functionality may not be available in the new API
  ///
  /// [homeworkId] - ID of the homework to mark as completed
  Future<bool> markHomeworkCompleted(int homeworkId) async {
    try {
      debugPrint('[HomeworkService] Marking homework $homeworkId as completed');

      // TODO: Implement when new API supports marking homework as completed
      // For now, return false to indicate this feature is not available
      debugPrint(
        '[HomeworkService] Marking homework as completed not supported in new API yet',
      );
      return false;
    } catch (e) {
      debugPrint('[HomeworkService] Error marking homework as completed: $e');
      rethrow;
    }
  }
}
