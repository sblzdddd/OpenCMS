import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/constants/periods.dart';
import '../../../data/models/assessment/assessment_response.dart';
import '../../../services/assessment/assessment_service.dart';
import 'dart:async';
import 'base_dashboard_widget.dart';

/// Widget that displays the latest assessment information
/// Shows the most recent assessment with score and subject
class LatestAssessmentWidget extends StatefulWidget {
  final VoidCallback? onRefresh;
  final int? refreshTick;

  const LatestAssessmentWidget({super.key, this.onRefresh, this.refreshTick});

  @override
  State<LatestAssessmentWidget> createState() => _LatestAssessmentWidgetState();
}

class _LatestAssessmentWidgetState extends State<LatestAssessmentWidget>
    with AutomaticKeepAliveClientMixin, BaseDashboardWidgetMixin {
  @override
  bool get wantKeepAlive => true;

  AssessmentResponse? _assessmentData;
  final AssessmentService _assessmentService = AssessmentService();

  @override
  void initState() {
    super.initState();
    initializeWidget();
    startTimer();
  }

  @override
  void didUpdateWidget(covariant LatestAssessmentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTick != oldWidget.refreshTick) {
      refresh();
    }
  }

  @override
  void dispose() {
    disposeMixin();
    super.dispose();
  }

  @override
  Future<void> initializeWidget() async {
    await _fetchAssessments();
  }

  @override
  void startTimer() {
    // Update every hour to refresh assessment data
    setCustomTimer(const Duration(hours: 1));
  }

  @override
  Future<void> refreshData() async {
    debugPrint('LatestAssessmentWidget: Refreshing assessments');
    await _fetchAssessments(refresh: true);
    // Call the parent refresh callback if provided
    widget.onRefresh?.call();
  }

  Future<void> _fetchAssessments({bool refresh = false}) async {
    try {
      setLoading(true);
      setError(false);

      final assessments = await _assessmentService.fetchAssessments(
        year: PeriodConstants.getAcademicYears().first.year,
        refresh: refresh,
      );

      if (mounted) {
        setState(() {
          _assessmentData = assessments;
        });
        setLoading(false);
      }
    } catch (e) {
      if (mounted) {
        setLoading(false);
        setError(true);
      }
      debugPrint('LatestAssessmentWidget: Error fetching assessments: $e');
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildCommonLayout();
  }

  @override
  IconData getWidgetIcon() => Symbols.assessment_rounded;

  @override
  String getWidgetTitle() => 'quickActions.assessment'.tr();

  @override
  String getWidgetSubtitle() {
    final latestAssessment = _getLatestAssessment();
    if (latestAssessment == null) return '';
    return latestAssessment.title;
  }

  @override
  String? getBottomRightText() {
    final latestAssessment = _getLatestAssessment();
    if (latestAssessment == null) return null;
    return _getScoreText(latestAssessment);
  }

  @override
  String? getBottomText() {
    final latestAssessment = _getLatestAssessment();
    if (latestAssessment == null) return null;
    return _getSubjectCode(latestAssessment);
  }

  @override
  String getLoadingText() => 'Loading assessments...';

  @override
  String getErrorText() => 'Failed to load assessments';

  @override
  String getNoDataText() => 'No recent assessments';

  @override
  bool hasWidgetData() => _getLatestAssessment() != null;

  @override
  String getActionId() => 'assessment';
}
