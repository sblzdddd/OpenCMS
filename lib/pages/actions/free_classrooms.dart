import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../data/constants/periods.dart';
import '../../data/models/classroom/all_periods_classroom_response.dart';
import '../../services/classroom/free_classroom_service.dart';
import '../../ui/shared/views/refreshable_page.dart';

class FreeClassroomsPage extends StatefulWidget {
  const FreeClassroomsPage({super.key});

  @override
  State<FreeClassroomsPage> createState() => _FreeClassroomsPageState();
}

class _FreeClassroomsPageState extends RefreshablePage<FreeClassroomsPage> {
  final FreeClassroomService _freeClassroomService = FreeClassroomService();
  
  DateTime _selectedDate = DateTime.now();
  AllPeriodsClassroomResponse? _allPeriodsData;
  StreamSubscription<AllPeriodsClassroomResponse>? _dataSubscription;

  @override
  String get appBarTitle => 'Free Classrooms';

  @override
  List<Widget>? get appBarActions => [
    OutlinedButton.icon(
      onPressed: () => _selectDate(context),
      icon: const Icon(Icons.calendar_today, size: 18),
      label: Text(
        DateFormat('MMM dd, yyyy').format(_selectedDate),
        style: const TextStyle(fontSize: 14),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final dateString = FreeClassroomService.formatDate(_selectedDate);
    
    // Cancel previous subscription
    _dataSubscription?.cancel();
    
    // Start new stream subscription
    _dataSubscription = _freeClassroomService.fetchAllPeriodsClassrooms(
      date: dateString,
      refresh: refresh,
    ).listen((response) {
      setState(() {
        _allPeriodsData = response;
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select date',
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await loadData(refresh: true);
    }
  }

  Widget _buildClassroomBadge(String classroom) {
    return Container(
      margin: const EdgeInsets.only(right: 2, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.meeting_room,
            size: 14,
            color: Colors.green.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 4),
          Text(
            classroom,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.green.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(int period) {
    final isInitialLoading = _allPeriodsData == null;
    final isLoading = _allPeriodsData?.isLoading(period) ?? false;
    final hasError = _allPeriodsData?.hasError(period) ?? false;
    final errorMessage = _allPeriodsData?.getError(period);
    final classrooms = _allPeriodsData?.getClassroomsForPeriod(period) ?? [];
    final hasData = _allPeriodsData?.hasData(period) ?? false;
    final periodTime = PeriodConstants.periods.firstWhere((p) => p.name == 'Period $period').startTime;
    final periodEndTime = PeriodConstants.periods.firstWhere((p) => p.name == 'Period $period').endTime;
    
    return Card(
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$periodTime - $periodEndTime',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (hasError)
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () => loadData(refresh: true),
                    tooltip: 'Retry',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (isInitialLoading || isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(strokeWidth: 2),
                    SizedBox(height: 8),
                    Text(
                      'Loading classrooms...',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else if (hasError)
              Text(
                'Error: ${errorMessage ?? 'Unknown error'}',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 14,
                ),
              )
            else if (hasData)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${classrooms.length} free classroom${classrooms.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (classrooms.isNotEmpty)
                    Wrap(
                      children: classrooms.map((classroom) => _buildClassroomBadge(classroom)).toList(),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: themeNotifier.getBorderRadiusAll(0.5),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.meeting_room_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'All classrooms occupied',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllPeriodsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...FreeClassroomService.getAllPeriods().map((period) => _buildPeriodCard(period)),
      ],
    );
  }

  @override
  Widget buildPageContent(BuildContext context, ThemeNotifier themeNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildAllPeriodsList(),
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: bodyPadding,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAllPeriodsList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isEmpty {
    if (_allPeriodsData == null) return true;
    
    // Don't show empty state if we're still loading any period
    if (_allPeriodsData!.isAnyLoading) return false;
    
    // Don't show empty state if there are any errors
    for (int period = 1; period <= 10; period++) {
      if (_allPeriodsData!.hasError(period)) return false;
    }
    
    // Show empty state only if all periods have data but no classrooms
    bool allPeriodsHaveData = true;
    bool allPeriodsEmpty = true;
    
    for (int period = 1; period <= 10; period++) {
      if (!_allPeriodsData!.hasData(period)) {
        allPeriodsHaveData = false;
        break;
      }
      if (_allPeriodsData!.getClassroomsForPeriod(period).isNotEmpty) {
        allPeriodsEmpty = false;
      }
    }
    
    return allPeriodsHaveData && allPeriodsEmpty;
  }

  @override
  String get errorTitle => 'Error loading free classrooms';

  @override
  Widget buildEmptyWidget(BuildContext context, ThemeNotifier themeNotifier) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.meeting_room_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No free classrooms available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'All classrooms are occupied for this date',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
