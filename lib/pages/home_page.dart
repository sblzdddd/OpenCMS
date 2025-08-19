import 'package:flutter/material.dart';
import '../services/services.dart';
import '../ui/home/components/quick_actions/quick_actions.dart';
import '../ui/home/components/latest_assessment_card.dart';
import '../ui/home/components/notice_card.dart';
import '../ui/home/components/homework_card.dart';
import '../ui/shared/navigations/bottom_navigation.dart';
import '../ui/shared/navigations/app_navigation_rail.dart';
// deprecated
// import '../ui/shared/navigations/app_navigation_controller.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'actions/timetable.dart';
import '../ui/shared/logout_dialog.dart';
import '../data/constants/period_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
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
    _scrollController.dispose();
    // Clear global navigation controller state BEFORE disposing the notifier to avoid
    // any pending callbacks using a disposed notifier
    // AppNavigationController.reset();
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    final userInfo = _authService.userInfo;
    final username = userInfo?['en_name'] ?? userInfo?['username'] ?? 'Student';
    final now = DateTime.now();
    final formattedDate = PeriodConstants.formatDate(now);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $username',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => showLogoutDialog(context),
                  icon: const Icon(
                    Symbols.logout_rounded,
                    color: Color(0xFF718096),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLatestAssessment() {
    return const LatestAssessment();
  }

  Widget _buildNoticesAndHomework() {
    return Row(
      children: [
        const Expanded(child: NoticeCard()),
        const SizedBox(width: 16),
        const Expanded(child: HomeworkCard()),
      ],
    );
  }

  Widget _buildResponsiveContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use single column layout on smaller screens
        if (constraints.maxWidth < 800) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNoticesAndHomework(),
              const SizedBox(height: 20),
              _buildLatestAssessment(),
              const SizedBox(height: 24),
              const QuickActions(),
            ],
          );
        }

        // Use two-column layout on larger screens
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Fixed width for headings and info
            SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLatestAssessment(),
                  const SizedBox(height: 20),
                  _buildNoticesAndHomework(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right column - Expanding for Quick Actions
            Expanded(child: const QuickActions()),
          ],
        );
      },
    );
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildScrollableHomeContent();
      case 1:
        return TimetablePage(
          initialTabIndex: 0
              // AppNavigationController.takePendingTimetableInnerTabIndex() ?? 0,
        );
      case 2:
        return _buildPlaceholderPage('Homework');
      case 3:
        return _buildPlaceholderPage('Assessments');
      default:
        return _buildScrollableHomeContent();
    }
  }

  Widget _buildScrollableHomeContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildResponsiveContent(),
        ],
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
