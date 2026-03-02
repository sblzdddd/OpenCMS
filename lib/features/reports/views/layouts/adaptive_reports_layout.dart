import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/reports/models/reports.dart';
import 'package:opencms/features/reports/views/components/report_detail_content.dart';
import 'package:opencms/features/shared/views/selectable_item_wrapper.dart';
import 'package:opencms/features/shared/views/views/adaptive_list_detail_layout.dart';
import 'package:opencms/features/theme/services/theme_services.dart';

class AdaptiveReportsLayout extends StatelessWidget {
  final List<Exam> exams;
  final Function(Exam) onExamSelected;
  final Exam? selectedExam;
  final double breakpoint;

  const AdaptiveReportsLayout({
    super.key,
    required this.exams,
    required this.onExamSelected,
    this.selectedExam,
    this.breakpoint = 800.0,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveListDetailLayout<Exam>(
      items: exams,
      selectedItem: selectedExam,
      onItemSelected: onExamSelected,
      breakpoint: breakpoint,
      itemBuilder: (exam, isSelected) =>
          _buildReportItem(exam, isSelected, context),
      detailBuilder: (exam) => ReportDetailContent(
        key: ValueKey(exam.id),
        exam: exam,
        isWideScreen: true,
      ),
    );
  }

  Widget _buildReportItem(Exam exam, bool isSelected, BuildContext context) {
    final themeNotifier = ThemeNotifier.instance;

    return SelectableItemWrapper(
      isSelected: isSelected,
      highlightSelection: false,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      onTap: () => onExamSelected(exam),
      child: ListTile(
        mouseCursor: SystemMouseCursors.click,
        title: Text(
          exam.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: themeNotifier.getBorderRadiusAll(999),
                  ),
                  child: Text(exam.month, style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: themeNotifier.getBorderRadiusAll(999),
                  ),
                  child: Text(
                    exam.examType,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Symbols.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}
