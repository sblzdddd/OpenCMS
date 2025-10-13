import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../services/theme/theme_services.dart';
import '../../../services/skin/skin_service.dart';
import '../../../data/models/skin/skin.dart';
import '../../../data/models/skin/skin_image.dart';
import '../../../data/models/skin/skin_image_type.dart';
import 'skin_background_widget.dart';

class CustomScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final AlignmentDirectional persistentFooterAlignment;
  final Widget? drawer;
  final DrawerCallback? onDrawerChanged;
  final Widget? endDrawer;
  final DrawerCallback? onEndDrawerChanged;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? drawerScrimColor;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;
  final bool isTransparent;
  final String skinKey;
  final Color? fallbackColor;
  final BoxFit? boxFit;
  final double? opacity;
  final bool isHomePage;
  final bool enableForeground;
  const CustomScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.resizeToAvoidBottomInset = true,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
    this.isTransparent = false,
    this.skinKey='global',
    this.fallbackColor,
    this.boxFit,
    this.opacity,
    this.isHomePage = false,
    this.enableForeground = true,
  });

  /// Get the appropriate foreground image data for the category
  SkinImageData? _getForegroundImageData(Skin activeSkin) {
    if (!enableForeground) return null;

    // First try to get category-specific foreground
    final categoryKey = '$skinKey.foreground';
    final categoryImageData = activeSkin.imageData[categoryKey];
    
    if (categoryImageData != null && categoryImageData.hasImage) {
      return categoryImageData;
    }

    // Fall back to global foreground
    final globalKey = 'global.foreground';
    final globalImageData = activeSkin.imageData[globalKey];
    
    if (globalImageData != null && globalImageData.hasImage) {
      return globalImageData;
    }

    return null;
  }

  /// Get opacity from SkinImageData or use provided fallback
  double _getForegroundOpacity(SkinImageData imageData) {
    return opacity ?? imageData.opacity;
  }

  /// Create positioned foreground image widget
  Widget? _createForegroundImage(Skin activeSkin) {
    final imageData = _getForegroundImageData(activeSkin);
    
    if (imageData == null || imageData.imagePath == null) {
      return null;
    }

    // Check if image file exists
    if (!File(imageData.imagePath!).existsSync()) {
      return null;
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: imageData.position.alignment,
          child: Opacity(
            opacity: _getForegroundOpacity(imageData),
            child: FutureBuilder<ImageInfo>(
              future: _getImageInfo(File(imageData.imagePath!)),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final imageInfo = snapshot.data!;
                  final scaledWidth = imageInfo.image.width * imageData.scale;
                  final scaledHeight = imageInfo.image.height * imageData.scale;
                  
                  return Image.file(
                    File(imageData.imagePath!),
                    width: scaledWidth,
                    height: scaledHeight,
                    fit: BoxFit.cover,
                  );
                }
                // Fallback while loading
                return Image.file(
                  File(imageData.imagePath!),
                  width: 300 * imageData.scale,
                  height: 400 * imageData.scale,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Get image information asynchronously
  Future<ImageInfo> _getImageInfo(File imageFile) async {
    final imageProvider = FileImage(imageFile);
    final imageStream = imageProvider.resolve(ImageConfiguration.empty);
    final completer = Completer<ImageInfo>();
    
    late ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
      if (!completer.isCompleted) {
        completer.complete(imageInfo);
        imageStream.removeListener(listener);
      }
    });
    
    imageStream.addListener(listener);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      persistentFooterAlignment: persistentFooterAlignment,
      drawer: drawer,
      onDrawerChanged: onDrawerChanged,
      endDrawer: endDrawer,
      onEndDrawerChanged: onEndDrawerChanged,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
      backgroundColor: Colors.transparent,
    );

    if (isTransparent) {
      return scaffold;
    }

    Color fallbackColor = Theme.of(context).colorScheme.surface;

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);

    if (isHomePage && themeNotifier.hasTransparentWindowEffect) {
      fallbackColor = fallbackColor.withValues(alpha: 0);
    } else if (themeNotifier.hasTransparentWindowEffect) {
      fallbackColor = fallbackColor.withValues(alpha: themeNotifier.isDarkMode? 0.8:0.5);
    }

    // If skinKey is provided, wrap with SkinBackgroundWidget
    final backgroundWidget = SkinBackgroundWidget(
      category: skinKey,
      fallbackColor: fallbackColor,
      boxFit: boxFit,
      opacity: opacity,
      child: scaffold,
    );

    // Check if we need to add foreground image
    if (enableForeground) {
      final skinService = SkinService.instance;
      final activeSkin = skinService.activeSkin;
      
      if (activeSkin != null) {
        final foregroundImage = _createForegroundImage(activeSkin);
        
        if (foregroundImage != null) {
          return Stack(
            children: [
              backgroundWidget,
              foregroundImage,
            ],
          );
        }
      }
    }

    return backgroundWidget;
  }
}
