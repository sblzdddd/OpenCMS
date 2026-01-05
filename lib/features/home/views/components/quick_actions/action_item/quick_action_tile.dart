import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../theme/services/theme_services.dart';
import '../../../../../shared/views/widgets/scaled_ink_well.dart';
import '../../../../../theme/views/widgets/skin_icon_widget.dart';

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
  final bool showExternalIcon;
  final String? skinImageKey;

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
    this.showExternalIcon = false,
    this.skinImageKey,
  });

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final Color resolvedIconBg =
        widget.iconBackgroundColor ??
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    final Color resolvedIconColor =
        widget.iconColor ?? Theme.of(context).colorScheme.primary;
    final TextStyle resolvedTitleStyle =
        widget.titleStyle ??
        Theme.of(context).textTheme.bodyMedium!.copyWith(
          // fontSize: (context.locale == Locale('zh', 'CN') ? 12 : 10),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ScaledInkWell(
        scaleDownFactor: 0.9,
        onTap: widget.onTap,
        borderRadius: themeNotifier.getBorderRadiusAll(1.5),
        background: (inkWell) => Material(
          color: themeNotifier.needTransparentBG
              ? (!themeNotifier.isDarkMode
                    ? Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.7)
                    : Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.4))
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
          child: inkWell,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: themeNotifier.getBorderRadiusAll(1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkinIcon(
                    imageKey: widget.skinImageKey ?? 'actionIcons.unknown',
                    fallbackIcon: widget.icon,
                    fallbackIconColor: resolvedIconColor,
                    fallbackIconBackgroundColor: resolvedIconBg,
                    size: 56,
                    iconSize: 35,
                  ),
                  const SizedBox(height: 6),
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
            if (widget.showDragIndicator)
              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.drag_indicator,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            if (widget.showExternalIcon && !widget.showDragIndicator)
              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
