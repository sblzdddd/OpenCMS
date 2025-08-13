import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'api/api.dart';
import 'components/home/quick_actions/quick_actions.dart';
import 'components/home/latest_assessment.dart';
import 'components/home/notice_card.dart';
import 'components/home/homework_card.dart';
import 'components/common/bottom_navigation.dart';
import 'components/common/app_navigation_rail.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  bool get _enableSmoothScroll {
    if (kIsWeb) return true;
    final platform = defaultTargetPlatform;
    return platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux ||
        platform == TargetPlatform.macOS;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (!_enableSmoothScroll) return;
    if (event is PointerScrollEvent && _scrollController.hasClients) {
      final currentOffset = _scrollController.offset;
      // Use platform/web delta directly; positive dy should scroll down
      final double delta = event.scrollDelta.dy;
      // Tune this factor for desired smoothness/speed
      const double scrollFactor = 1.8;
      final targetOffset = (currentOffset + delta * scrollFactor)
          .clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    }
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
    super.dispose();
  }

  Widget _buildHeader() {
    final userInfo = _authService.userInfo;
    final username = userInfo?['en_name'] ?? userInfo?['username'] ?? 'Student';
    final now = DateTime.now();
    final formattedDate = _formatDate(now);

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
                  onPressed: _showLogoutDialog,
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
        const Expanded(
          child: NoticeCard(),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: HomeworkCard(),
        ),
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
            Expanded(
              child: const QuickActions(),
            ),
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
        return _buildPlaceholderPage('Timetable');
      case 2:
        return _buildPlaceholderPage('Homework');
      case 3:
        return _buildPlaceholderPage('Assessments');
      default:
        return _buildScrollableHomeContent();
    }
  }

  Widget _buildScrollableHomeContent() {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        interactive: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: _enableSmoothScroll ? const NeverScrollableScrollPhysics() : null,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildResponsiveContent(),
            ],
          ),
        ),
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
    setState(() {
      _selectedIndex = index;
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    
    return '$weekday, $month ${date.day}, ${date.year}';
  }


  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('No No No'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _authService.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes Yes Yes'),
            ),
          ],
        );
      },
    );
  }
}
