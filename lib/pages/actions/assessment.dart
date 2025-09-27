import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../data/constants/periods.dart';
import '../../data/models/assessment/assessment_response.dart';
import '../../services/assessment/assessment_service.dart';
import '../../ui/shared/views/refreshable_view.dart';
import '../../ui/shared/academic_year_dropdown.dart';
import '../../services/theme/theme_services.dart';
import '../../ui/assessments/subject_assessments_view.dart';
import '../../ui/assessments/adaptive_assessment_layout.dart';
import '../../ui/shared/widgets/custom_app_bar.dart';

class AssessmentPage extends StatefulWidget {
  final int initialTabIndex;
  const AssessmentPage({super.key, this.initialTabIndex = 0});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends RefreshableView<AssessmentPage> {
  late AcademicYear _selectedYear;
  final AssessmentService _assessmentService = AssessmentService();
  AssessmentResponse? _assessmentData;
  SubjectAssessment? _selectedSubject;
  
  @override
  void initState() {
    _selectedYear =
        PeriodConstants.getAcademicYears().first; // Default to current year
    super.initState();
  }

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final assessments = await _assessmentService.fetchAssessments(
      year: _selectedYear.year,
      refresh: refresh,
    );
    setState(() {
      _assessmentData = assessments;
    });
  }

  void _onYearChanged(AcademicYear? newYear) {
    if (newYear != null) {
      setState(() {
        _selectedYear = newYear;
        _selectedSubject = null; // Reset selected subject when year changes
      });
      loadData(refresh: true);
    }
  }

  void _onSubjectSelected(SubjectAssessment subject) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 800.0;
    
    if (isWideScreen) {
      setState(() {
        _selectedSubject = subject;
      });
    } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectAssessmentsView(
          subject: subject,
          academicYear: _selectedYear,
        ),
      ),
    );
    }
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    if (_assessmentData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return AdaptiveAssessmentLayout(
      subjects: _assessmentData!.subjects,
      selectedYear: _selectedYear,
      onYearChanged: _onYearChanged,
      onSubjectSelected: _onSubjectSelected,
      selectedSubject: _selectedSubject,
    );
  }

  @override
  Widget buildEmptyWidget(BuildContext context, ThemeNotifier themeNotifier) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.assessment_rounded,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No assessments available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Select a different academic year or check back later',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  String get errorTitle => 'Error loading assessments';

  @override
  bool get isEmpty => _assessmentData == null || _assessmentData!.subjects.isEmpty;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Assessment'),
        centerTitle: false,
        actions: [
          AcademicYearDropdown(
            selectedYear: _selectedYear,
            onChanged: _onYearChanged,
          ),
        ],
      ),
      body: super.build(context),
    );
  }
}
