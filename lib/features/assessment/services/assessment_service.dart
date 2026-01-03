import 'package:logging/logging.dart';
import 'package:opencms/di/locator.dart';
import '../../API/networking/http_service.dart';
import '../../shared/constants/api_endpoints.dart';
import '../models/assessment_models.dart';


final logger = Logger('AssessmentService');

/// Service for fetching student assessments
class AssessmentService {
  static final AssessmentService _instance = AssessmentService._internal();
  factory AssessmentService() => _instance;
  AssessmentService._internal();

  /// Fetch assessments for a specific academic year
  Future<AssessmentResponse> fetchAssessments({
    required int year,
    bool refresh = false,
  }) async {
    try {
      logger.info('Fetching assessments for year $year');

      final response = await di<HttpService>().get(
        '${API.assessmentsUrl}?year=$year',
        refresh: refresh
      );
      final data = response.data;
      if (data != null) {
        return AssessmentResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format: null data');
      }
    } catch (e) {
      logger.severe('Error fetching assessments: $e');
      rethrow;
    }
  }

  /// Get assessments for a specific subject
  Future<List<Assessment>> getAssessmentsBySubject({
    required int year,
    required String subjectName,
    bool refresh = false,
  }) async {
    try {
      final response = await fetchAssessments(year: year, refresh: refresh);

      final subject = response.subjects.firstWhere(
        (subject) => subject.subject.toLowerCase() == subjectName.toLowerCase(),
        orElse: () => SubjectAssessment(id: 0, name: '', subject: '', assessments: []),
      );

      return subject.assessments;
    } catch (e) {
      logger.severe('Error getting assessments by subject: $e');
      rethrow;
    }
  }
}
