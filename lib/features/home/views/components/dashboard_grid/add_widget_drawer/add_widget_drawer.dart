import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

import '../../../../../theme/services/theme_services.dart';
import 'add_widget_action_grid.dart';
import 'add_widget_drawer_header.dart';
import 'add_widget_option_card.dart';
import 'add_widget_search_field.dart';
import '../widget_size_manager.dart';

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
          const AddWidgetDrawerHeader(),
          AddWidgetSearchField(
            onChanged: (value) => setState(() => searchQuery = value),
          ),
          const SizedBox(height: 12),
          // Available widgets and actions
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                  ...addableWidgets.map(
                    (widgetId) => AddWidgetOptionCard(
                      widgetId: widgetId,
                      onAddWidget: widget.onAddWidget,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (addableActions.isNotEmpty) ...[
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Quick Actions',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 12),
                          AddWidgetActionGrid(
                            actions: addableActions,
                            onAddAction: widget.onAddAction,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (addableWidgets.isEmpty && addableActions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No items available to add',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
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
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onErrorContainer,
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
}
