/// Model for storing free classroom data for all periods
library;

import 'free_classroom_response.dart';

class AllPeriodsClassroomResponse {
  final Map<int, FreeClassroomResponse> periodData;
  final String date;
  final Map<int, bool> loadingStates;
  final Map<int, String?> errorStates;

  const AllPeriodsClassroomResponse({
    required this.periodData,
    required this.date,
    required this.loadingStates,
    required this.errorStates,
  });

  factory AllPeriodsClassroomResponse.empty(String date) {
    final Map<int, bool> loadingStates = {};
    final Map<int, String?> errorStates = {};

    // Initialize loading states for periods 1-10
    for (int i = 1; i <= 10; i++) {
      loadingStates[i] = false;
      errorStates[i] = null;
    }

    return AllPeriodsClassroomResponse(
      periodData: {},
      date: date,
      loadingStates: loadingStates,
      errorStates: errorStates,
    );
  }

  AllPeriodsClassroomResponse copyWith({
    Map<int, FreeClassroomResponse>? periodData,
    String? date,
    Map<int, bool>? loadingStates,
    Map<int, String?>? errorStates,
  }) {
    return AllPeriodsClassroomResponse(
      periodData: periodData ?? this.periodData,
      date: date ?? this.date,
      loadingStates: loadingStates ?? this.loadingStates,
      errorStates: errorStates ?? this.errorStates,
    );
  }

  List<String> getClassroomsForPeriod(int period) {
    final data = periodData[period];
    return data?.freeClassrooms ?? [];
  }

  bool isLoading(int period) {
    return loadingStates[period] ?? false;
  }

  bool hasError(int period) {
    return errorStates[period] != null;
  }

  String? getError(int period) {
    return errorStates[period];
  }

  bool hasData(int period) {
    return periodData.containsKey(period) && !hasError(period);
  }

  List<int> getAvailablePeriods() {
    return periodData.keys.where((period) => hasData(period)).toList()..sort();
  }

  bool get isAnyLoading => loadingStates.values.any((loading) => loading);

  bool get isAllLoaded {
    for (int i = 1; i <= 10; i++) {
      if (!hasData(i) && !hasError(i) && !isLoading(i)) {
        return false;
      }
    }
    return true;
  }
}
