import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/theme/theme_services.dart';
import '../../../data/constants/periods.dart';
import '../../../data/models/attendance/attendance_response.dart';
import '../../../data/constants/attendance_types.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';

class AttendanceTableView extends StatelessWidget {
  final List<RecordOfDay> days;
  final Function(AttendanceEntry entry, DateTime date) onEventTap;

  const AttendanceTableView({
    super.key,
    required this.days,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final periods = PeriodConstants.attendancePeriods;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double minTableWidth = 1000;
        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : minTableWidth;
        final double tableWidth = availableWidth < minTableWidth
            ? minTableWidth
            : availableWidth;
        final int totalColumns = 1 + periods.length;
        final double columnWidth = tableWidth / totalColumns;

        return CustomChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: CustomChildScrollView(
              child: RepaintBoundary(
                child: DataTable(
              columnSpacing: 0,
              horizontalMargin: 0,
              headingRowHeight: 40,
              dataRowMinHeight: 60,
              dataRowMaxHeight: 90,
              columns: [
                DataColumn(
                  label: SizedBox(
                    width: columnWidth,
                    child: const Text('Date', textAlign: TextAlign.left),
                  ),
                ),
                ...periods.map((period) => DataColumn(
                  label: SizedBox(
                    width: columnWidth,
                    child: Text(
                      period.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )),
              ],
              rows: days
                  .map((day) => _buildDataRow(context, day, periods, columnWidth))
                  .toList(),
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  String _getDayOfWeek(DateTime date) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[date.weekday - 1];
  }

  DataRow _buildDataRow(BuildContext context, RecordOfDay day, List<PeriodInfo> periods, double columnWidth) {
    // Create a map of period index to attendance entry
    final Map<int, AttendanceEntry> attendanceMap = {};
    
    for (int i = 0; i < day.attendances.length && i < periods.length; i++) {
      final entry = day.attendances[i];
      attendanceMap[i] = entry; // Include all records, including present ones
    }

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: columnWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(day.date),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  textAlign: TextAlign.left,
                ),
                Text(
                  _getDayOfWeek(day.date),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
        ...List.generate(periods.length, (index) {
          final entry = attendanceMap[index];
          return DataCell(
            SizedBox(
              width: columnWidth,
              height: 80,
              child: entry != null ? _buildAttendanceCell(context, entry, day.date, index) : const SizedBox.shrink(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAttendanceCell(BuildContext context, AttendanceEntry entry, DateTime date, int index) {
    final subjectName = entry.getSubjectNameWithIndex(index);
    final backgroundColor = subjectName == "/" ? Colors.transparent : AttendanceConstants.kindBackgroundColor[entry.kind] ?? Colors.transparent;
    final textColor = subjectName == "/" ? Theme.of(context).colorScheme.onSurface : AttendanceConstants.kindTextColor[entry.kind] ?? Theme.of(context).colorScheme.onSurface;
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return GestureDetector(
      onTap: () => onEventTap(entry, date),
      child: Container(
        width: double.infinity,
        height: 75,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: themeNotifier.getBorderRadiusAll(0.375),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  subjectName == "/" ? "" : subjectName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ),
            if (entry.kind != 0) // Show kindText if not present
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    entry.kindText,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 7,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}