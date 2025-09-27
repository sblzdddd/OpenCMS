import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../services/theme/theme_services.dart';

class CustomScaffold extends Scaffold {
  CustomScaffold({
    super.key,
    super.appBar,
    super.body,
    super.floatingActionButton,
    super.floatingActionButtonLocation,
    super.floatingActionButtonAnimator,
    super.persistentFooterButtons,
    super.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    super.drawer,
    super.onDrawerChanged,
    super.endDrawer,
    super.onEndDrawerChanged,
    super.bottomNavigationBar,
    super.bottomSheet,
    super.resizeToAvoidBottomInset,
    super.primary = true,
    super.drawerDragStartBehavior = DragStartBehavior.start,
    super.extendBody = false,
    super.extendBodyBehindAppBar = false,
    super.drawerScrimColor,
    super.drawerEdgeDragWidth,
    super.drawerEnableOpenDragGesture = true,
    super.endDrawerEnableOpenDragGesture = true,
    super.restorationId,
    bool isTransparent = false,
    BuildContext? context,
  }) : super(
          backgroundColor: isTransparent && context != null
              ? Theme.of(context).colorScheme.surface.withValues(
                  alpha: ThemeNotifier.instance.needTransparentBG
                      ? ThemeNotifier.instance.isDarkMode ? 0.8 : 0.5
                      : 1,
                )
              : null,
        );
}
