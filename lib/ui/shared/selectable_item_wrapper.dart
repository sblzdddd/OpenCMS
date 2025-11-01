import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme/theme_services.dart';
import 'scaled_ink_well.dart';

class SelectableItemWrapper extends StatelessWidget {
  final bool isSelected;
  final Widget child; // Usually a ListTile
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;
  final bool highlightSelection;

  const SelectableItemWrapper({
    super.key,
    required this.isSelected,
    required this.child,
    required this.onTap,
    this.margin,
    this.highlightSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final borderRadius = themeNotifier.getBorderRadiusAll(1);

    Color backgroundColor;
    if (highlightSelection && isSelected) {
      backgroundColor = Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.3);
    } else if (themeNotifier.needTransparentBG && !themeNotifier.isDarkMode) {
      backgroundColor = Theme.of(
        context,
      ).colorScheme.surfaceBright.withValues(alpha: 0.5);
    } else if (themeNotifier.needTransparentBG && themeNotifier.isDarkMode) {
      backgroundColor = Theme.of(
        context,
      ).colorScheme.surfaceContainer.withValues(alpha: 0.8);
    } else {
      // Non-transparent base surface
      backgroundColor = Theme.of(context).colorScheme.surfaceContainer;
      if (!highlightSelection) {
        if (themeNotifier.isDarkMode) {
          backgroundColor = backgroundColor.withValues(alpha: 0.8);
        }
      }
    }

    return Material(
      color: Colors.transparent,
      child: ScaledInkWell(
        margin:
            margin ??
            const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        background: (inkWell) => Material(
          color: backgroundColor,
          borderRadius: borderRadius,
          child: inkWell,
        ),
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
