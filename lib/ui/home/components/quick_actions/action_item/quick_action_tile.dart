import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// A generic quick action tile used by various quick action components.
class QuickActionTile extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final TextStyle? titleStyle;
  final double titleHeight;
  final int titleMaxLines;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final bool showDragIndicator;

  const QuickActionTile({
    super.key,
    this.width = 100,
    this.height = 108,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.titleStyle,
    this.titleHeight = 30,
    this.titleMaxLines = 2,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
    this.showDragIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedIconBg = iconBackgroundColor ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    final Color resolvedIconColor = iconColor ?? Theme.of(context).colorScheme.primary;
    final TextStyle resolvedTitleStyle = titleStyle ?? const TextStyle(fontSize: 11, height: 1.2);

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: borderWidth > 0 && borderColor != null
                  ? Border.all(color: borderColor!, width: borderWidth, style: BorderStyle.solid)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: resolvedIconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          icon,
                          color: resolvedIconColor,
                          size: 28,
                        ),
                      ),
                      if (showDragIndicator)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(
                            Symbols.drag_indicator_rounded,
                            size: 12,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: titleHeight,
                  child: Text(
                    title,
                    style: resolvedTitleStyle,
                    textAlign: TextAlign.center,
                    maxLines: titleMaxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


