import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/app_router.dart';
import 'package:opencms/features/home/views/components/dashboard_grid/dashboard_grid.dart';
import 'package:opencms/features/home/views/components/quick_actions/quick_actions.dart';
import 'package:opencms/features/navigations/controllers/bottom_actions_controller.dart';
import 'package:opencms/features/navigations/views/app_navigation_rail.dart';
import 'package:opencms/features/navigations/views/bottom_navigation.dart';
import 'package:opencms/features/shared/views/widgets/custom_app_bar.dart';
import 'package:opencms/features/shared/views/widgets/custom_scaffold.dart';
import 'package:opencms/features/shared/views/widgets/custom_scroll_view.dart';
import 'package:opencms/features/theme/services/theme_services.dart';

import 'manage_widgets_page.dart';

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
  final BottomActionsController _bottomActionsController =
      BottomActionsController();
  late final PageController _pageController;
  int _layoutVersion = 0;

  int get _selectedIndex => _selectedIndexNotifier.value;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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
    final themeNotifier = ThemeNotifier.instance;
    final bgColor = !themeNotifier.isDarkMode
        ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
        : Theme.of(context).colorScheme.surface.withValues(alpha: 0.8);
    return ListenableBuilder(
      listenable: _bottomActionsController,
      builder: (context, _) {
        if (_bottomActionsController.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final items = _bottomActionsController.currentItems;
        final safeIndex = _selectedIndex < items.length ? _selectedIndex : 0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool useRail = constraints.maxWidth >= 800;
            return CustomScaffold(
              skinKey: safeIndex < items.length ? items[safeIndex].id : 'home',
              isHomePage: true,
              body: SafeArea(
                child: useRail
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppNavigationRail(
                            selectedIndex: safeIndex,
                            onTapCallback: _onNavTap,
                            items: items,
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
                      selectedIndex: safeIndex,
                      onTapCallback: _onNavTap,
                      items: items,
                    ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // Clear global navigation controller state BEFORE disposing the notifier to avoid
    // any pending callbacks using a disposed notifier
    // AppNavigationController.reset();
    _pageController.dispose();
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  Widget _buildPageContent() {
    final items = _bottomActionsController.currentItems;
    if (items.isEmpty) return _buildScrollableHomeContent();

    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      onPageChanged: (index) {
        _selectedIndexNotifier.value = index;
      },
      itemBuilder: (context, index) {
        final id = items[index].id;
        return (id == 'home')
            ? _buildScrollableHomeContent()
            : AppRouter.getWidget(id);
      },
    );
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
              actions: [
                IconButton(
                  onPressed: _onManageWidgets,
                  icon: Icon(Symbols.edit_rounded),
                  tooltip: 'Manage Widgets',
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
                            DashboardGrid(
                              key: ValueKey('grid_$_layoutVersion'),
                              controller: _dashboardController,
                              isReadOnly: true,
                            ),
                            const SizedBox(height: 16),
                            QuickActions(
                              key: ValueKey('actions_$_layoutVersion'),
                              controller: _quickActionsController,
                              isReadOnly: true,
                            ),
                          ] else ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: DashboardGrid(
                                    key: ValueKey('grid_w_$_layoutVersion'),
                                    controller: _dashboardController,
                                    isReadOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 4,
                                  child: QuickActions(
                                    key: ValueKey('actions_w_$_layoutVersion'),
                                    controller: _quickActionsController,
                                    isReadOnly: true,
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

  Future<void> _onManageWidgets() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ManageWidgetsPage()));

    // Refresh bottom actions
    await _bottomActionsController.refresh();

    if (mounted) {
      setState(() {
        _layoutVersion++;
      });
    }
  }

  /// Refresh all data on the home page
  Future<void> _refreshHomePage() async {
    // Trigger dashboard grid refresh via controller to avoid callback recursion
    _dashboardController.refresh();
    _bottomActionsController.refresh();
    // Optional: small delay to keep the indicator visible
    await Future.delayed(const Duration(milliseconds: 400));
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;

    _selectedIndexNotifier.value = index;
    _pageController.jumpToPage(index);
  }
}
