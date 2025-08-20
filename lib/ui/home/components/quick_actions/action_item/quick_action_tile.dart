import 'package:flutter/material.dart';

/// A generic quick action tile used by various quick action components.
class QuickActionTile extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final TextStyle? titleStyle;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final bool showDragIndicator;

  const QuickActionTile({
    super.key,
    this.width = 120,
    this.height = 112,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.titleStyle,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
    this.showDragIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedIconBg = iconBackgroundColor ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    final Color resolvedIconColor = iconColor ?? Theme.of(context).colorScheme.primary;
    final Color resolvedBorderColor = borderColor ?? Theme.of(context).colorScheme.outline.withValues(alpha: 0.2);
    final TextStyle resolvedTitleStyle = titleStyle ?? Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12, fontWeight: FontWeight.w500);

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: borderWidth > 0
                  ? Border.all(color: resolvedBorderColor, width: borderWidth, style: BorderStyle.solid)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: resolvedIconBg,
                    borderRadius: BorderRadius.circular(20),
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
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 20,
                  child: Text(
                    title,
                    style: resolvedTitleStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
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


