import 'package:logging/logging.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/API/networking/http_service.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/features/free_classroom/models/all_periods_classroom_response.dart';
import 'package:opencms/features/free_classroom/models/free_classroom_response.dart';
import 'package:opencms/features/shared/constants/api_endpoints.dart';
import 'package:opencms/features/shared/constants/period_constants.dart';

final logger = Logger('FreeClassroomService');

/// Service for fetching free classroom information
class FreeClassroomService {
  static final FreeClassroomService _instance =
      FreeClassroomService._internal();
  factory FreeClassroomService() => _instance;
  FreeClassroomService._internal();

  PeriodInfo? _periodInfoFromSlot(Map<String, dynamic> slot, int period) {
    final tr = slot['time_range']?.toString().trim();
    if (tr == null || tr.isEmpty) return null;
    final m = RegExp(r'^(\d{1,2}:\d{2})-(\d{1,2}:\d{2})$').firstMatch(tr);
    if (m == null) return null;
    final label = slot['label']?.toString().trim();
    final name = (label != null && label.isNotEmpty)
        ? label
        : (period == kPastoralPeriodId ? 'Pastoral' : 'Period $period');
    return PeriodInfo(name: name, startTime: m[1]!, endTime: m[2]!);
  }

  AllPeriodsClassroomResponse _parsePayload(
    Map<String, dynamic> json,
    String date,
  ) {
    final slots = json['slots'];
    if (slots is! List<dynamic>) {
      throw const FormatException('Invalid free classroom payload: missing slots');
    }

    final Map<int, FreeClassroomResponse> periodData = {
      for (final p in kFreeClassroomPeriodOrder) p: FreeClassroomResponse.empty(),
    };
    final Map<int, PeriodInfo> slotTimes = {};

    for (final raw in slots) {
      if (raw is! Map) continue;
      final slot = Map<String, dynamic>.from(raw);
      final period = int.tryParse(slot['period']?.toString() ?? '');
      if (period == null) continue;
      if (period != kPastoralPeriodId &&
          (period < 1 || period > 10)) {
        continue;
      }

      final pi = _periodInfoFromSlot(slot, period);
      if (pi != null) {
        slotTimes[period] = pi;
      }

      final roomsList = slot['available_rooms'];
      final labels = <String>[];
      if (roomsList is List<dynamic>) {
        for (final room in roomsList) {
          if (room is! Map) continue;
          final m = Map<String, dynamic>.from(room);
          final label = m['label']?.toString();
          final value = m['value']?.toString();
          final s = (label != null && label.isNotEmpty) ? label : (value ?? '');
          if (s.isNotEmpty) labels.add(s);
        }
      }

      periodData[period] = FreeClassroomResponse(
        status: 'OK',
        info: '',
        rooms: labels.join(' '),
      );
    }

    return AllPeriodsClassroomResponse(
      periodData: periodData,
      date: date,
      loadingStates: {for (final i in kFreeClassroomPeriodOrder) i: false},
      errorStates: {for (final i in kFreeClassroomPeriodOrder) i: null},
      slotTimes: slotTimes,
    );
  }

  /// Fetch free classrooms for all periods (single API request).
  Stream<AllPeriodsClassroomResponse> fetchAllPeriodsClassrooms({
    required String date,
    bool refresh = false,
  }) async* {
    final effectiveDate = di<LoginState>().isMock ? '2026-01-05' : date;

    yield AllPeriodsClassroomResponse.empty(date).copyWith(
      loadingStates: {for (final i in kFreeClassroomPeriodOrder) i: true},
    );

    try {
      final response = await di<HttpService>().get(
        API.freeClassroomMyUrl,
        data: {'date': effectiveDate},
        refresh: refresh,
      );

      if (response.statusCode != 200 && response.statusCode != 304) {
        throw Exception(
          'Failed to fetch free classrooms: ${response.statusCode}',
        );
      }

      final data = response.data;
      if (data is! Map) {
        throw Exception('Invalid free classroom response format');
      }

      final json = Map<String, dynamic>.from(data);
      yield _parsePayload(json, date);
    } catch (e, st) {
      logger.severe('Error fetching free classrooms: $e', e, st);
      yield AllPeriodsClassroomResponse.empty(date).copyWith(
        loadingStates: {for (final i in kFreeClassroomPeriodOrder) i: false},
        errorStates: {for (final i in kFreeClassroomPeriodOrder) i: e.toString()},
      );
    }
  }

  /// Format date for API
  static String formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }
}
