import 'package:flutter/material.dart';
import 'package:opencms/features/assessment/models/assessment_models.dart';
import 'package:opencms/features/assessment/views/layouts/subject_assessments_content.dart';
import 'package:opencms/features/shared/constants/period_constants.dart';
import 'package:opencms/features/shared/views/views/refreshable_page.dart';

class SubjectAssessmentsView extends StatefulWidget {
  final SubjectAssessment subject;
  final AcademicYear academicYear;

  const SubjectAssessmentsView({
    super.key,
    required this.subject,
    required this.academicYear,
  });

  @override
  State<SubjectAssessmentsView> createState() => _SubjectAssessmentsViewState();
}

class _SubjectAssessmentsViewState
    extends RefreshablePage<SubjectAssessmentsView> {
  @override
  String get skinKey => 'assessments';

  @override
  String get appBarTitle =>
      'Assessments - ${widget.subject.name.split('.')[0]} ${widget.subject.subject}';

  @override
  Future<void> fetchData({bool refresh = false}) async {
    // No need to fetch data here as it's handled by the content widget
  }

  @override
  Widget buildPageContent(BuildContext context, ThemeNotifier themeNotifier) {
    return SubjectAssessmentsContent(
      subject: widget.subject,
      academicYear: widget.academicYear,
      isWideScreen: false,
    );
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    return buildPageContent(context, themeNotifier);
  }

  @override
  bool get isEmpty => widget.subject.assessments.isEmpty;

  @override
  String get errorTitle => 'Error loading assessments';
}
