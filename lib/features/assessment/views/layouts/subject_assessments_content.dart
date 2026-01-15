import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silky_scroll/silky_scroll.dart';
import '../../../shared/constants/period_constants.dart';
import '../../models/assessment_models.dart';
import '../../services/assessment_service.dart';
import '../../services/weighted_average_service.dart';
import '../../../theme/services/theme_services.dart';

import '../components/subject_assessment_header.dart';
import '../components/assessment_summary.dart';
import '../components/assessment_list_item.dart';

class SubjectAssessmentsContent extends StatefulWidget {
  final SubjectAssessment subject;
  final AcademicYear academicYear;
  final bool isWideScreen;
  final VoidCallback? onRefresh;

  const SubjectAssessmentsContent({
    super.key,
    required this.subject,
    required this.academicYear,
    this.isWideScreen = false,
    this.onRefresh,
  });

  @override
  State<SubjectAssessmentsContent> createState() =>
      _SubjectAssessmentsContentState();
}

class _SubjectAssessmentsContentState extends State<SubjectAssessmentsContent> {
  late SubjectAssessment _currentSubject;
  bool _isLoading = false;
  bool _showWeights = false;

  @override
  void initState() {
    super.initState();
    _currentSubject = widget.subject;
  }

  @override
  void didUpdateWidget(SubjectAssessmentsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subject.id != widget.subject.id) {
      _currentSubject = widget.subject;
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final assessments = await AssessmentService().getAssessmentsBySubject(
        year: widget.academicYear.year,
        subjectName: _currentSubject.subject,
        refresh: true,
      );

      setState(() {
        _currentSubject = SubjectAssessment(
          id: _currentSubject.id,
          name: _currentSubject.name,
          subject: _currentSubject.subject,
          assessments: assessments,
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showResetConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Weights'),
        content: const Text(
          'Are you sure you want to reset all custom weights for this subject? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await WeightedAverageService().resetSubjectWeights(_currentSubject);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    // Use reversed list for assessments to show newest first
    final reversedAssessments = _currentSubject.assessments.reversed.toList();
    
    final totalCount = 3 + reversedAssessments.length + 1;

    final content = SilkyScroll(
        scrollSpeed: 2,
        builder: (context, controller, physics) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            controller: controller,
            physics: physics,
            // Small cache extent to trigger build closer to viewport
            cacheExtent: 100,
            itemCount: totalCount,
            itemBuilder: (context, index) {
              // 0: Header
              if (index == 0) {
                return SubjectAssessmentHeader(
                  subject: _currentSubject,
                  academicYear: widget.academicYear,
                  themeNotifier: themeNotifier,
                );
              }

              // 1: Summary
              if (index == 1) {
                return AssessmentSummary(
                  subject: _currentSubject,
                  themeNotifier: themeNotifier,
                );
              }

              // 2: Controls Row
              if (index == 2) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 4.0),
                  child: Row(
                    children: [
                      Text(
                        "Assessments",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      if (_showWeights) ...[
                        TextButton.icon(
                          onPressed: _showResetConfirmationDialog,
                          icon: const Icon(Icons.restore_rounded, size: 18),
                          label: const Text("Reset"),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      FilterChip(
                        label: Text('Edit weights'),
                        selected: _showWeights,
                        onSelected: (val) {
                          setState(() {
                            _showWeights = val;
                          });
                        },
                      ),
                    ],
                  ),
                );
              }

              // N+1: Bottom Spacer
              if (index == totalCount - 1) {
                return const SizedBox(height: 32);
              }

              // Assessments
              final assessmentIndex = index - 3;
              if (assessmentIndex >= 0 && assessmentIndex < reversedAssessments.length) {
                return AssessmentListItem(
                  assessment: reversedAssessments[assessmentIndex],
                  themeNotifier: themeNotifier,
                  subject: _currentSubject,
                  showWeights: _showWeights,
                );
              }
              
              return const SizedBox.shrink();
            },
          );
        });

    if (widget.isWideScreen) {
      return content;
    } else {
      return RefreshIndicator(onRefresh: _refreshData, child: content);
    }
  }
}
