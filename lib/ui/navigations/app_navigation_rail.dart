import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../../services/theme/theme_services.dart';
import 'nav_items.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AppNavigationRail extends StatefulWidget {
  const AppNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onTapCallback,
    this.appIcon,
  });

  final int selectedIndex;
  final void Function(int) onTapCallback;
  final Widget? appIcon;

  @override
  State<AppNavigationRail> createState() => _AppNavigationRailState();
}

class _AppNavigationRailState extends State<AppNavigationRail> {

  int lastClickMilliseconds = DateTime.now().millisecondsSinceEpoch;

  void onDoubleTap() {
    _handleDoubleTap();
  }

  void _handleDoubleTap() async {
    try {
      bool isMaximized = await windowManager.isMaximized();
      if (!isMaximized) {
        await windowManager.maximize();
      } else {
        await windowManager.unmaximize();
      }
    } catch (e) {
      // Handle any errors silently to avoid blocking the UI
      debugPrint('Error handling double tap: $e');
    }
  }

  void onSingleTap() {}

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier.instance;
    final bgColor = Theme.of(context).colorScheme.surface.withValues(
      alpha: themeNotifier.needTransparentBG ? 
      themeNotifier.isDarkMode ? 0.6 : 0
      : 1,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (details) {
            windowManager.startDragging();
          },
          onTapDown: (_) {
            int currMills = DateTime.now().millisecondsSinceEpoch;
            if ((currMills - lastClickMilliseconds) < 600) {
              onDoubleTap();
            } else {
              lastClickMilliseconds = currMills;
              onSingleTap();
            }
          },
          child: NavigationRail(
            leading: Container(
              height: 56,
              alignment: Alignment.center,
              child: Icon(Symbols.school_rounded, fill: 1, size: 32),
            ),
            selectedIndex: widget.selectedIndex,
            onDestinationSelected: widget.onTapCallback,
            extended: false,
            labelType: NavigationRailLabelType.selected,
            backgroundColor: bgColor,
            destinations: appNavItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon, fill: 1),
                    label: Text(item.label, style: TextStyle(fontSize: 9),),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
