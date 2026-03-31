import 'package:flutter/material.dart';

import 'nav_items.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTapCallback,
    this.items,
  });

  final int selectedIndex;
  final void Function(int) onTapCallback;
  final List<AppNavItem>? items;

  @override
  Widget build(BuildContext context) {
    final navItems = items ?? appNavItems;
    final bgColor = Theme.of(context).colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onTapCallback,
        backgroundColor: bgColor,
        // indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.icon, fill: 1),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
