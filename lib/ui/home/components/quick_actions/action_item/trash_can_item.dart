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
    );

    if (isHighlighted) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: 0.6,
        child: baseItem,
      );
    }

    return baseItem;
  }
}
