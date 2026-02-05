import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/shared/views/widgets/custom_app_bar.dart';
import 'package:opencms/features/shared/views/widgets/custom_scaffold.dart';

import '../../../navigations/controllers/bottom_actions_controller.dart';
import '../components/dashboard_grid/add_widget_drawer/add_widget_drawer.dart';
import '../components/dashboard_grid/dashboard_grid.dart';
import '../components/quick_actions/quick_actions.dart';

class ManageWidgetsPage extends StatefulWidget {
  const ManageWidgetsPage({super.key});

  @override
  State<ManageWidgetsPage> createState() => _ManageWidgetsPageState();
}

class _ManageWidgetsPageState extends State<ManageWidgetsPage> {
  final DashboardGridController _dashboardController =
      DashboardGridController();
  final QuickActionsController _quickActionsController =
      QuickActionsController();
  final BottomActionsController _bottomActionsController =
      BottomActionsController();

  void _showAddWidgetDrawer() {
    final addableWidgets = _dashboardController.getAddableWidgets();
    final addableActions = _quickActionsController.getAddableActions();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddWidgetDrawer(
        addableWidgets: addableWidgets,
        onAddWidget: (id, size) {
          _dashboardController.addWidget(id, size);
          Navigator.of(context).pop();
        },
        addableActions: addableActions,
        onAddAction: (action) {
          _quickActionsController.addAction(action);
          Navigator.of(context).pop();
        },
        onReset: () {
          _dashboardController.resetLayout();
          _quickActionsController.resetActions();
          _bottomActionsController.reset();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isHomePage: false,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: const Text('Manage Widgets'),
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Symbols.arrow_back_rounded),
              ),
              actions: [
                IconButton(
                  onPressed: _showAddWidgetDrawer,
                  icon: const Icon(Symbols.add_rounded),
                  tooltip: 'Add Widget',
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Widgets',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DashboardGrid(
                      controller: _dashboardController,
                      isReadOnly: false,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    QuickActions(
                      controller: _quickActionsController,
                      isReadOnly: false,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bottom Navigation',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ListenableBuilder(
                          listenable: _bottomActionsController,
                          builder: (context, _) {
                            final available =
                                _bottomActionsController.availableItems;
                            return PopupMenuButton<String>(
                              icon: const Icon(Symbols.add_circle_rounded),
                              tooltip: 'Add Navigation Item',
                              enabled:
                                  available.isNotEmpty &&
                                  !_bottomActionsController.isLoading,
                              onSelected: (id) {
                                final item = available.firstWhere(
                                  (e) => e.id == id,
                                );
                                _bottomActionsController.addItem(item);
                              },
                              itemBuilder: (context) {
                                return available
                                    .map(
                                      (item) => PopupMenuItem(
                                        value: item.id,
                                        child: Row(
                                          children: [
                                            Icon(item.icon),
                                            const SizedBox(width: 8),
                                            Text(item.label),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListenableBuilder(
                      listenable: _bottomActionsController,
                      builder: (context, _) {
                        if (_bottomActionsController.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final items = _bottomActionsController.currentItems;
                        return ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          onReorder: _bottomActionsController.reorder,
                          children: [
                            for (int i = 0; i < items.length; i++)
                              ListTile(
                                key: ValueKey(items[i].id),
                                leading: ReorderableDragStartListener(
                                  index: i,
                                  child: const Icon(
                                    Symbols.drag_handle_rounded,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Icon(items[i].icon),
                                    const SizedBox(width: 8),
                                    Text(items[i].label),
                                  ],
                                ),
                                trailing: items[i].id == 'home'
                                    ? null
                                    : IconButton(
                                        icon: const Icon(
                                          Symbols.remove_circle_outline_rounded,
                                        ),
                                        onPressed: () =>
                                            _bottomActionsController.removeItem(
                                              items[i],
                                            ),
                                      ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
