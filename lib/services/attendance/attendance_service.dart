import '../../data/constants/api_endpoints.dart';
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
    bool refresh = false,
  }) async {
    final DateTime today = DateTime.now();
    DateTime start = startDate ?? DateTime(today.year - 1, 8, 1);
    if (today.month >= 8 && today.day >= 1) {
      start = DateTime(today.year, 8, 1);
    }
    final DateTime end = endDate ?? today;

    final String startStr = _fmt(start);
    final String endStr = _fmt(end);

    final String url =
        '${ApiConstants.attendanceUrl}?start_date=$startStr&end_date=$endStr';

    final response = await _httpService.get(url, refresh: refresh);

    final Map<String, dynamic> jsonData = response.data as Map<String, dynamic>;
    return AttendanceResponse.fromJson(jsonData);
  }

  String _fmt(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}
