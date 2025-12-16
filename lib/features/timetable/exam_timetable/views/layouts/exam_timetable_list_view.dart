import 'package:flutter/material.dart';
import '../../models/exam_timetable_models.dart';
import '../../../../shared/views/timetable_card.dart';
import '../../../../shared/views/error/empty_placeholder.dart';

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
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          EmptyPlaceholder(
            title: 'No exams scheduled for this month',
            onRetry: () => onExamTap(exams[0]),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            for (final exam in items)
              Builder(
                builder: (cardContext) => Column(
                  children: [
                    TimetableCard(
                      subject: exam.paper.isNotEmpty
                          ? exam.paper
                          : (exam.code.isNotEmpty ? exam.code : 'Exam'),
                      code: exam.code.isNotEmpty && exam.code != "0"
                          ? exam.code
                          : exam.examName,
                      room: exam.room.isNotEmpty ? exam.room : 'TBA',
                      extraInfo:
                          'Seat: ${exam.seat.isNotEmpty ? exam.seat : 'TBA'}',
                      timespan: '${exam.startTime} - ${exam.endTime}',
                      periodText: '',
                      onTap: () => onExamTap(exam),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            if (index != sortedDates.length - 1) const Divider(height: 20),
          ],
        );
      },
    );
  }
}
