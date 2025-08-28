import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:intl/intl.dart';
import '../../../data/constants/period_constants.dart';
import '../../../data/models/assessment/assessment_response.dart';
import '../../../services/assessment/assessment_service.dart';
import '../../../pages/actions.dart';
import 'dart:async';

/// Widget that displays the latest assessment information
/// Shows the most recent assessment with score and subject
class LatestAssessmentWidget extends StatefulWidget {
  final VoidCallback? onRefresh;
  final int? refreshTick;
  
  const LatestAssessmentWidget({super.key, this.onRefresh, this.refreshTick});

  @override
  State<LatestAssessmentWidget> createState() => _LatestAssessmentWidgetState();
}

class _LatestAssessmentWidgetState extends State<LatestAssessmentWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  AssessmentResponse? _assessmentData;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _updateTimer;
  
  final AssessmentService _assessmentService = AssessmentService();

  @override
  void initState() {
    super.initState();
    print('LatestAssessmentWidget: initState called, refreshTick: ${widget.refreshTick}');
    _fetchAssessments();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant LatestAssessmentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTick != oldWidget.refreshTick) {
      print('LatestAssessmentWidget: refreshTick changed from ${oldWidget.refreshTick} to ${widget.refreshTick} -> refreshing with refresh=true');
      refresh();
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Update every hour to refresh assessment data
    _updateTimer = Timer.periodic(const Duration(hours: 1), (_) {
      if (mounted) {
        setState(() {
          // Refresh to update assessment data
        });
      }
    });
  }

  /// Refresh the widget data
  Future<void> refresh() async {
    print('LatestAssessmentWidget: Refreshing assessments');
    await _fetchAssessments(refresh: true);
    // Call the parent refresh callback if provided
    widget.onRefresh?.call();
  }

  Future<void> _fetchAssessments({bool refresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

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
      print('LatestAssessmentWidget: Error fetching assessments: $e');
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

  String _getSubjectName(Assessment assessment) {
    // Find the subject name for this assessment
    for (final subject in _assessmentData!.subjects) {
      if (subject.assessments.contains(assessment)) {
        return subject.subject;
      }
    }
    return 'Unknown Subject';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => buildActionPage({
                'id': 'assessments',
                'title': 'Assessments',
              }),
            ),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading assessments...',
            style: TextStyle(
              fontSize: 8,
            ),
          ),
        ],
      );
    }
    
    if (_hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.error_outline_rounded,
            fill: 1.0,
            color: Theme.of(context).colorScheme.error,
            size: 18,
          ),
          Text(
            'Failed to load assessments',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const Spacer(),
          Text(
            'Swipe down to refresh',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    final latestAssessment = _getLatestAssessment();
    
    if (latestAssessment == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.assessment_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
            fill: 1,
          ),
          Text(
            'Latest Assessment',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          Text(
            'No recent assessments',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12, 
              color: Theme.of(context).colorScheme.onSurface
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Symbols.assessment_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
              fill: 1,
            ),
            const Spacer(),
            Text(
              _getScoreText(latestAssessment),
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _getSubjectName(latestAssessment),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Spacer(),
        Text(
          latestAssessment.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}
