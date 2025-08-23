import 'package:flutter/material.dart';
import '../ui/home/components/quick_actions/quick_actions.dart';
import '../ui/home/components/dashboard_grid/dashboard_grid.dart';
import '../ui/shared/navigations/bottom_navigation.dart';
import '../ui/shared/navigations/app_navigation_rail.dart';
import 'actions/timetable.dart';
import 'actions/homework.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useRail = constraints.maxWidth >= 800;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
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
                      Expanded(child: _buildPageContent()),
                    ],
                  )
                : _buildPageContent(),
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
      case 1: return TimetablePage(initialTabIndex: 0,);
      case 2: return const HomeworkPage();
      case 3: return _buildPlaceholderPage('Assessments');
      case 4: return const SettingsPage();
      default: return _buildScrollableHomeContent();
    }
  }

  Widget _buildScrollableHomeContent() {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use single column layout on smaller screens
          if (constraints.maxWidth < 850) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardGrid(),
                  const SizedBox(height: 16),
                  const QuickActions(),
                ],
              ),
            );
          }

          // Use two-column layout on larger screens
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dashboard", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: DashboardGrid(), flex: 3),
                    const SizedBox(width: 24),
                    // Right column - Quick Actions expanded
                    const Expanded(child: QuickActions(), flex: 4),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Text(
        '$title coming soon!',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF718096),
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    _selectedIndexNotifier.value = index;
  }
}
