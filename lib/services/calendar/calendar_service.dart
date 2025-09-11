/// Calendar service for handling calendar-related API calls
library;

import '../shared/http_service.dart';
import '../auth/auth_service.dart';
import '../../data/constants/api_constants.dart';
import '../../data/models/calendar/calendar.dart';

/// Service for handling calendar operations
class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();

  /// Get calendar data for a specific month
  /// 
  /// Parameters:
  /// - [year]: Year (e.g., 2025)
  /// - [month]: Month (1-12)
  /// - [refresh]: Whether to refresh cache
  Future<CalendarResponse> getCalendar({
    required int year,
    required int month,
    bool refresh = false,
  }) async {
    try {
      final username = await _authService.fetchCurrentUsername();
      if (username.isEmpty) {
        throw Exception('Missing username. Please login again.');
      }

      // Extract psid from username (e.g., "s22103" from username)
      final psid = username;

      final response = await _httpService.postLegacy(
        ApiConstants.calendarUrl,
        body: 'psid=$psid&y=$year&p=$year&m=$month&kind=-1',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        refresh: refresh,
      );

      return CalendarResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Calendar service error: $e');
    }
  }

  /// Get detailed information for a specific calendar event
  /// 
  /// Parameters:
  /// - [eventId]: The ID of the calendar event
  /// - [refresh]: Whether to refresh cache
  Future<CalendarDetailResponse> getCalendarDetail({
    required String eventId,
    bool refresh = false,
  }) async {
    try {
      final response = await _httpService.postLegacy(
        ApiConstants.calendarDetailUrl,
        body: 'id=$eventId',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        refresh: refresh,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch calendar detail: ${response.statusCode}');
      }

      return CalendarDetailResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Calendar detail service error: $e');
    }
  }

  /// Get comment information for a specific calendar event
  /// 
  /// Parameters:
  /// - [eventId]: The ID of the calendar event
  /// - [kind]: The kind of comment (e.g., "ft_title", "fv_title", "ve_title", "sle_title", "sue_title")
  /// - [refresh]: Whether to refresh cache
  Future<CalendarCommentResponse> getCalendarComment({
    required String eventId,
    required String kind,
    bool refresh = false,
  }) async {
    try {
      final response = await _httpService.postLegacy(
        ApiConstants.calendarCommentUrl,
        body: 'id=$eventId&kind=$kind',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        refresh: refresh,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch calendar comment: ${response.statusCode}');
      }

      return CalendarCommentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Calendar comment service error: $e');
    }
  }

  /// Get calendar for current month
  Future<CalendarResponse> getCurrentMonthCalendar({bool refresh = false}) async {
    final now = DateTime.now();
    return getCalendar(
      year: now.year,
      month: now.month,
      refresh: refresh,
    );
  }

  /// Get calendar for next month
  Future<CalendarResponse> getNextMonthCalendar({bool refresh = false}) async {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1);
    return getCalendar(
      year: nextMonth.year,
      month: nextMonth.month,
      refresh: refresh,
    );
  }

  /// Get calendar for previous month
  Future<CalendarResponse> getPreviousMonthCalendar({bool refresh = false}) async {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1);
    return getCalendar(
      year: prevMonth.year,
      month: prevMonth.month,
      refresh: refresh,
    );
  }
}
