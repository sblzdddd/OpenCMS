import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:window_manager/window_manager.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../services/theme/theme_services.dart';

/// A custom app bar that includes window controls for desktop platforms
/// and allows other scaffolds to add their own actions
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final double? toolbarHeight;
  final double? leadingWidth;
  final bool? centerTitle;
  final double? titleSpacing;
  final ShapeBorder? shape;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;
  final bool primary;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool forceMaterialTransparency;
  final EdgeInsets? padding;
  final Color? surfaceTintColor;

  const CustomAppBar({
    super.key,
    this.actions,
    this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.bottom,
    this.toolbarHeight,
    this.leadingWidth,
    this.centerTitle,
    this.titleSpacing,
    this.shape,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary = true,
    this.systemOverlayStyle,
    this.forceMaterialTransparency = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
    this.surfaceTintColor,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize {
    final height = toolbarHeight ?? kToolbarHeight;
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(height + bottomHeight);
  }
}

class _CustomAppBarState extends State<CustomAppBar> {
  int lastClickMilliseconds = DateTime.now().millisecondsSinceEpoch;
  bool isMaximized = false;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    // Check if we're on a desktop platform
    final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isLinux);

    // Create the list of actions, adding window controls for desktop
    List<Widget> allActions = widget.actions ?? <Widget>[];

    if (isDesktop) {
      allActions = [
        ...allActions,
        IconButton(
          padding: const EdgeInsets.all(0),
          visualDensity: VisualDensity.compact,
          onPressed: () async {
            await windowManager.minimize();
          },
          icon: const Icon(Symbols.minimize_rounded, size: 20),
          tooltip: 'Minimize',
        ),
        IconButton(
          padding: const EdgeInsets.all(0),
          visualDensity: VisualDensity.compact,
          onPressed: () async {
            isMaximized = await windowManager.isMaximized();
            if (isMaximized) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
            isMaximized = !isMaximized;
          },
          icon: Icon(Symbols.crop_square_rounded, size: 16, color: isMaximized ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface),
          tooltip: isMaximized ? 'Restore' : 'Maximize',
        ),
        IconButton(
          padding: const EdgeInsets.all(0),
          visualDensity: VisualDensity.compact,
          onPressed: () async {
            await windowManager.close();
          },
          icon: Icon(Symbols.close_rounded, weight: 500, size: 20, color: Theme.of(context).colorScheme.primary),
          tooltip: 'Close',
        ),
        const SizedBox(width: 8),
      ];
    }

    final appBar = Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: AppBar(
        actions: allActions,
        title: widget.title,
        backgroundColor: themeNotifier.hasActiveSkinBackgroundImage ? Colors.transparent : widget.backgroundColor,
        foregroundColor: widget.foregroundColor,
        elevation: widget.elevation,
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        leading: widget.leading,
        bottom: widget.bottom,
        toolbarHeight: widget.toolbarHeight,
        leadingWidth: widget.leadingWidth,
        centerTitle: widget.centerTitle,
        titleSpacing: widget.titleSpacing,
        shape: widget.shape,
        iconTheme: widget.iconTheme,
        actionsIconTheme: widget.actionsIconTheme,
        primary: widget.primary,
        systemOverlayStyle: widget.systemOverlayStyle,
        forceMaterialTransparency: isDesktop ? true : widget.forceMaterialTransparency,
        surfaceTintColor: Colors.transparent,
      ),
    );

    // Wrap with DragToMoveArea for desktop platforms
    if (isDesktop) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          windowManager.startDragging();
        },
        onTapDown: (_) {
          int currMills = DateTime.now().millisecondsSinceEpoch;
          if ((currMills - lastClickMilliseconds) < 600) {
            onDoubleTap();
          } else {
            lastClickMilliseconds = currMills;
            onSingleTap();
          }
        },
        child: appBar,
      );
    }

    return appBar;
  }

  void onSingleTap() {}

  void onDoubleTap() {
    _handleDoubleTap();
  }

  void _handleDoubleTap() async {
    try {
      bool isMaximized = await windowManager.isMaximized();
      if (!isMaximized) {
        await windowManager.maximize();
      } else {
        await windowManager.unmaximize();
      }
    } catch (e) {
      // Handle any errors silently to avoid blocking the UI
      debugPrint('Error handling double tap: $e');
    }
  }
}
