import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../services/theme/theme_services.dart';
import '../../../../shared/scaled_ink_well.dart';

/// A generic quick action tile used by various quick action components.
class QuickActionTile extends StatefulWidget {
  final double width;
  final double height;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final TextStyle? titleStyle;
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
    this.onTap,
    this.showDragIndicator = false,
  });

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    final Color resolvedIconBg = widget.iconBackgroundColor ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    final Color resolvedIconColor = widget.iconColor ?? Theme.of(context).colorScheme.primary;
    final TextStyle resolvedTitleStyle = widget.titleStyle ?? Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10, fontWeight: FontWeight.w500);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ScaledInkWell(
        scaleDownFactor: 0.9,
        onTap: widget.onTap,
        borderRadius: themeNotifier.getBorderRadiusAll(1.5),
        background: (inkWell) => Material(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
          child: inkWell,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: themeNotifier.getBorderRadiusAll(1.5),
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
                  borderRadius: themeNotifier.getBorderRadiusAll(1),
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
              Text(
                widget.title,
                style: resolvedTitleStyle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


