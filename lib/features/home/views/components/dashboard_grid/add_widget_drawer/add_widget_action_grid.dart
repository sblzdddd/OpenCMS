import 'package:flutter/material.dart';
import '../../quick_actions/action_item/quick_action_tile.dart';

class AddWidgetActionGrid extends StatelessWidget {
  final List<Map<String, dynamic>> actions;
  final Function(Map<String, dynamic>)? onAddAction;

  const AddWidgetActionGrid({
    super.key,
    required this.actions,
    this.onAddAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 16.0;
        const double minTileWidth = 100.0;
        final double availableWidth = constraints.maxWidth;
        final int columns =
            (((availableWidth + spacing) / (minTileWidth + spacing)).floor())
                .clamp(1, 6);
        final double tileWidth =
            (availableWidth - (columns - 1) * spacing) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              actions.map((action) {
                return QuickActionTile(
                  width: tileWidth,
                  icon: action['icon'] as IconData,
                  title: action['title'] as String,
                  onTap: () {
                    onAddAction?.call(action);
                  },
                );
              }).toList(),
        );
      },
    );
  }
}
