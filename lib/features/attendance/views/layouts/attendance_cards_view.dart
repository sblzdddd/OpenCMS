import 'package:flutter/material.dart';
import 'package:silky_scroll/silky_scroll.dart';
import '../../../shared/constants/period_constants.dart';
import '../../models/attendance_models.dart';
import '../../../shared/views/timetable_card.dart';
import '../../models/attendance_constants.dart';
import 'package:provider/provider.dart';
import '../../../theme/services/theme_services.dart';

class AttendanceCardsView extends StatelessWidget {
  final List<RecordOfDay> days;
  final Function(AttendanceEntry entry, DateTime date) onEventTap;
  final Set<int> selectedCourseIds;

  const AttendanceCardsView({
    super.key,
    required this.days,
    required this.onEventTap,
    required this.selectedCourseIds,
  });

  @override
  Widget build(BuildContext context) {
    // Build indices of days to display based on filter
    final List<int> visibleDayIndices = <int>[];
    if (selectedCourseIds.isEmpty) {
      for (int i = 0; i < days.length; i++) {
        visibleDayIndices.add(i);
      }
    } else {
      for (int i = 0; i < days.length; i++) {
        final day = days[i];
        final bool hasSelectedAbsence = day.attendances.any(
          (e) => e.kind != 0 && selectedCourseIds.contains(e.courseId),
        );
        if (hasSelectedAbsence) {
          visibleDayIndices.add(i);
        }
      }
    }

    return SilkyScroll(
      scrollSpeed: 2,
      builder: (context, controller, physics) => ListView.separated(
        physics: physics,
        controller: controller,
        itemCount: visibleDayIndices.length,
        padding: EdgeInsets.zero,
        cacheExtent: 800,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final day = days[visibleDayIndices[index]];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepaintBoundary(
                key: ValueKey(day.date.toIso8601String()),
                child: _buildDaySection(context, day, selectedCourseIds),
              ),
              const SizedBox(height: 16),
              const Divider(height: 32),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Widget _buildDaySection(
    BuildContext context,
    RecordOfDay day,
    Set<int> selectedCourseIds,
  ) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final periods = PeriodConstants.attendancePeriods;
    final atts = day.attendances;
    final int count = atts.length < periods.length
        ? atts.length
        : periods.length;

    final List<Widget> cards = [];
    int i = 0;
    while (i < count) {
      final startEntry = atts[i];
      if (startEntry.kind == 0 ||
          (selectedCourseIds.isNotEmpty &&
              !selectedCourseIds.contains(startEntry.courseId))) {
        i++;
        continue;
      }

      int endIndex = i;
      while (endIndex + 1 < count) {
        final nextEntry = atts[endIndex + 1];
        if (nextEntry.kind != 0 &&
            nextEntry.courseId == startEntry.courseId &&
            nextEntry.kind == startEntry.kind &&
            nextEntry.reason == startEntry.reason &&
            nextEntry.grade == startEntry.grade &&
            (selectedCourseIds.isEmpty ||
                selectedCourseIds.contains(nextEntry.courseId))) {
          endIndex++;
          continue;
        }
        break;
      }

      final startP = periods[i];
      final endP = periods[endIndex];
      final String timespan = '${startP.startTime} - ${endP.endTime}';
      final String periodText = startP.name == endP.name
          ? startP.name
          : '${startP.name} - ${endP.name}';

      cards.add(
        TimetableCard(
          subject: startEntry.getSubjectNameWithIndex(i),
          code: startEntry.reason,
          room: startEntry.kindText,
          extraInfo: startEntry.grade,
          timespan: timespan,
          periodText: periodText,
          backgroundColor:
              (AttendanceConstants.kindBackgroundColor[startEntry.kind] ??
                      Colors.transparent)
                  .withValues(
                    alpha: themeNotifier.needTransparentBG ? 0.5 : 0.7,
                  ),
          textColor: AttendanceConstants.kindTextColor[startEntry.kind],
          onTap: () {
            onEventTap(startEntry, day.date);
          },
        ),
      );
      cards.add(const SizedBox(height: 12));

      i = endIndex + 1;
    }

    if (cards.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatDate(day.date), style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('No attendance issues'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _formatDate(day.date),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text('${day.absentCount.toStringAsFixed(1)} day'),
          ],
        ),
        const SizedBox(height: 8),
        ...cards,
      ],
    );
  }
}
