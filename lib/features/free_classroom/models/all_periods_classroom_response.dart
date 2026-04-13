/// Model for storing free classroom data for all periods
library;

import 'package:opencms/features/shared/constants/period_constants.dart';

import 'free_classroom_response.dart';

const int kPastoralPeriodId = 26;

/// Teaching periods 1–10 + Pastoral ([kPastoralPeriodId]).
const List<int> kFreeClassroomPeriodOrder = [
  1,
  2,
  3,
  4,
  5,
  6,
  kPastoralPeriodId,
  7,
  8,
  9,
  10,
];

class AllPeriodsClassroomResponse {
  final Map<int, FreeClassroomResponse> periodData;
  final String date;
  final Map<int, bool> loadingStates;
  final Map<int, String?> errorStates;

  final Map<int, PeriodInfo> slotTimes;

  const AllPeriodsClassroomResponse({
    required this.periodData,
    required this.date,
    required this.loadingStates,
    required this.errorStates,
    this.slotTimes = const {},
  });

  factory AllPeriodsClassroomResponse.empty(String date) {
    final Map<int, bool> loadingStates = {};
    final Map<int, String?> errorStates = {};

    for (final i in kFreeClassroomPeriodOrder) {
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
    Map<int, PeriodInfo>? slotTimes,
  }) {
    return AllPeriodsClassroomResponse(
      periodData: periodData ?? this.periodData,
      date: date ?? this.date,
      loadingStates: loadingStates ?? this.loadingStates,
      errorStates: errorStates ?? this.errorStates,
      slotTimes: slotTimes ?? this.slotTimes,
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
    for (final i in kFreeClassroomPeriodOrder) {
      if (!hasData(i) && !hasError(i) && !isLoading(i)) {
        return false;
      }
    }
    return true;
  }
}
