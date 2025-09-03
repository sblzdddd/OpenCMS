import 'package:dio/dio.dart';
import '../../data/constants/api_constants.dart';
import '../../data/models/classroom/free_classroom_response.dart';
import '../../data/models/classroom/all_periods_classroom_response.dart';
import '../auth/auth_service.dart';
import '../shared/http_service.dart';

/// Service for fetching free classroom information
class FreeClassroomService {
  static final FreeClassroomService _instance = FreeClassroomService._internal();
  factory FreeClassroomService() => _instance;
  FreeClassroomService._internal();

  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();

  /// Fetch free classrooms for a specific date and period
  /// 
  /// [date] - Date in yyyy-mm-dd format (e.g., 2025-09-03)
  /// [period] - Period range like W1 (period 1-10), W2 (period 11-14), etc.
  /// [refresh] - Whether to bypass cache
  Future<FreeClassroomResponse> fetchFreeClassrooms({
    required String date,
    required String period,
    bool refresh = false,
  }) async {
    try {
      final username = await _authService.fetchCurrentUsername();
      if (username.isEmpty) {
        throw Exception('Missing username. Please login again.');
      }

      final endpoint = '/$username${ApiConstants.freeClassroomsUrl}';
      
      // Prepare form data
      final body = 'b=$date&w=$period&c=${ApiConstants.classroomsList}';
      print(endpoint);
      print(body);

      final response = await _httpService.postLegacy(
        endpoint,
        body: body,
        refresh: refresh,
      );

      print('FreeClassroomService.fetchFreeClassrooms:');
      print('  Endpoint: $endpoint');
      print('  Body: $body');
      print('  Status Code: ${response.statusCode}');
      print('  Response Data: ${response.data}');

      // Accept both 200 and 304 status codes (304 means cached response)
      if (response.statusCode != 200 && response.statusCode != 304) {
        throw Exception('Failed to fetch free classrooms: ${response.statusCode}');
      }

      // The response is JSON with status, info, and rooms fields
      final Map<String, dynamic> jsonData = response.data;
      
      // Check if the response status is OK
      if (jsonData['status'] != 'OK') {
        throw Exception('API returned error status: ${jsonData['status']} - ${jsonData['info']}');
      }
      
      return FreeClassroomResponse.fromJson(jsonData);
    } catch (e) {
      print('FreeClassroomService: Error fetching free classrooms: $e');
      print((e as DioException).response?.data);
      return FreeClassroomResponse.empty();
    }
  }

  /// Get all individual periods (1-10)
  static List<int> getAllPeriods() {
    return List.generate(10, (index) => index + 1);
  }

  /// Convert period number to API format
  static String periodToApiFormat(int period) {
    return 'W$period';
  }

  /// Fetch free classrooms for all periods asynchronously
  /// Returns a stream that emits updates as each period loads
  Stream<AllPeriodsClassroomResponse> fetchAllPeriodsClassrooms({
    required String date,
    bool refresh = false,
  }) async* {
    AllPeriodsClassroomResponse currentResponse = AllPeriodsClassroomResponse.empty(date);
    yield currentResponse;

    // Start loading all periods
    final futures = <int, Future<FreeClassroomResponse>>{};
    
    for (int period = 1; period <= 10; period++) {
      // Mark period as loading
      currentResponse = currentResponse.copyWith(
        loadingStates: Map.from(currentResponse.loadingStates)..[period] = true,
      );
      yield currentResponse;

      // Start the fetch for this period
      futures[period] = fetchFreeClassrooms(
        date: date,
        period: periodToApiFormat(period),
        refresh: refresh,
      );
    }

    // Process results as they complete
    for (final entry in futures.entries) {
      final period = entry.key;
      final future = entry.value;
      
      try {
        final response = await future;
        print('FreeClassroomService: Period $period completed successfully');
        print('  Classrooms: ${response.freeClassrooms}');
        currentResponse = currentResponse.copyWith(
          periodData: Map.from(currentResponse.periodData)..[period] = response,
          loadingStates: Map.from(currentResponse.loadingStates)..[period] = false,
          errorStates: Map.from(currentResponse.errorStates)..[period] = null,
        );
        yield currentResponse;
      } catch (e) {
        print('FreeClassroomService: Period $period failed with error: $e');
        currentResponse = currentResponse.copyWith(
          loadingStates: Map.from(currentResponse.loadingStates)..[period] = false,
          errorStates: Map.from(currentResponse.errorStates)..[period] = e.toString(),
        );
        yield currentResponse;
      }
    }
  }

  /// Format date for API
  static String formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }
}
