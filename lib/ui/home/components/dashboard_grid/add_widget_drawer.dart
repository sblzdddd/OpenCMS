import 'package:flutter/material.dart';
import '../dynamic_gradient_banner.dart';
import 'widget_size_manager.dart';

/// Drawer for adding new widgets to the dashboard
class AddWidgetDrawer extends StatelessWidget {
  final List<String> addableWidgets;
  final Function(String, Size) onAddWidget;

  const AddWidgetDrawer({
    super.key,
    required this.addableWidgets,
    required this.onAddWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Add Widget',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Available widgets
          Expanded(
            child: addableWidgets.isEmpty
                ? Center(
                    child: Text(
                      'All available widgets are already added',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: addableWidgets.length,
                    itemBuilder: (context, index) {
                      final widgetId = addableWidgets[index];
                      return _buildAddWidgetOption(context, widgetId);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build an add widget option with size selection
  Widget _buildAddWidgetOption(BuildContext context, String widgetId) {
    final isBanner = widgetId == 'banner';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if(isBanner) ...[
              const Positioned.fill(
                child: DynamicGradientBanner(),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.1),
                ),
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
                      color: isBanner ? Colors.white : Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        WidgetSizeManager.getWidgetTitle(widgetId),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isBanner ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if(widgetId == 'banner') ...[
                      const Spacer(),
                      _buildSizeOption(
                        context,
                        widgetId,
                        const Size(4, 1.6),
                        'Add (4x1.6)',
                      ),
                    ]
                  ],
                ),
                if(widgetId != 'banner') ...[
                  const SizedBox(height: 16),
                  if(widgetId == 'notices') ...[
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
                ]
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
        Navigator.of(context).pop();
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
