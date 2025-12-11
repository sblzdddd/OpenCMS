import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../ui/home/components/dashboard_grid/add_widget_drawer.dart';
import '../ui/home/components/quick_actions/quick_actions.dart';
import '../ui/home/components/dashboard_grid/dashboard_grid.dart';
import '../ui/navigations/bottom_navigation.dart';
import '../ui/navigations/app_navigation_rail.dart';
import 'actions/timetable.dart';
import 'actions/homework.dart';
import 'actions/assessment.dart';
import '../ui/shared/widgets/custom_app_bar.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';
import 'package:opencms/ui/shared/widgets/custom_scaffold.dart';
import 'package:opencms/services/theme/theme_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final DashboardGridController _dashboardController =
      DashboardGridController();
  final QuickActionsController _quickActionsController =
      QuickActionsController();

  int get _selectedIndex => _selectedIndexNotifier.value;

  @override
  void initState() {
    super.initState();
    // Initialize the navigation controller
    // AppNavigationController.initialize(_selectedIndexNotifier);
    // Listen to changes in selected index
    _selectedIndexNotifier.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final bgColor = themeNotifier.hasTransparentWindowEffect
        ? (!themeNotifier.isDarkMode
              ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0.8))
        : Colors.transparent;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useRail = constraints.maxWidth >= 800;
        return CustomScaffold(
          skinKey: [
            'home',
            'timetable',
            'homeworks',
            'assessment',
          ][_selectedIndex],
          isHomePage: true,
          body: SafeArea(
            child: useRail
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppNavigationRail(
                        selectedIndex: _selectedIndex,
                        onTapCallback: _onNavTap,
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: Container(
                          color: bgColor,
                          child: _buildPageContent(),
                        ),
                      ),
                    ],
                  )
                : Container(color: bgColor, child: _buildPageContent()),
          ),
          bottomNavigationBar: useRail
              ? null
              : BottomNavigation(
                  selectedIndex: _selectedIndex,
                  onTapCallback: _onNavTap,
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Clear global navigation controller state BEFORE disposing the notifier to avoid
    // any pending callbacks using a disposed notifier
    // AppNavigationController.reset();
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildScrollableHomeContent();
      case 1:
        return TimetablePage(initialTabIndex: 0, isTransparent: true);
      case 2:
        return const HomeworkPage(isTransparent: true);
      case 3:
        return const AssessmentPage(isTransparent: true);
      default:
        return _buildScrollableHomeContent();
    }
  }

  Widget _buildScrollableHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 850;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 10 : 5,
                vertical: 10,
              ),
              title: Text('Home'),
              actions: [
                IconButton(
                  onPressed: _showAddWidgetDrawer,
                  icon: Icon(Symbols.add_rounded),
                ),
              ],
              forceMaterialTransparency: true,
              surfaceTintColor: Colors.transparent,
            ),
            Expanded(
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refreshHomePage,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: CustomChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWideScreen ? 24 : 16,
                        vertical: 0,
                      ),
                      child: Column(
                        children: [
                          if (!isWideScreen) ...[
                            DashboardGrid(controller: _dashboardController),
                            const SizedBox(height: 16),
                            QuickActions(controller: _quickActionsController),
                          ] else ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: DashboardGrid(
                                    controller: _dashboardController,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 4,
                                  child: QuickActions(
                                    controller: _quickActionsController,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
        },
      ),
    );
  }

  /// Refresh all data on the home page
  Future<void> _refreshHomePage() async {
    // Trigger dashboard grid refresh via controller to avoid callback recursion
    _dashboardController.refresh();
    // Optional: small delay to keep the indicator visible
    await Future.delayed(const Duration(milliseconds: 400));
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    _selectedIndexNotifier.value = index;
  }
}
