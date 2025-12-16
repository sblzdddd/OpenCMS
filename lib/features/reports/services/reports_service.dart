import 'package:opencms/di/locator.dart';

import '../../shared/constants/api_endpoints.dart';
import '../models/reports.dart';
import '../../API/networking/http_service.dart';
import 'package:flutter/foundation.dart';

/// Service for fetching student reports
class ReportsService {
  static final ReportsService _instance = ReportsService._internal();
  factory ReportsService() => _instance;
  ReportsService._internal();

  /// Fetch all reports grouped by grade level
  Future<ReportsListResponse> fetchReportsList({bool refresh = false}) async {
    try {
      debugPrint('[ReportsService] Fetching reports list');

      final response = await di<HttpService>().get(
        API.reportsListUrl,
        refresh: refresh,
      );

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
      debugPrint('[ReportsService] Error fetching reports list: $e');
      rethrow;
    }
  }

  /// Fetch detailed report for a specific exam
  Future<ReportDetail> fetchReportDetail(
    int examId, {
    bool refresh = false,
  }) async {
    try {
      debugPrint('[ReportsService] Fetching report detail for exam $examId');

      final response = await di<HttpService>().get(
        API.reportsDetailUrl(examId),
        refresh: refresh,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final jsonData = response.data;
        if (jsonData is Map<String, dynamic>) {
          return ReportDetail.fromJson(jsonData);
        } else {
          throw Exception('Invalid response format: expected Map');
        }
      } else {
        throw Exception(
          'Failed to fetch report detail: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint(
        '[ReportsService] Error fetching report detail for exam $examId: $e',
      );
      rethrow;
    }
  }
}
