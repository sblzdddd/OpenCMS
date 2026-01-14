import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silky_scroll/silky_scroll.dart';
import '../../../shared/constants/period_constants.dart';
import '../../models/assessment_models.dart';
import '../../services/assessment_service.dart';
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

  Widget _buildAssessmentsList(ThemeNotifier themeNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _currentSubject.assessments.length,
          itemBuilder: (context, index) {
            final assessment =
                _currentSubject.assessments.reversed.toList()[index];
            return AssessmentListItem(
              assessment: assessment,
              themeNotifier: themeNotifier,
              subject: _currentSubject,
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildAssessmentsContents(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final List<Widget> contents = [
      SubjectAssessmentHeader(
        subject: _currentSubject,
        academicYear: widget.academicYear,
        themeNotifier: themeNotifier,
      ),
      AssessmentSummary(
        subject: _currentSubject,
        themeNotifier: themeNotifier,
      ),
      _buildAssessmentsList(themeNotifier),
      const SizedBox(height: 32),
    ];

    return contents;
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildAssessmentsContents(context);
    final content = SilkyScroll(
        scrollSpeed: 2,
        builder: (context, controller, physics) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            controller: controller,
            physics: physics,
            itemCount: items.length,
            itemBuilder: (context, index) => items[index],
          );
        });
    if (widget.isWideScreen) {
      return content;
    } else {
      return RefreshIndicator(onRefresh: _refreshData, child: content);
    }
  }

}
