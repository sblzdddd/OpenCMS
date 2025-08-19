import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'quick_action_tile.dart';

class TrashCanItem extends StatelessWidget {
  final bool isHighlighted;
  final double? tileWidth;

  const TrashCanItem({
    Key? key,
    this.isHighlighted = false,
    this.tileWidth,
  }) : super(key: key ?? const ValueKey('trash_can'));

  @override
  Widget build(BuildContext context) {
    Widget baseItem = QuickActionTile(
      width: tileWidth ?? 120,
      // height: 108,
      icon: Symbols.delete_rounded,
      title: 'Remove',
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withValues(alpha: 0.1),
      titleStyle: const TextStyle(
        fontSize: 11,
        color: Colors.red,
      ),
      borderColor: Colors.red.withValues(alpha: 0.3),
      borderWidth: 2,
    );

    if (isHighlighted) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
              spreadRadius: 0,
              blurRadius: 1,
              offset: const Offset(0, 0),
            ),
          ],
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
