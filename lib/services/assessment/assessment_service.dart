import 'package:flutter/foundation.dart';
import '../shared/http_service.dart';
import '../../data/constants/api_endpoints.dart';
import '../../data/models/assessment/assessment_response.dart';

/// Service for fetching student assessments
class AssessmentService {
  static final AssessmentService _instance = AssessmentService._internal();
  factory AssessmentService() => _instance;
  AssessmentService._internal();

  final HttpService _httpService = HttpService();

  /// Fetch assessments for a specific academic year
  ///
  /// [year] - Academic year (e.g., 2024 for 2024-2025)
  /// [refresh] - Whether to force refresh the cache
  Future<AssessmentResponse> fetchAssessments({
    required int year,
    bool refresh = false,
  }) async {
    try {
      debugPrint('[AssessmentService] Fetching assessments for year $year');

      final url = '${ApiConstants.assessmentsUrl}?year=$year';

      final response = await _httpService.get(url, refresh: refresh);

      final data = response.data;
      if (data != null) {
        return AssessmentResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format: null data');
      }
    } catch (e) {
      debugPrint('[AssessmentService] Error fetching assessments: $e');
      rethrow;
    }
  }

  /// Get assessments for a specific subject
  ///
  /// [year] - Academic year
  /// [subjectName] - Name of the subject to filter by
  /// [refresh] - Whether to force refresh the cache
  Future<List<Assessment>> getAssessmentsBySubject({
    required int year,
    required String subjectName,
    bool refresh = false,
  }) async {
    try {
      final response = await fetchAssessments(year: year, refresh: refresh);

      final subject = response.subjects.firstWhere(
        (subject) => subject.subject.toLowerCase() == subjectName.toLowerCase(),
        orElse: () =>
            SubjectAssessment(id: 0, name: '', subject: '', assessments: []),
      );

      return subject.assessments;
    } catch (e) {
      debugPrint(
        '[AssessmentService] Error getting assessments by subject: $e',
      );
      rethrow;
    }
  }

  /// Get all assessments of a specific type
  ///
  /// [year] - Academic year
  /// [assessmentType] - Type of assessment (e.g., 'Test/Exam', 'Project', 'Homework')
  /// [refresh] - Whether to force refresh the cache
  Future<List<Assessment>> getAssessmentsByType({
    required int year,
    required String assessmentType,
    bool refresh = false,
  }) async {
    try {
      final response = await fetchAssessments(year: year, refresh: refresh);

      final allAssessments = <Assessment>[];
      for (final subject in response.subjects) {
        allAssessments.addAll(
          subject.assessments.where(
            (assessment) =>
                assessment.kind.toLowerCase() == assessmentType.toLowerCase(),
          ),
        );
      }

      return allAssessments;
    } catch (e) {
      debugPrint('[AssessmentService] Error getting assessments by type: $e');
      rethrow;
    }
  }

  /// Calculate overall performance statistics for a subject
  ///
  /// [year] - Academic year
  /// [subjectName] - Name of the subject
  /// [refresh] - Whether to force refresh the cache
  Future<Map<String, dynamic>> getSubjectPerformance({
    required int year,
    required String subjectName,
    bool refresh = false,
  }) async {
    try {
      final assessments = await getAssessmentsBySubject(
        year: year,
        subjectName: subjectName,
        refresh: refresh,
      );

      if (assessments.isEmpty) {
        return {
          'totalAssessments': 0,
          'averageScore': 0.0,
          'highestScore': 0.0,
          'lowestScore': 0.0,
          'testCount': 0,
          'projectCount': 0,
          'homeworkCount': 0,
        };
      }

      final validAssessments = assessments
          .where((a) => a.percentageScore != null)
          .toList();

      if (validAssessments.isEmpty) {
        return {
          'totalAssessments': assessments.length,
          'averageScore': 0.0,
          'highestScore': 0.0,
          'lowestScore': 0.0,
          'testCount': assessments.where((a) => a.isTestOrExam).length,
          'projectCount': assessments.where((a) => a.isProject).length,
          'homeworkCount': assessments.where((a) => a.isHomework).length,
        };
      }

      final scores = validAssessments.map((a) => a.percentageScore!).toList();
      final averageScore = scores.reduce((a, b) => a + b) / scores.length;
      final highestScore = scores.reduce((a, b) => a > b ? a : b);
      final lowestScore = scores.reduce((a, b) => a < b ? a : b);

      return {
        'totalAssessments': assessments.length,
        'averageScore': averageScore,
        'highestScore': highestScore,
        'lowestScore': lowestScore,
        'testCount': assessments.where((a) => a.isTestOrExam).length,
        'projectCount': assessments.where((a) => a.isProject).length,
        'homeworkCount': assessments.where((a) => a.isHomework).length,
      };
    } catch (e) {
      debugPrint(
        '[AssessmentService] Error calculating subject performance: $e',
      );
      rethrow;
    }
  }
}
