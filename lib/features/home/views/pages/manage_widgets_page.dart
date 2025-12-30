import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../components/dashboard_grid/add_widget_drawer.dart';
import '../components/dashboard_grid/dashboard_grid.dart';
import '../components/quick_actions/quick_actions.dart';
import 'package:opencms/features/shared/views/widgets/custom_app_bar.dart';
import 'package:opencms/features/shared/views/widgets/custom_scaffold.dart';

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

  void _showAddWidgetDrawer() {
    final addableWidgets = _dashboardController.getAddableWidgets();
    final addableActions = _quickActionsController.getAddableActions(); // Note: QuickActionsController might need this method exposed or added if it wasn't already.
    // Based on previous file read, QuickActionsController DOES have getAddableActions.

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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isHomePage: false, // It's a sub-page
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
                      isReadOnly: false, // Editable here
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    QuickActions(
                      controller: _quickActionsController,
                      isReadOnly: false, // Editable here
                    ),
                     const SizedBox(height: 40), // Bottom padding
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
