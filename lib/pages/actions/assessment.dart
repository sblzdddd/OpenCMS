import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../data/constants/periods.dart';
import '../../data/models/assessment/assessment_response.dart';
import '../../services/assessment/assessment_service.dart';
import '../../ui/shared/academic_year_dropdown.dart';
import '../../ui/shared/views/refreshable_view.dart';
import '../../services/theme/theme_services.dart';
import '../../ui/assessments/subject_assessments_view.dart';
import '../../ui/components/assessment_type_counts_widget.dart';
import '../../ui/shared/scaled_ink_well.dart';

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
      });
      loadData(refresh: true);
    }
  }

  void _navigateToSubjectAssessments(SubjectAssessment subject) {
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

  Widget _buildSubjectItem(SubjectAssessment subject, BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    // Calculate performance statistics
    final validAssessments = subject.assessments.where((a) => a.percentageScore != null).toList();
    final averageScore = validAssessments.isNotEmpty
        ? validAssessments.map((a) => a.percentageScore!).reduce((a, b) => a + b) / validAssessments.length
        : 0.0;
    
    return ScaledInkWell(
      onTap: () => _navigateToSubjectAssessments(subject), // Add this line
      margin: const EdgeInsets.only(bottom: 8.0),
      background: (inkWell) => Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: themeNotifier.getBorderRadiusAll(1.5),
        child: inkWell,
      ),
      borderRadius: themeNotifier.getBorderRadiusAll(1.5),
      child: ListTile(
        mouseCursor: SystemMouseCursors.click,
        title: Text(
          '${subject.name.split('.')[0]} ${subject.subject}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            AssessmentTypeCountsWidget(
              assessments: subject.assessments,
              themeNotifier: themeNotifier,
            ),
            if (validAssessments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Symbols.school_rounded, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    subject.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Symbols.avg_pace_rounded, size: 16),
                  const SizedBox(width: 2),
                  Text(
                    'Average: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '${averageScore.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getScoreColor(averageScore),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.yellow.shade700;
    return Colors.red;
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    if (_assessmentData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView.builder(
        itemCount: _assessmentData!.subjects.length,
        itemBuilder: (context, index) {
          return _buildSubjectItem(_assessmentData!.subjects[index], context);
        },
      ),
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
                Icons.assessment_outlined,
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
      appBar: AppBar(
        title: const Text('Assessment'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: AcademicYearDropdown(
              selectedYear: _selectedYear,
              onChanged: _onYearChanged,
            ),
          ),
        ],
      ),
      body: super.build(context),
    );
  }
}
