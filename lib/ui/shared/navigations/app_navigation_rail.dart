import 'package:flutter/material.dart';
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
  bool forceExtended = false;

  void onToggleSidebar() {
    setState(() {
      forceExtended = !forceExtended;
    });
    print('Toggle clicked, forceExtended: $forceExtended');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool extended = constraints.maxWidth >= 1100;
        // For wide screens: default to extended but allow toggle to collapse
        // For narrow screens: default to collapsed but allow toggle to extend
        final bool isExtended = extended ? !forceExtended : forceExtended;
        return NavigationRail(
          leading: Container(
            height: 56,
            alignment: Alignment.centerLeft,
            width: isExtended ? 225 : 72,
            child: isExtended
                ? Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: onToggleSidebar,
                        icon: const Icon(Symbols.menu_rounded),
                        tooltip: 'Toggle sidebar',
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'OpenCMS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  )
                :
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: onToggleSidebar,
                        icon: const Icon(Symbols.menu_rounded),
                        tooltip: 'Toggle sidebar',
                      )
                    ],
                  ),
          ),
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: widget.onTapCallback,
          extended: isExtended,
          minExtendedWidth: 225,
          labelType: isExtended ? null : NavigationRailLabelType.selected,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          destinations: appNavItems
              .map(
                (item) => NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.icon, fill: 1),
                  label: Text(item.label, style: TextStyle(fontSize: isExtended ? 12 : 9),),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
