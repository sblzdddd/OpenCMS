import 'package:flutter/material.dart';
import '../../../data/constants/period_constants.dart';
import '../../../data/models/timetable/exam_timetable_entry.dart';
import '../../../services/timetable/exam_timetable_service.dart';
import '../../../ui/shared/error_placeholder.dart';
import '../../../ui/shared/timetable_card.dart';

class ExamTimetablePage extends StatefulWidget {
  final AcademicYear selectedYear;

  const ExamTimetablePage({
    super.key,
    required this.selectedYear,
  });

  @override
  State<ExamTimetablePage> createState() => _ExamTimetablePageState();
}

class _ExamTimetablePageState extends State<ExamTimetablePage> {
  final ExamTimetableService _examService = ExamTimetableService();

  int _selectedMonth = DateTime.now().month; // 1-12
  bool _isLoading = true;
  String? _errorMessage;
  List<ExamTimetableEntry> _exams = const [];

  @override
  void initState() {
    super.initState();
    _loadExamTimetable();
  }

  @override
  void didUpdateWidget(covariant ExamTimetablePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear.year != widget.selectedYear.year) {
      _loadExamTimetable();
    }
  }

  Future<void> _loadExamTimetable() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _exams = const [];
    });

    try {
      final parsed = await _examService.fetchExamTimetable(
        year: widget.selectedYear.year,
        month: _selectedMonth,
      );

      if (!mounted) return;
      setState(() {
        _exams = parsed;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onMonthChanged(int? newMonth) {
    if (newMonth == null) return;
    setState(() {
      _selectedMonth = newMonth;
    });
    _loadExamTimetable();
  }
  @override
  Widget build(BuildContext context) {
    final months = List<int>.generate(12, (i) => i + 1);
    return Column(
      children: [
        // Top bar with month dropdown aligned right
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 12, left: 12, bottom: 4),
          child: Row(
            children: [
              Text(
                'Month: ',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              DropdownButton<int>(
                value: _selectedMonth,
                onChanged: _onMonthChanged,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.only(left: 12, right: 6, top: 0, bottom: 0),
                underline: Container(),
                items: months
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text('${PeriodConstants.monthNames[m - 1]} ($m)'),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return ErrorPlaceholder(title: 'Failed to load timetable', errorMessage: _errorMessage!, onRetry: _loadExamTimetable);
    }

    if (_exams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            const Text('No exams scheduled for this month'),
          ],
        ),
      );
    }

    // Group by date
    final Map<String, List<ExamTimetableEntry>> byDate = {};
    for (final e in _exams) {
      byDate.putIfAbsent(e.date, () => []).add(e);
    }
    final sortedDates = byDate.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final items = byDate[date]!..sort((a, b) => a.startTime.compareTo(b.startTime));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                date,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final exam in items) 
              TimetableCard(
                subject: exam.subject.isNotEmpty ? exam.subject : (exam.code.isNotEmpty ? exam.code : 'Exam'),
                code: exam.code.isNotEmpty ? exam.code : '',
                room: exam.room.isNotEmpty ? exam.room : 'TBA',
                extraInfo: 'Seat: ${exam.seat.isNotEmpty ? exam.seat : 'TBA'}',
                timespan: '${exam.startTime} - ${exam.endTime}',
                periodText: '',
              ),
            const SizedBox(height: 8),
            if (index != sortedDates.length - 1) const Divider(height: 20),
          ],
        );
      },
    );
  }
}
