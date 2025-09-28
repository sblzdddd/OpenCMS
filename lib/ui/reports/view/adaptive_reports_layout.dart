import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/reports/reports.dart';
import '../../../services/theme/theme_services.dart';
import '../../shared/scaled_ink_well.dart';
import '../../shared/views/adaptive_list_detail_layout.dart';
import 'report_detail_content.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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
      itemBuilder: (exam, isSelected) => _buildReportItem(exam, isSelected, context),
      detailBuilder: (exam) => ReportDetailContent(
        key: ValueKey(exam.id),
        exam: exam,
        isWideScreen: true,
      ),
      emptyState: _buildEmptyState(context),
    );
  }

  Widget _buildReportItem(Exam exam, bool isSelected, BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    
    return Material(
        color: Colors.transparent,
        child: ScaledInkWell(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          background: (inkWell) => Material(
            color: themeNotifier.needTransparentBG ? (!themeNotifier.isDarkMode
                ? Theme.of(context).colorScheme.surfaceBright.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.8))
            : Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: themeNotifier.getBorderRadiusAll(1),
            child: inkWell,
          ),
          onTap: () => onExamSelected(exam),
          borderRadius: themeNotifier.getBorderRadiusAll(1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: themeNotifier.getBorderRadiusAll(1),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5) : Theme.of(context).colorScheme.outline.withValues(alpha: 0),
                width: 1,
              ),
            ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: themeNotifier.getBorderRadiusAll(999),
                      ),
                      child: Text(
                        exam.month,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
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
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Symbols.description_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No reports available',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for updates',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
