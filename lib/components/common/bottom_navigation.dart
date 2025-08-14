import 'package:flutter/material.dart';
import 'nav_items.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTapCallback,
  });

  final int selectedIndex;
  final void Function(int) onTapCallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        // indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: appNavItems
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