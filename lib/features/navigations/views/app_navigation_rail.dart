import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/theme/views/widgets/skin_icon_widget.dart';
import 'package:window_manager/window_manager.dart';

import 'nav_items.dart';

final logger = Logger('AppNavigationRail');

class AppNavigationRail extends StatefulWidget {
  const AppNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onTapCallback,
    this.appIcon,
    this.items,
  });

  final int selectedIndex;
  final void Function(int) onTapCallback;
  final Widget? appIcon;
  final List<AppNavItem>? items;

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
      logger.severe('Error handling double tap: $e');
    }
  }

  void onSingleTap() {}

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.surface.withValues(alpha: 0);
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
              child: SkinIcon(
                imageKey: 'global.app_icon',
                fallbackIcon: Symbols.school_rounded,
                fallbackIconColor: Theme.of(context).colorScheme.primary,
                fallbackIconBackgroundColor: Colors.transparent,
                size: 40,
                iconSize: 32,
                fill: 1,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            selectedIndex: widget.selectedIndex,
            onDestinationSelected: widget.onTapCallback,
            extended: false,
            labelType: NavigationRailLabelType.selected,
            // Center destinations vertically within the rail
            groupAlignment: 0.0,
            backgroundColor: bgColor,
            destinations: (widget.items ?? appNavItems)
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon, fill: 1),
                    label: Text(item.label, style: TextStyle(fontSize: 9)),
                  ),
                )
                .toList(),
            trailing: SizedBox(height: 75, width: 16),
          ),
        );
      },
    );
  }
}
