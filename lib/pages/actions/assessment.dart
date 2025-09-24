import 'package:flutter/material.dart';
import '../../data/constants/periods.dart';
import '../../data/models/assessment/assessment_response.dart';
import '../../services/assessment/assessment_service.dart';
import '../../ui/shared/academic_year_dropdown.dart';
import '../../ui/shared/views/refreshable_view.dart';
import '../../services/theme/theme_services.dart';
import '../../ui/assessments/subject_assessments_view.dart';

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

  Widget _buildSubjectItem(SubjectAssessment subject) {
    // Calculate performance statistics
    final validAssessments = subject.assessments.where((a) => a.percentageScore != null).toList();
    final averageScore = validAssessments.isNotEmpty
        ? validAssessments.map((a) => a.percentageScore!).reduce((a, b) => a + b) / validAssessments.length
        : 0.0;
    
    final testCount = subject.assessments.where((a) => a.isTestOrExam).length;
    final projectCount = subject.assessments.where((a) => a.isProject).length;
    final homeworkCount = subject.assessments.where((a) => a.isHomework).length;
    final practicalCount = subject.assessments.where((a) => a.isPractical).length;
    final formativeCount = subject.assessments.where((a) => a.isFormative).length;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          subject.subject,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                if (testCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getAssessmentTypeColor('test').withValues(alpha: 0.2),
                      borderRadius: themeNotifier.getBorderRadiusAll(999),
                    ),
                    child: Text(
                      '$testCount Test${testCount > 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 12, color: _getAssessmentTypeColor('test')),
                    ),
                  ),
                if (testCount > 0) const SizedBox(width: 4),
                if (projectCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getAssessmentTypeColor('project').withValues(alpha: 0.2),
                      borderRadius: themeNotifier.getBorderRadiusAll(999),
                    ),
                    child: Text(
                      '$projectCount Project${projectCount > 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 12, color: _getAssessmentTypeColor('project')),
                    ),
                  ),
                if (projectCount > 0) const SizedBox(width: 4),
                if (homeworkCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getAssessmentTypeColor('homework').withValues(alpha: 0.2),
                      borderRadius: themeNotifier.getBorderRadiusAll(999),
                    ),
                    child: Text(
                      '$homeworkCount HW',
                      style: TextStyle(fontSize: 12, color: _getAssessmentTypeColor('homework')),
                    ),
                  ),
                if (homeworkCount > 0) const SizedBox(width: 4),
                if (practicalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getAssessmentTypeColor('practical').withValues(alpha: 0.2),
                      borderRadius: themeNotifier.getBorderRadiusAll(999),
                    ),
                    child: Text(
                      '$practicalCount Practical${practicalCount > 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 12, color: _getAssessmentTypeColor('practical')),
                    ),
                  ),
                if (practicalCount > 0) const SizedBox(width: 4),
                if (formativeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getAssessmentTypeColor('formative').withValues(alpha: 0.2),
                      borderRadius: themeNotifier.getBorderRadiusAll(999),
                    ),
                    child: Text(
                      '$formativeCount Formative${formativeCount > 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 12, color: _getAssessmentTypeColor('formative')),
                    ),
                  ),
              ],
            ),
            if (validAssessments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
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
        onTap: () => _navigateToSubjectAssessments(subject),
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

  Color _getAssessmentTypeColor(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('test') || lowerType.contains('exam')) return Colors.red;
    if (lowerType.contains('project')) return Colors.blue;
    if (lowerType.contains('homework')) return Colors.green;
    if (lowerType.contains('practical')) return Colors.orange;
    if (lowerType.contains('formative')) return Colors.purple;
    return Colors.grey;
  }
  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    if (_assessmentData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      itemCount: _assessmentData!.subjects.length,
      itemBuilder: (context, index) {
        return _buildSubjectItem(_assessmentData!.subjects[index]);
      },
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
