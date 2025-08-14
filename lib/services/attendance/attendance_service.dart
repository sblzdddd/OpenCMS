import 'dart:convert';
import '../../data/constants/api_constants.dart';
import '../../data/models/attendance/attendance_response.dart';
import '../shared/http_service.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final HttpService _httpService = HttpService();

  /// Fetch attendance between [startDate] and [endDate] (inclusive)
  /// If not provided, defaults to 1 year prior to today through today.
  Future<AttendanceResponse> fetchAttendance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final DateTime today = DateTime.now();
    final DateTime start = startDate ?? DateTime(today.year - 1, today.month, today.day);
    final DateTime end = endDate ?? today;

    final String startStr = _fmt(start);
    final String endStr = _fmt(end);

    final String url = '${ApiConstants.attendanceUrl}?start_date=$startStr&end_date=$endStr';

    final response = await _httpService.get(
      url,
      headers: {
        'referer': ApiConstants.timetableReferer,
      },
    );

    if (!response.isSuccess) {
      throw Exception('Failed to fetch attendance: ${response.statusCode}');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    return AttendanceResponse.fromJson(jsonData);
  }

  String _fmt(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}


