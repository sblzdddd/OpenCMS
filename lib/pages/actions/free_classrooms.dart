import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/data/constants/sfcalendar_theme_data.dart';
import 'dart:async';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
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
  late CalendarController _calendarController;

  DateTime _selectedDate = DateTime.now();
  AllPeriodsClassroomResponse? _allPeriodsData;
  StreamSubscription<AllPeriodsClassroomResponse>? _dataSubscription;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  String get skinKey => 'free_classrooms';

  @override
  String get appBarTitle => 'Free Classrooms';

  @override
  List<Widget>? get appBarActions => [
    IconButton(
      icon: const Icon(Symbols.refresh_rounded),
      onPressed: () => loadData(refresh: true),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    loadData();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Future<void> fetchData({bool refresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final dateString = FreeClassroomService.formatDate(_selectedDate);

    // Cancel previous subscription
    _dataSubscription?.cancel();

    // Start new stream subscription
    _dataSubscription = _freeClassroomService
        .fetchAllPeriodsClassrooms(date: dateString, refresh: refresh)
        .listen(
          (response) {
            if (mounted) {
              setState(() {
                _allPeriodsData = response;
                _isLoading = false;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _errorMessage = error.toString();
                _isLoading = false;
              });
            }
          },
        );
  }

  List<CalendarResource> _buildCalendarResources() {
    if (_allPeriodsData == null) return [];

    // Get all unique classrooms across all periods
    final Set<String> allClassrooms = {};
    for (int period = 1; period <= 10; period++) {
      if (_allPeriodsData!.hasData(period)) {
        allClassrooms.addAll(_allPeriodsData!.getClassroomsForPeriod(period));
      }
    }

    // Create resources for each classroom
    return allClassrooms.map((classroom) {
      return CalendarResource(
        displayName: classroom,
        id: classroom,
        color: _getClassroomColor(classroom),
      );
    }).toList();
  }

  Color _getClassroomColor(String classroom) {
    // Generate consistent colors for classrooms
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
    ];

    final hash = int.parse(classroom.replaceAll('(', '').substring(1, 2));
    return colors[hash.abs() % colors.length].withValues(alpha: 0.7);
  }

  List<ClassroomAppointment> _buildCalendarAppointments() {
    final List<ClassroomAppointment> appointments = [];

    if (_allPeriodsData == null) return appointments;

    for (int period = 1; period <= 10; period++) {
      if (!_allPeriodsData!.hasData(period)) continue;

      final classrooms = _allPeriodsData!.getClassroomsForPeriod(period);
      if (classrooms.isEmpty) continue;

      final periodInfo = PeriodConstants.periods.firstWhere(
        (p) => p.name == 'Period $period',
        orElse: () => const PeriodInfo(
          name: 'Period 1',
          startTime: '08:10',
          endTime: '08:50',
        ),
      );

      final startTime = _parseTime(periodInfo.startTime);
      final endTime = _parseTime(periodInfo.endTime);

      final appointmentDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        startTime.hour,
        startTime.minute,
      );

      final endDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        endTime.hour,
        endTime.minute,
      );

      for (final classroom in classrooms) {
        appointments.add(
          ClassroomAppointment(
            subject: 'Period $period',
            startTime: appointmentDate,
            endTime: endDate,
            resourceIds: [classroom],
            color: _getClassroomColor(classroom),
            classroom: classroom,
            period: period,
          ),
        );
      }
    }

    return appointments;
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    return DateTime(2024, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  Future<void> _onViewChanged(ViewChangedDetails details) async {
    final List<DateTime> visible = details.visibleDates;
    final DateTime newDate = visible.isNotEmpty
        ? visible[visible.length ~/ 2]
        : DateTime.now();

    // Check if the date has actually changed
    if (_selectedDate.year == newDate.year &&
        _selectedDate.month == newDate.month &&
        _selectedDate.day == newDate.day) {
      return; // No change needed
    }

    // Defer the state update until after the current build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      setState(() {
        _selectedDate = newDate;
      });

      await loadData(refresh: true);
    });
  }

  @override
  Widget buildPageContent(BuildContext context, ThemeNotifier themeNotifier) {
    return _buildCalendarBody(themeNotifier);
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    return _buildCalendarBody(themeNotifier);
  }

  Widget _buildCalendarBody(ThemeNotifier themeNotifier) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load free classrooms',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => loadData(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_allPeriodsData == null && !_isLoading) {
      return const Center(child: Text('No classroom data available'));
    }

    final resources = _buildCalendarResources();
    final appointments = _buildCalendarAppointments();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final calendarWidth = screenWidth > 800 ? screenWidth : 800.0;

        return Center(
          child: SizedBox(
            width: calendarWidth,
            child: Stack(
              children: [
                SfCalendarTheme(
                  data: themeData(context),
                  child: SfCalendar(
                    controller: _calendarController,
                    view: CalendarView.timelineDay,
                    dataSource: _ClassroomDataSource(appointments, resources),
                    showCurrentTimeIndicator: true,
                    allowViewNavigation: true,
                    showDatePickerButton: true,
                    viewNavigationMode: ViewNavigationMode.snap,
                    onViewChanged: _onViewChanged,
                    resourceViewSettings: ResourceViewSettings(
                      showAvatar: false,
                      displayNameTextStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      size: 42,
                    ),
                    timeSlotViewSettings: TimeSlotViewSettings(
                      timeIntervalHeight: 40,
                      timeIntervalWidth: -1,
                      minimumAppointmentDuration: const Duration(minutes: 30),
                      startHour: 8,
                      endHour: 17,
                    ),
                    appointmentBuilder:
                        (
                          BuildContext context,
                          CalendarAppointmentDetails details,
                        ) {
                          final ClassroomAppointment appointment =
                              details.appointments.first
                                  as ClassroomAppointment;
                          return Container(
                            decoration: BoxDecoration(
                              color: appointment.color,
                              borderRadius: themeNotifier.getBorderRadiusAll(
                                0.25,
                              ),
                            ),
                          );
                        },
                    onTap: (details) {
                      if (details.targetElement ==
                              CalendarElement.appointment &&
                          details.appointments != null &&
                          details.appointments!.isNotEmpty) {
                        final ClassroomAppointment tapped =
                            details.appointments!.first as ClassroomAppointment;
                        _showClassroomDetailDialog(tapped, themeNotifier);
                      }
                    },
                  ),
                ),
                if (_isLoading)
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showClassroomDetailDialog(
    ClassroomAppointment appointment,
    ThemeNotifier themeNotifier,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
        ),
        clipBehavior: Clip.antiAlias,
        title: Text('${appointment.classroom} - ${appointment.subject}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Classroom', appointment.classroom),
            _buildDetailRow('Period', 'Period ${appointment.period}'),
            _buildDetailRow(
              'Time',
              '${DateFormat('HH:mm').format(appointment.startTime)} - ${DateFormat('HH:mm').format(appointment.endTime)}',
            ),
            _buildDetailRow(
              'Date',
              DateFormat('MMM dd, yyyy').format(appointment.startTime),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
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
  String get emptyTitle => 'No free classrooms available';
}

class ClassroomAppointment {
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final List<Object> resourceIds;
  final Color color;
  final String classroom;
  final int period;

  ClassroomAppointment({
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.resourceIds,
    required this.color,
    required this.classroom,
    required this.period,
  });
}

class _ClassroomDataSource extends CalendarDataSource {
  _ClassroomDataSource(
    List<ClassroomAppointment> source,
    List<CalendarResource> resourceColl,
  ) {
    appointments = source;
    resources = resourceColl;
  }

  @override
  DateTime getStartTime(int index) =>
      appointments![index].startTime as DateTime;

  @override
  DateTime getEndTime(int index) => appointments![index].endTime as DateTime;

  @override
  String getSubject(int index) => appointments![index].subject as String;

  @override
  Color getColor(int index) => appointments![index].color as Color;

  @override
  List<Object> getResourceIds(int index) =>
      appointments![index].resourceIds as List<Object>;
}
