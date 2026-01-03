import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../shared/constants/period_constants.dart';
import '../../models/assessment_models.dart';
import '../../services/assessment_service.dart';
import 'dart:async';
import '../../../home/views/widgets/base_dashboard_widget.dart';

final logger = Logger('LatestAssessmentWidget');

class LatestAssessmentWidget extends StatefulWidget {
  final VoidCallback? onRefresh;
  final int? refreshTick;

  const LatestAssessmentWidget({super.key, this.onRefresh, this.refreshTick});

  @override
  State<LatestAssessmentWidget> createState() => _LatestAssessmentWidgetState();
}

class _LatestAssessmentWidgetState extends State<LatestAssessmentWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  AssessmentResponse? _assessmentData;
  final AssessmentService _assessmentService = AssessmentService();
  bool _isLoading = true;
  bool _hasError = false;

  Future<void> _fetchWidgetData({bool refresh = false}) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      }

      final assessments = await _assessmentService.fetchAssessments(
        year: PeriodConstants.getAcademicYears().first.year,
        refresh: refresh,
      );

      if (mounted) {
        setState(() {
          _assessmentData = assessments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      logger.severe('LatestAssessmentWidget: Error fetching assessments: $e');
    }
  }

  Assessment? _getLatestAssessment() {
    if (_assessmentData == null) {
      return null;
    }

    // Get all assessments from all subjects
    final allAssessments = <Assessment>[];
    for (final subject in _assessmentData!.subjects) {
      allAssessments.addAll(subject.assessments);
    }

    if (allAssessments.isEmpty) {
      return null;
    }

    // Sort by date (latest first) and take the most recent
    final sortedAssessments = List<Assessment>.from(allAssessments)
      ..sort((a, b) {
        try {
          final dateA = DateFormat('yyyy-MM-dd').parse(a.date);
          final dateB = DateFormat('yyyy-MM-dd').parse(b.date);
          return dateB.compareTo(dateA); // Latest first
        } catch (e) {
          return 0;
        }
      });

    return sortedAssessments.first;
  }

  String _getScoreText(Assessment assessment) {
    if (assessment.mark.isNotEmpty && assessment.outOf.isNotEmpty) {
      return '${assessment.mark}/${assessment.outOf}';
    }
    return 'No score';
  }

  String _getSubjectCode(Assessment assessment) {
    for (final subject in _assessmentData!.subjects) {
      if (subject.assessments.contains(assessment)) {
        return subject.name;
      }
    }
    return 'Unknown Subject';
  }

  String _getWidgetSubtitle() {
    final latestAssessment = _getLatestAssessment();
    if (latestAssessment == null) return '';
    return latestAssessment.title;
  }

  String? _getBottomRightText() {
    final latestAssessment = _getLatestAssessment();
    if (latestAssessment == null) return null;
    return _getScoreText(latestAssessment);
  }

  String? _getBottomText() {
    final latestAssessment = _getLatestAssessment();
    if (latestAssessment == null) return null;
    return _getSubjectCode(latestAssessment);
  }

  bool _hasWidgetData() => _getLatestAssessment() != null;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseDashboardWidget(
      title: 'Assessment',
      subtitle: _getWidgetSubtitle(),
      icon: Symbols.assessment_rounded,
      actionId: 'assessment',
      isLoading: _isLoading,
      hasError: _hasError,
      hasData: _hasWidgetData(),
      loadingText: 'Loading assessments...',
      errorText: 'Failed to load assessments',
      noDataText: 'No recent assessments',
      bottomText: _getBottomText(),
      bottomRightText: _getBottomRightText(),
      onFetch: _fetchWidgetData,
      refreshTick: widget.refreshTick,
    );
  }
}
