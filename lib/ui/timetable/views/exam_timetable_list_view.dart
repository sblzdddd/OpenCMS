import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/models/timetable/exam_timetable_entry.dart';
import '../../shared/timetable_card.dart';

class ExamTimetableListView extends StatelessWidget {
  final List<ExamTimetableEntry> exams;
  final Function(ExamTimetableEntry) onExamTap;

  const ExamTimetableListView({
    super.key,
    required this.exams,
    required this.onExamTap,
  });

  @override
  Widget build(BuildContext context) {
    // Group by date
    final Map<String, List<ExamTimetableEntry>> byDate = {};
    for (final e in exams) {
      byDate.putIfAbsent(e.date, () => []).add(e);
    }
    final sortedDates = byDate.keys.toList()..sort();

    if (exams.isEmpty) {
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
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                const Text('No exams scheduled for this month'),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Builder(
                builder: (cardContext) => TimetableCard(
                  subject: exam.subject.isNotEmpty
                      ? exam.subject
                      : (exam.code.isNotEmpty ? exam.code : 'Exam'),
                  code: exam.code.isNotEmpty ? exam.code : '',
                  room: exam.room.isNotEmpty ? exam.room : 'TBA',
                  extraInfo: 'Seat: ${exam.seat.isNotEmpty ? exam.seat : 'TBA'}',
                  timespan: '${exam.startTime} - ${exam.endTime}',
                  periodText: '',
                  onTap: () => onExamTap(exam),
                ),
              ),
            const SizedBox(height: 8),
            if (index != sortedDates.length - 1) const Divider(height: 20),
          ],
        );
      },
    );
  }
}
