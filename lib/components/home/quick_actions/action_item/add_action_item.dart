import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'quick_action_tile.dart';

class AddActionItem extends StatelessWidget {
  final bool isHighlighted;
  final VoidCallback? onTap;

  const AddActionItem({
    Key? key,
    this.isHighlighted = false,
    this.onTap,
  }) : super(key: key ?? const ValueKey('add_action'));

  @override
  Widget build(BuildContext context) {
    Widget baseItem = QuickActionTile(
      width: 100,
      height: 108,
      icon: Symbols.add_rounded,
      title: 'Add',
      iconColor: Theme.of(context).colorScheme.primary,
      iconBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      titleStyle: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.primary,
      ),
      titleHeight: 20,
      onTap: onTap,
      borderColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      borderWidth: 2,
    );

    if (isHighlighted) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
        ),
        child: Transform.scale(
          scale: 1.05,
          child: baseItem,
        ),
      );
    }

    return baseItem;
  }
}
