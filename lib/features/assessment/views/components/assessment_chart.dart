import 'package:flutter/material.dart';
import 'package:opencms/features/assessment/models/assessment_models.dart';
import 'package:opencms/features/assessment/services/weighted_average_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:opencms/features/assessment/views/components/assessment_chart_empty_state.dart';
import 'package:opencms/features/assessment/views/components/assessment_chart_header.dart';
import 'package:opencms/features/assessment/views/components/assessment_chart_content.dart';

class AssessmentChart extends StatefulWidget {
  final List<Assessment> assessments;
  final String subjectName;
  final int subjectId;

  const AssessmentChart({
    super.key,
    required this.assessments,
    required this.subjectName,
    required this.subjectId,
  });

  @override
  State<AssessmentChart> createState() => _AssessmentChartState();
}

class _AssessmentChartState extends State<AssessmentChart> {
  bool _isColumnChart = false;
  late ZoomPanBehavior _zoomPanBehavior;
  final WeightedAverageService _weightedAverageService =
      WeightedAverageService();
  Map<String, int> _weights = {};
  bool _areWeightsLoaded = false;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enableSelectionZooming: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );
    _loadWeights();
    _weightedAverageService.addListener(_loadWeights);
  }

  @override
  void didUpdateWidget(AssessmentChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assessments != widget.assessments ||
        oldWidget.subjectId != widget.subjectId) {
      if (oldWidget.subjectId != widget.subjectId) {
        _areWeightsLoaded = false;
      }
      _loadWeights();
    }
  }

  @override
  void dispose() {
    _weightedAverageService.removeListener(_loadWeights);
    super.dispose();
  }

  Future<void> _loadWeights() async {
    final newWeights = <String, int>{};
    for (final assessment in widget.assessments) {
      if (assessment.percentageScore != null) {
        final weight = await _weightedAverageService.getWeight(
          widget.subjectId,
          assessment,
        );
        final key = '${assessment.date}_${assessment.title}';
        newWeights[key] = weight;
      }
    }
    if (mounted) {
      setState(() {
        _weights = newWeights;
        _areWeightsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final validAssessments = widget.assessments
        .where((assessment) => assessment.percentageScore != null)
        .toList();

    if (validAssessments.isEmpty) {
      return const AssessmentChartEmptyState();
    }

    // Sort assessments by date for chronological order
    validAssessments.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.date);
        final dateB = DateTime.parse(b.date);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AssessmentChartHeader(
          onZoomIn: _zoomPanBehavior.zoomIn,
          onZoomOut: _zoomPanBehavior.zoomOut,
          onZoomReset: _zoomPanBehavior.reset,
          onToggleChartType: () {
            setState(() {
              _isColumnChart = !_isColumnChart;
            });
          },
          isColumnChart: _isColumnChart,
        ),
        if (!_areWeightsLoaded)
          const SizedBox(height: 280)
        else
          AssessmentChartContent(
            assessments: validAssessments,
            zoomPanBehavior: _zoomPanBehavior,
            isColumnChart: _isColumnChart,
            weights: _weights,
          ),
      ],
    );
  }
}
