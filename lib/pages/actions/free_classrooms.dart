import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
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
  int _selectedPeriod = 1;
  AllPeriodsClassroomResponse? _allPeriodsData;
  StreamSubscription<AllPeriodsClassroomResponse>? _dataSubscription;

  @override
  String get appBarTitle => 'Free Classrooms';

  @override
  List<Widget>? get appBarActions => [
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () => loadData(refresh: true),
      tooltip: 'Refresh',
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

  void _onPeriodChanged(int? newPeriod) {
    if (newPeriod != null && newPeriod != _selectedPeriod) {
      setState(() {
        _selectedPeriod = newPeriod;
      });
    }
  }

  Widget _buildDateSelector() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date & Period',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedPeriod,
                    onChanged: _onPeriodChanged,
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: FreeClassroomService.getAllPeriods()
                        .map((period) => DropdownMenuItem(
                              value: period,
                              child: Text(
                                'Period $period',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassroomCard(String classroom) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.meeting_room,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          classroom,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Available',
          style: TextStyle(
            color: Colors.green.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPeriodStatusCard(int period) {
    if (_allPeriodsData == null) {
      return const SizedBox.shrink();
    }

    final isLoading = _allPeriodsData!.isLoading(period);
    final hasError = _allPeriodsData!.hasError(period);
    final errorMessage = _allPeriodsData!.getError(period);

    if (isLoading) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          title: Text(
            'Period $period',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: const Text(
            'Loading classrooms...',
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    if (hasError) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: 20,
            ),
          ),
          title: Text(
            'Period $period',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            'Error: ${errorMessage ?? 'Unknown error'}',
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 14,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => loadData(refresh: true),
            tooltip: 'Retry',
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildClassroomsList() {
    if (_allPeriodsData == null) {
      return const SizedBox.shrink();
    }

    final classrooms = _allPeriodsData!.getClassroomsForPeriod(_selectedPeriod);
    final isLoading = _allPeriodsData!.isLoading(_selectedPeriod);
    final hasError = _allPeriodsData!.hasError(_selectedPeriod);
    final hasData = _allPeriodsData!.hasData(_selectedPeriod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show loading/error status for selected period
        if (isLoading || hasError) _buildPeriodStatusCard(_selectedPeriod),
        
        // Show classrooms if data is available
        if (hasData && classrooms.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Available Classrooms for Period $_selectedPeriod (${classrooms.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...classrooms.map((classroom) => _buildClassroomCard(classroom)),
        ],
        
        // Show empty state if no classrooms available
        if (hasData && classrooms.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'No free classrooms for Period $_selectedPeriod',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.meeting_room_outlined,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
              title: const Text(
                'All classrooms are occupied',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text(
                'Try selecting a different period',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget buildPageContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateSelector(),
        const SizedBox(height: 8),
        Expanded(
          child: _buildClassroomsList(),
        ),
      ],
    );
  }

  @override
  bool get isEmpty => _allPeriodsData == null || !_allPeriodsData!.hasData(_selectedPeriod);

  @override
  String get errorTitle => 'Error loading free classrooms';

  @override
  Widget buildEmptyWidget(BuildContext context) {
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
                'Try selecting a different date or period',
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
