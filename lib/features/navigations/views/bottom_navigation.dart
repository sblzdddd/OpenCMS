import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'nav_items.dart';
import '../../theme/services/theme_services.dart';

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
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final bgColor = Theme.of(context).colorScheme.surface.withValues(
      alpha: themeNotifier.needTransparentBG
          ? themeNotifier.isDarkMode
                ? 0.6
                : 0
          : 1,
    );
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
