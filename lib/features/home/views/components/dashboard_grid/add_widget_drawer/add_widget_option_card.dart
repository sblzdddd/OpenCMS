import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../theme/services/theme_services.dart';
import '../../../widgets/dynamic_gradient_banner.dart';
import '../widget_size_manager.dart';

class AddWidgetOptionCard extends StatelessWidget {
  final String widgetId;
  final Function(String, Size) onAddWidget;

  const AddWidgetOptionCard({
    super.key,
    required this.widgetId,
    required this.onAddWidget,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final isBanner = widgetId == 'banner';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (isBanner) ...[
              const Positioned.fill(child: DynamicGradientBanner()),
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.1)),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        WidgetSizeManager.getWidgetIcon(widgetId),
                        color:
                            isBanner
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          WidgetSizeManager.getWidgetTitle(widgetId),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color:
                                    isBanner
                                        ? Colors.white
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      if (widgetId == 'banner') ...[
                        const Spacer(),
                        _buildSizeOption(
                          context,
                          widgetId,
                          const Size(4, 1.6),
                          'Add (4x1.6)',
                        ),
                      ],
                    ],
                  ),
                  if (widgetId != 'banner') ...[
                    const SizedBox(height: 16),
                    if (widgetId == 'notices' || widgetId == 'calendar') ...[
                      // Three size options for notices: 2x1, 4x1, 4x1.6
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildSizeOption(
                                  context,
                                  widgetId,
                                  const Size(2, 1),
                                  'Compact (2×1)',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSizeOption(
                                  context,
                                  widgetId,
                                  const Size(4, 1),
                                  'Wide (4×1)',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: _buildSizeOption(
                              context,
                              widgetId,
                              const Size(4, 1.6),
                              'Extra Wide (4×1.6)',
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Two size options for other widgets: 2x1, 4x1
                      Row(
                        children: [
                          Expanded(
                            child: _buildSizeOption(
                              context,
                              widgetId,
                              const Size(2, 1),
                              'Compact (2×1)',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSizeOption(
                              context,
                              widgetId,
                              const Size(4, 1),
                              'Wide (4×1)',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a size option button
  Widget _buildSizeOption(
    BuildContext context,
    String widgetId,
    Size size,
    String label,
  ) {
    return ElevatedButton(
      onPressed: () {
        onAddWidget(widgetId, size);
        // Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        padding: const EdgeInsets.all(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
