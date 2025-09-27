import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import '../../../../services/theme/theme_services.dart';
import '../../data/models/assessment/assessment_response.dart';

class AssessmentChartWidget extends StatelessWidget {
  final List<Assessment> assessments;
  final String subjectName;

  const AssessmentChartWidget({
    super.key,
    required this.assessments,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final validAssessments = assessments
        .where((assessment) => assessment.percentageScore != null)
        .toList();

    if (validAssessments.isEmpty) {
      return _buildNoDataWidget(context);
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

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(
                    text: 'Assessments',
                    textStyle: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(
                    text: 'Percentage (%)',
                    textStyle: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  interval: 20,
                  minimum: _calculateYAxisMinimum(validAssessments),
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
                series: <CartesianSeries>[
                  SplineSeries<AssessmentData, String>(
                    name: 'Your Score',
                    dataSource: _prepareChartData(validAssessments),
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
                  if (_hasClassAverage(validAssessments))
                    SplineSeries<AssessmentData, String>(
                      name: 'Class Average',
                      dataSource: _prepareClassAverageData(validAssessments),
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
                      dashArray: [5, 5],
                    ),
                ],
                legend: Legend(
                  isVisible: _hasClassAverage(validAssessments),
                  position: LegendPosition.bottom,
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Symbols.analytics_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Chart Data Available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Assessment data with percentage scores is needed to display the performance trend.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AssessmentData> _prepareChartData(List<Assessment> assessments) {
    return assessments.asMap().entries.map((entry) {
      final index = entry.key;
      final assessment = entry.value;
      return AssessmentData(
        label: 'A${index + 1}',
        percentage: assessment.percentageScore!.toInt(),
        title: assessment.title,
        date: assessment.date,
      );
    }).toList();
  }

  List<AssessmentData> _prepareClassAverageData(List<Assessment> assessments) {
    return assessments.asMap().entries.map((entry) {
      final index = entry.key;
      final assessment = entry.value;
      return AssessmentData(
        label: 'A${index + 1}',
        percentage: ((assessment.numericAverage ?? 0) / assessment.numericOutOf! * 100).toInt(),
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
      if (assessment.numericAverage != null && assessment.numericOutOf != null) {
        final classAveragePercentage = (assessment.numericAverage! / assessment.numericOutOf! * 100);
        allPercentages.add(classAveragePercentage);
      }
    }
    
    if (allPercentages.isEmpty) return 0;
    
    // Find the minimum value
    final minValue = allPercentages.reduce((a, b) => a < b ? a : b);
    
    // Set minimum to be 10 points below the lowest value, but not less than 0
    // This provides some visual breathing room at the bottom
    final calculatedMinimum = (minValue - 10).clamp(0.0, 100.0);
    
    // Round down to nearest 10 for cleaner axis labels
    return (calculatedMinimum / 10).floor() * 10.0;
  }
}

class AssessmentData {
  final String label;
  final int percentage;
  final String title;
  final String date;

  AssessmentData({
    required this.label,
    required this.percentage,
    required this.title,
    required this.date,
  });
}
