import 'package:flutter/material.dart';

/// A generic quick action tile used by various quick action components.
class QuickActionTile extends StatefulWidget {
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
    this.width = 100,
    this.height = 100,
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
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    final Color resolvedIconBg = widget.iconBackgroundColor ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    final Color resolvedIconColor = widget.iconColor ?? Theme.of(context).colorScheme.primary;
    final Color resolvedBorderColor = widget.borderColor ?? Theme.of(context).colorScheme.outline.withValues(alpha: 0.2);
    final TextStyle resolvedTitleStyle = widget.titleStyle ?? Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10, fontWeight: FontWeight.w500);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: widget.borderWidth > 0
                  ? Border.all(color: resolvedBorderColor, width: widget.borderWidth, style: BorderStyle.solid)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: resolvedIconBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          widget.icon,
                          color: resolvedIconColor,
                          size: 27,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 20,
                  child: Text(
                    widget.title,
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


