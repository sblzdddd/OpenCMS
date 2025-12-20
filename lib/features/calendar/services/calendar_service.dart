library;

import 'package:dio/dio.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/di/locator.dart';

import '../../API/networking/http_service.dart';
import '../../shared/constants/api_endpoints.dart';
import '../models/calendar.dart';

/// Service for handling calendar operations
class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  /// Get calendar data for a specific month
  Future<CalendarResponse> getCalendar({
    required int year,
    required int month,
    bool refresh = false,
  }) async {
    final username = di<LoginState>().currentUsername;
    if (username.isEmpty) {
      throw Exception('Missing username. Please login again.');
    }

    final response = await di<HttpService>().post(
      '${API.calendarUrl}?psid=$username&y=$year&p=$year&m=$month&kind=-1',
      data: 'psid=$username&y=$year&p=$year&m=$month&kind=-1',
      options: (
        Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        )
      ),
      refresh: refresh,
      legacy: true,
      ignoreLegacyUsername: true,
    );

    return CalendarResponse.fromJson(response.data);
  }

  /// Get detailed information for a specific calendar event
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
        legacy: true,
        ignoreLegacyUsername: true,
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
        legacy: true,
        ignoreLegacyUsername: true,
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
}
