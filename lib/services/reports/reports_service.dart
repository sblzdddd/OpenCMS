import '../../data/constants/api_constants.dart';
import '../../data/models/reports/reports.dart';
import '../shared/http_service.dart';

/// Service for fetching student reports including:
/// - Reports list grouped by grade
/// - Detailed reports for specific exams
/// - Support for different report types (Regular, PSAT, External Component)
class ReportsService {
  static final ReportsService _instance = ReportsService._internal();
  factory ReportsService() => _instance;
  ReportsService._internal();

  final HttpService _httpService = HttpService();

  /// Fetch all reports grouped by grade level
  /// 
  /// Returns a list of grade groups, each containing exams for that grade
  Future<ReportsListResponse> fetchReportsList() async {
    try {
      print('ReportsService: Fetching reports list');
      
      final response = await _httpService.get(ApiConstants.reportsListUrl);

      if (response.statusCode == 200 || response.statusCode == 304) {
        final jsonData = response.data;
        if (jsonData is List) {
          return ReportsListResponse.fromJson(jsonData);
        } else {
          throw Exception('Invalid response format: expected List');
        }
      } else {
        throw Exception('Failed to fetch reports list: ${response.statusCode}');
      }
    } catch (e) {
      print('ReportsService: Error fetching reports list: $e');
      rethrow;
    }
  }

  /// Fetch detailed report for a specific exam
  /// 
  /// [examId] - ID of the exam to fetch details for
  /// Returns detailed report data based on the exam type
  Future<ReportDetail> fetchReportDetail(int examId) async {
    try {
      print('ReportsService: Fetching report detail for exam $examId');
      
      final response = await _httpService.get(ApiConstants.reportsDetailUrl(examId));

      if (response.statusCode == 200 || response.statusCode == 304) {
        final jsonData = response.data;
        if (jsonData is Map<String, dynamic>) {
          return ReportDetail.fromJson(jsonData);
        } else {
          throw Exception('Invalid response format: expected Map');
        }
      } else {
        throw Exception('Failed to fetch report detail: ${response.statusCode}');
      }
    } catch (e) {
      print('ReportsService: Error fetching report detail for exam $examId: $e');
      rethrow;
    }
  }

  /// Fetch reports for a specific grade level
  /// 
  /// [grade] - Grade level to filter by (e.g., "A1", "G2", "G1")
  /// Returns filtered list of grade groups
  Future<List<GradeGroup>> fetchReportsByGrade(String grade) async {
    try {
      final allReports = await fetchReportsList();
      return allReports.gradeGroups
          .where((group) => group.grade == grade)
          .toList();
    } catch (e) {
      print('ReportsService: Error fetching reports by grade $grade: $e');
      rethrow;
    }
  }

  /// Fetch reports for a specific academic year
  /// 
  /// [year] - Academic year to filter by (e.g., 2024 for 2024-2025)
  /// Returns filtered list of exams across all grades
  Future<List<Exam>> fetchReportsByYear(int year) async {
    try {
      final allReports = await fetchReportsList();
      final List<Exam> exams = [];
      
      for (final group in allReports.gradeGroups) {
        for (final exam in group.exams) {
          if (exam.year == year) {
            exams.add(exam);
          }
        }
      }
      
      return exams;
    } catch (e) {
      print('ReportsService: Error fetching reports by year $year: $e');
      rethrow;
    }
  }

  /// Fetch reports for a specific semester
  /// 
  /// [year] - Academic year
  /// [semester] - Semester number (1 or 2)
  /// Returns filtered list of exams for the specified semester
  Future<List<Exam>> fetchReportsBySemester(int year, int semester) async {
    try {
      final allReports = await fetchReportsList();
      final List<Exam> exams = [];
      
      for (final group in allReports.gradeGroups) {
        for (final exam in group.exams) {
          if (exam.year == year && exam.semester == semester) {
            exams.add(exam);
          }
        }
      }
      
      return exams;
    } catch (e) {
      print('ReportsService: Error fetching reports by semester $year-$semester: $e');
      rethrow;
    }
  }

  /// Get the most recent exam for a specific grade
  /// 
  /// [grade] - Grade level to filter by
  /// Returns the most recent exam based on month field, or null if none found
  Future<Exam?> getMostRecentExam(String grade) async {
    try {
      final gradeReports = await fetchReportsByGrade(grade);
      if (gradeReports.isEmpty) return null;
      
      Exam? mostRecent;
      DateTime? mostRecentDate;
      
      for (final group in gradeReports) {
        for (final exam in group.exams) {
          // Parse month field (format: "2025.08")
          final monthParts = exam.month.split('.');
          if (monthParts.length == 2) {
            final year = int.tryParse(monthParts[0]);
            final month = int.tryParse(monthParts[1]);
            
            if (year != null && month != null) {
              final examDate = DateTime(year, month);
              if (mostRecentDate == null || examDate.isAfter(mostRecentDate)) {
                mostRecentDate = examDate;
                mostRecent = exam;
              }
            }
          }
        }
      }
      
      return mostRecent;
    } catch (e) {
      print('ReportsService: Error getting most recent exam for grade $grade: $e');
      return null;
    }
  }

  /// Get exam statistics for a specific grade
  /// 
  /// [grade] - Grade level to analyze
  /// Returns statistics about exams for the grade
  Future<Map<String, dynamic>> getGradeStatistics(String grade) async {
    try {
      final gradeReports = await fetchReportsByGrade(grade);
      if (gradeReports.isEmpty) {
        return {
          'totalExams': 0,
          'examTypes': {},
          'yearRange': null,
          'semesterDistribution': {},
        };
      }
      
      final List<Exam> allExams = [];
      for (final group in gradeReports) {
        allExams.addAll(group.exams);
      }
      
      // Count exam types
      final Map<String, int> examTypes = {};
      for (final exam in allExams) {
        final type = exam.examType;
        examTypes[type] = (examTypes[type] ?? 0) + 1;
      }
      
      // Get year range
      int? minYear;
      int? maxYear;
      for (final exam in allExams) {
        if (minYear == null || exam.year < minYear) minYear = exam.year;
        if (maxYear == null || exam.year > maxYear) maxYear = exam.year;
      }
      
      // Count semester distribution
      final Map<int, int> semesterDistribution = {};
      for (final exam in allExams) {
        semesterDistribution[exam.semester] = (semesterDistribution[exam.semester] ?? 0) + 1;
      }
      
      return {
        'totalExams': allExams.length,
        'examTypes': examTypes,
        'yearRange': minYear != null && maxYear != null ? '$minYear-$maxYear' : null,
        'semesterDistribution': semesterDistribution,
      };
    } catch (e) {
      print('ReportsService: Error getting grade statistics for $grade: $e');
      return {
        'error': e.toString(),
        'totalExams': 0,
        'examTypes': {},
        'yearRange': null,
        'semesterDistribution': {},
      };
    }
  }
}
