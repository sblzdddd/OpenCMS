import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:opencms/features/assessment/models/assessment_models.dart';
import 'package:opencms/features/assessment/models/assessment_chart_data.dart';

class AssessmentChartContent extends StatelessWidget {
  final List<Assessment> assessments;
  final ZoomPanBehavior zoomPanBehavior;
  final bool isColumnChart;
  final Map<String, int> weights;

  const AssessmentChartContent({
    super.key,
    required this.assessments,
    required this.zoomPanBehavior,
    required this.isColumnChart,
    required this.weights,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: SfCartesianChart(
        zoomPanBehavior: zoomPanBehavior,
        axes: <ChartAxis>[
          NumericAxis(
            name: 'Weights',
            isVisible: false,
            minimum: 0,
            maximum: 100,
          ),
        ],
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(
            fontSize: 10,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: TextStyle(
            fontSize: 10,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          interval: 10,
          minimum: _calculateYAxisMinimum(assessments),
          maximum: 110,
          majorGridLines: MajorGridLines(
            width: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: '',
          format: 'point.x\npoint.y%',
          textStyle: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        series: _buildSeries(context, assessments),
        legend: Legend(
          isVisible: _hasClassAverage(assessments),
          position: LegendPosition.bottom,
          textStyle: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  List<CartesianSeries> _buildSeries(
    BuildContext context,
    List<Assessment> validAssessments,
  ) {
    final chartData = _prepareChartData(validAssessments);
    final classAverageData = _prepareClassAverageData(validAssessments);
    final hasClassAverage = _hasClassAverage(validAssessments);

    final weightSeries = ColumnSeries<AssessmentData, String>(
      name: 'Weight',
      yAxisName: 'Weights',
      dataSource: chartData,
      xValueMapper: (AssessmentData data, _) => data.label,
      yValueMapper: (AssessmentData data, _) => data.weight,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      width: 1.0,
      spacing: 0,
      animationDuration: 0,
    );

    if (isColumnChart) {
      return <CartesianSeries>[
        weightSeries,
        ColumnSeries<AssessmentData, String>(
          name: 'Your Score',
          dataSource: chartData,
          xValueMapper: (AssessmentData data, _) => data.label,
          yValueMapper: (AssessmentData data, _) => data.percentage,
          color: Theme.of(context).colorScheme.primary,
          width: 0.8,
          spacing: 0.2,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        if (hasClassAverage)
          ColumnSeries<AssessmentData, String>(
            name: 'Class Average',
            dataSource: classAverageData,
            xValueMapper: (AssessmentData data, _) => data.label,
            yValueMapper: (AssessmentData data, _) => data.percentage,
            color: Theme.of(context).colorScheme.secondary,
            width: 0.8,
            spacing: 0.2,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
      ];
    } else {
      return <CartesianSeries>[
        weightSeries,
        SplineSeries<AssessmentData, String>(
          name: 'Your Score',
          splineType: SplineType.cardinal,
          dataSource: chartData,
          xValueMapper: (AssessmentData data, _) => data.label,
          yValueMapper: (AssessmentData data, _) => data.percentage,
          markerSettings: MarkerSettings(
            isVisible: true,
            height: 8,
            width: 8,
            borderColor: Theme.of(context).colorScheme.primary,
            borderWidth: 2,
          ),
          color: Theme.of(context).colorScheme.primary,
          width: 3,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        if (hasClassAverage)
          SplineSeries<AssessmentData, String>(
            name: 'Class Average',
            splineType: SplineType.cardinal,
            dataSource: classAverageData,
            xValueMapper: (AssessmentData data, _) => data.label,
            yValueMapper: (AssessmentData data, _) => data.percentage,
            markerSettings: MarkerSettings(
              isVisible: true,
              height: 6,
              width: 6,
              borderColor: Theme.of(context).colorScheme.secondary,
              borderWidth: 2,
            ),
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
            dashArray: const [5, 5],
          ),
      ];
    }
  }

  List<AssessmentData> _prepareChartData(List<Assessment> assessments) {
    return assessments.asMap().entries.map((entry) {
      final index = entry.key;
      final assessment = entry.value;
      final key = '${assessment.date}_${assessment.title}';
      return AssessmentData(
        label: 'A${index + 1}',
        percentage: assessment.percentageScore!.toInt(),
        title: assessment.title,
        date: assessment.date,
        weight: weights[key] ?? 0,
      );
    }).toList();
  }

  List<AssessmentData> _prepareClassAverageData(List<Assessment> assessments) {
    return assessments.asMap().entries.map((entry) {
      final index = entry.key;
      final assessment = entry.value;
      return AssessmentData(
        label: 'A${index + 1}',
        percentage:
            ((assessment.numericAverage ?? 0) / assessment.numericOutOf! * 100)
                .toInt(),
        title: assessment.title,
        date: assessment.date,
      );
    }).toList();
  }

  bool _hasClassAverage(List<Assessment> assessments) {
    return assessments.any((assessment) => assessment.numericAverage != null);
  }

  double _calculateYAxisMinimum(List<Assessment> assessments) {
    // Get all percentage values from both user scores and class averages
    final List<double> allPercentages = [];

    // Add user percentage scores
    for (final assessment in assessments) {
      if (assessment.percentageScore != null) {
        allPercentages.add(assessment.percentageScore!.toDouble());
      }
    }

    // Add class average percentages if available
    for (final assessment in assessments) {
      if (assessment.numericAverage != null &&
          assessment.numericOutOf != null) {
        final classAveragePercentage =
            (assessment.numericAverage! / assessment.numericOutOf! * 100);
        allPercentages.add(classAveragePercentage);
      }
    }

    if (allPercentages.isEmpty) return 0;

    // Find the minimum value
    final minValue = allPercentages.reduce((a, b) => a < b ? a : b);

    // Set minimum to be 10 points below the lowest value, but not less than 0
    // This provides some visual breathing room at the bottom
    final calculatedMinimum = (minValue - 5).clamp(0.0, 100.0);

    // Round down to nearest 10 for cleaner axis labels
    return (calculatedMinimum / 10).floor() * 10.0;
  }
}
