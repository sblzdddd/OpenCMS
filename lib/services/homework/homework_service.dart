import '../../data/models/homework/homework_response.dart';
import '../shared/http_service.dart';
import '../auth/auth_service.dart';
import 'homework_parser.dart';

class HomeworkService {
  static final HomeworkService _instance = HomeworkService._internal();
  factory HomeworkService() => _instance;
  HomeworkService._internal();

  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();

  /// Fetch homework for a specific academic year with optional filters
  /// 
  /// [academicYear] - Academic year (e.g., 2025 for 2025-2026)
  /// [courseId] - Optional course ID filter
  /// [dueDateStart] - Optional start date filter (yyyy-mm-dd)
  /// [dueDateEnd] - Optional end date filter (yyyy-mm-dd)
  /// [page] - Page number for pagination (defaults to 1)
  Future<HomeworkResponse> fetchHomework({
    required int academicYear,
    String? courseId,
    String? dueDateStart,
    String? dueDateEnd,
    int page = 1,
  }) async {
    try {
      print('HomeworkService: Fetching homework for year $academicYear, page $page');
      
      // Get username for legacy URL
      final username = await _authService.fetchCurrentUsername();
      if (username.isEmpty) {
        throw Exception('Missing username. Please login again.');
      }
      
      // Add optional form fields
      courseId ??= "";
      dueDateStart ??= "";
      dueDateEnd ??= "";
      
      // Page parameter is handled in URL path for legacy CMS
      String endpoint = '/$username/homework/$page/?duedate=$dueDateStart&duedate2=$dueDateEnd&courseid=$courseId&fy=$academicYear';
      
      final response = await _httpService.getLegacy(endpoint);

      final html = response.data;
      if (html != null && html is String) {
        return parseHomeworkHtml(html);
      } else {
        throw Exception('Invalid response format: expected HTML string');
      }
    } catch (e) {
      print('HomeworkService: Error fetching homework: $e');
      rethrow;
    }
  }

  /// Mark a homework item as completed
  /// 
  /// [homeworkId] - ID of the homework to mark as completed
  Future<bool> markHomeworkCompleted(String homeworkId) async {
    try {
      print('HomeworkService: Marking homework $homeworkId as completed');
      
      // Get username for legacy URL
      final username = await _authService.fetchCurrentUsername();
      if (username.isEmpty) {
        throw Exception('Missing username. Please login again.');
      }
      
      final endpoint = '/$username/homework/marktofinished/$homeworkId/';
      
      final response = await _httpService.getLegacy(endpoint);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to mark homework as completed: ${response.statusCode}');
      }
    } catch (e) {
      print('HomeworkService: Error marking homework as completed: $e');
      rethrow;
    }
  }
}


