import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../../services/theme/theme_services.dart';
import '../dynamic_gradient_banner.dart';
import 'widget_size_manager.dart';
import '../quick_actions/action_item/quick_action_tile.dart';

/// Drawer for adding new widgets to the dashboard
class AddWidgetDrawer extends StatefulWidget {
  final List<String> addableWidgets;
  final Function(String, Size) onAddWidget;
  final List<Map<String, dynamic>>? addableActions;
  final Function(Map<String, dynamic>)? onAddAction;
  final VoidCallback? onReset;

  const AddWidgetDrawer({
    super.key,
    required this.addableWidgets,
    required this.onAddWidget,
    this.addableActions,
    this.onAddAction,
    this.onReset,
  });

  @override
  State<AddWidgetDrawer> createState() => _AddWidgetDrawerState();
}

class _AddWidgetDrawerState extends State<AddWidgetDrawer> {
  String searchQuery = '';

  List<String> get _filteredWidgets {
    if (searchQuery.isEmpty) return widget.addableWidgets;
    final q = searchQuery.toLowerCase();
    return widget.addableWidgets.where((id) {
      final title = WidgetSizeManager.getWidgetTitle(id).toLowerCase();
      return title.contains(q) || id.toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredActions {
    final actions = widget.addableActions ?? const [];
    if (searchQuery.isEmpty) return actions;
    final q = searchQuery.toLowerCase();
    return actions.where((action) {
      final title = (action['title'] as String?)?.toLowerCase() ?? '';
      final id = (action['id'] as String?)?.toLowerCase() ?? '';
      return title.contains(q) || id.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final addableWidgets = _filteredWidgets;
    final addableActions = _filteredActions;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: themeNotifier.getBorderRadiusTop(1.25),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: themeNotifier.getBorderRadiusAll(0.125),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Items',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Symbols.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search widgets and quick actions...',
                prefixIcon: const Icon(Symbols.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: themeNotifier.getBorderRadiusAll(0.75),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: themeNotifier.getBorderRadiusAll(0.75),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: themeNotifier.getBorderRadiusAll(0.75),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Available widgets and actions
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (addableWidgets.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Widgets',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  ...addableWidgets
                      .map(
                        (widgetId) => _buildAddWidgetOption(context, widgetId),
                      )
                      ,
                  const SizedBox(height: 8),
                ],
                if (addableActions.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const double spacing = 16.0;
                      const double minTileWidth = 100.0;
                      final double availableWidth = constraints.maxWidth;
                      final int columns =
                          (((availableWidth + spacing) /
                                      (minTileWidth + spacing))
                                  .floor())
                              .clamp(1, 6);
                      final double tileWidth =
                          (availableWidth - (columns - 1) * spacing) / columns;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: addableActions.map((action) {
                          return QuickActionTile(
                            width: tileWidth,
                            icon: action['icon'] as IconData,
                            title: action['title'] as String,
                            onTap: () {
                              widget.onAddAction?.call(action);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
                if (addableWidgets.isEmpty && addableActions.isEmpty)
                  _buildEmptyState(context),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onReset?.call();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Symbols.refresh_rounded),
                    label: const Text('Reset to Default'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.errorContainer,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final bool showActions = (_filteredActions).isNotEmpty;
    final bool showWidgets = _filteredWidgets.isNotEmpty;
    if (showActions || showWidgets) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (showWidgets) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Widgets',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ..._filteredWidgets
                .map((widgetId) => _buildAddWidgetOption(context, widgetId))
                ,
          ],
          if (showActions) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Quick Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 16.0;
                const double minTileWidth = 100.0;
                final double availableWidth = constraints.maxWidth;
                final int columns =
                    (((availableWidth + spacing) / (minTileWidth + spacing))
                            .floor())
                        .clamp(1, 6);
                final double tileWidth =
                    (availableWidth - (columns - 1) * spacing) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: _filteredActions.map((action) {
                    return QuickActionTile(
                      width: tileWidth,
                      icon: action['icon'] as IconData,
                      title: action['title'] as String,
                      onTap: () {
                        widget.onAddAction?.call(action);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ],
      );
    }
    return Center(
      child: Text(
        'No items available to add',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  /// Build an add widget option with size selection
  Widget _buildAddWidgetOption(BuildContext context, String widgetId) {
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
                        color: isBanner
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
                                color: isBanner
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
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
                    if (widgetId == 'notices') ...[
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
        widget.onAddWidget(widgetId, size);
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
