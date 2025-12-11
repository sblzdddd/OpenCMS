/// Calendar service for handling calendar-related API calls
library;

import 'package:dio/dio.dart';
import 'package:opencms/features/auth/login_state.dart';
import 'package:opencms/features/core/di/locator.dart';

import '../../features/core/networking/http_service.dart';
import '../../data/constants/api_endpoints.dart';
import '../../data/models/calendar/calendar.dart';

/// Service for handling calendar operations
class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

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
      final username = di<LoginState>().currentUsername;
      if (username.isEmpty) {
        throw Exception('Missing username. Please login again.');
      }

      final psid = username;

      final response = await di<HttpService>().post(
        '${API.calendarUrl}?psid=$psid&y=$year&p=$year&m=$month&kind=-1',
        data: 'psid=$psid&y=$year&p=$year&m=$month&kind=-1',
        options: (
          Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          )
        ),
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
      final response = await di<HttpService>().post(
        API.calendarDetailUrl,
        data: 'id=$eventId',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        refresh: refresh,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch calendar detail: ${response.statusCode}',
        );
      }

      return CalendarDetailResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Calendar detail service error: $e');
    }
  }

  /// Get today's calendar (new CMS daily endpoint)
  ///
  /// This calls `/legacy/calendar/yyyy-mm-dd/` which returns a JSON array
  /// of calendar items for the provided date. Only today's date is supported
  /// by this convenience method.
  Future<List<CalendarTodayItem>> getTodayCalendar({
    bool refresh = false,
  }) async {
    try {
      final today = DateTime.now();
      final yyyy = today.year.toString().padLeft(4, '0');
      final mm = today.month.toString().padLeft(2, '0');
      final dd = today.day.toString().padLeft(2, '0');
      final dateStr = '$yyyy-$mm-$dd';

      final response = await di<HttpService>().get(
        API.calendarByDateUrl(dateStr),
        refresh: refresh,
      );

      if (!(response.statusCode == 200 || response.statusCode == 304)) {
        throw Exception(
          'Failed to fetch today\'s calendar: ${response.statusCode}',
        );
      }

      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => CalendarTodayItem.fromJson(e))
            .toList();
      } else if (data is Map<String, dynamic> && data['results'] is List) {
        final list = data['results'] as List;
        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => CalendarTodayItem.fromJson(e))
            .toList();
      }

      throw Exception('Unexpected today calendar payload');
    } catch (e) {
      throw Exception('Today calendar service error: $e');
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
      final response = await di<HttpService>().post(
        API.calendarCommentUrl,
        data: 'id=$eventId&kind=$kind',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        refresh: refresh,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch calendar comment: ${response.statusCode}',
        );
      }

      return CalendarCommentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Calendar comment service error: $e');
    }
  }

  /// Get calendar for current month
  Future<CalendarResponse> getCurrentMonthCalendar({
    bool refresh = false,
  }) async {
    final now = DateTime.now();
    return getCalendar(year: now.year, month: now.month, refresh: refresh);
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
  Future<CalendarResponse> getPreviousMonthCalendar({
    bool refresh = false,
  }) async {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1);
    return getCalendar(
      year: prevMonth.year,
      month: prevMonth.month,
      refresh: refresh,
    );
  }
}
