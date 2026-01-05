import 'package:flutter/material.dart';
import 'package:opencms/features/shared/constants/quick_actions.dart';
import '../../quick_actions/action_item/quick_action_tile.dart';

class AddWidgetActionGrid extends StatelessWidget {
  final List<QuickAction> actions;
  final Function(QuickAction)? onAddAction;

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
                  icon: action.icon,
                  title: action.title,
                  showExternalIcon: action.isWebLink ?? false,
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
