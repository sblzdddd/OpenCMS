import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/constants/period_constants.dart';
import '../../../data/models/timetable/exam_timetable_entry.dart';
import '../../../services/timetable/exam_timetable_service.dart';
import '../../shared/timetable_card.dart';
import '../../shared/views/refreshable_view.dart';

class ExamTimetableView extends StatefulWidget {
  final AcademicYear selectedYear;

  const ExamTimetableView({super.key, required this.selectedYear});

  @override
  State<ExamTimetableView> createState() => _ExamTimetableViewState();
}

class _ExamTimetableViewState extends RefreshableView<ExamTimetableView> {
  final ExamTimetableService _examService = ExamTimetableService();

  int _selectedMonth = DateTime.now().month; // 1-12
  List<ExamTimetableEntry> _exams = const [];

  @override
  void didUpdateWidget(covariant ExamTimetableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear.year != widget.selectedYear.year) {
      loadData(refresh: true);
    }
  }

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final parsed = await _examService.fetchExamTimetable(
      year: widget.selectedYear.year,
      month: _selectedMonth,
      refresh: refresh,
    );

    if (mounted) {
      setState(() {
        _exams = parsed;
      });
    }
  }

  @override
  Widget buildContent(BuildContext context) {
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
        final items = byDate[date]!
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                date,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final exam in items)
              TimetableCard(
                subject: exam.subject.isNotEmpty
                    ? exam.subject
                    : (exam.code.isNotEmpty ? exam.code : 'Exam'),
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

  @override
  Widget buildEmptyWidget(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.event_busy_rounded,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              const Text('No exams scheduled for this month'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  String get errorTitle => 'Failed to load timetable';

  @override
  bool get isEmpty => _exams.isEmpty;

  void _onMonthChanged(int? newMonth) {
    if (newMonth == null) return;
    setState(() {
      _selectedMonth = newMonth;
    });
    loadData(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final months = List<int>.generate(12, (i) => i + 1);
    return Column(
      children: [
        // Top bar with month dropdown aligned right
        Padding(
          padding: const EdgeInsets.only(
            top: 4,
            right: 12,
            left: 12,
            bottom: 4,
          ),
          child: Row(
            children: [
              Text('Month: ', style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(),
              DropdownButton<int>(
                value: _selectedMonth,
                onChanged: _onMonthChanged,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 6,
                  top: 0,
                  bottom: 0,
                ),
                underline: Container(),
                items: months
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          '${PeriodConstants.monthNames[m - 1]} ($m)',
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: super.build(context)),
      ],
    );
  }
}
