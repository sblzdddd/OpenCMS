import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AssessmentChartHeader extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomReset;
  final VoidCallback onToggleChartType;
  final bool isColumnChart;

  const AssessmentChartHeader({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onZoomReset,
    required this.onToggleChartType,
    required this.isColumnChart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Performance Trend',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onZoomIn,
                icon: Icon(
                  Symbols.zoom_in_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Zoom In',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                iconSize: 20,
              ),
              IconButton(
                onPressed: onZoomOut,
                icon: Icon(
                  Symbols.zoom_out_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Zoom Out',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                iconSize: 20,
              ),
              IconButton(
                onPressed: onZoomReset,
                icon: Icon(
                  Symbols.crop_free_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Reset Zoom',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                iconSize: 20,
              ),
              IconButton(
                onPressed: onToggleChartType,
                icon: Icon(
                  isColumnChart
                      ? Symbols.show_chart_rounded
                      : Symbols.bar_chart_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: isColumnChart
                    ? 'Switch to Line Chart'
                    : 'Switch to Column Chart',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
