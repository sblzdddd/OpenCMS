import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/theme/theme_services.dart';
import '../../../data/models/skin/skin.dart';
import '../../../data/models/skin/skin_image.dart';
import '../../../data/models/skin/skin_image_type.dart';
import '../../../services/skin/skin_service.dart';

/// A widget that displays background images based on skin configuration
/// Falls back from category.background to global.background if available
class SkinBackgroundWidget extends StatefulWidget {
  final String category;
  final Widget child;
  final Color? fallbackColor;
  final BoxFit? boxFit;
  final double? opacity;

  const SkinBackgroundWidget({
    super.key,
    required this.category,
    required this.child,
    this.fallbackColor,
    this.boxFit,
    this.opacity,
  });

  @override
  State<SkinBackgroundWidget> createState() => _SkinBackgroundWidgetState();
}

class _SkinBackgroundWidgetState extends State<SkinBackgroundWidget> {
  final SkinService _skinService = SkinService.instance;
  Skin? _activeSkin;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _skinService.addListener(_onSkinChanged);
    // Get the cached active skin immediately, no loading needed
    _activeSkin = _skinService.activeSkin;
    // If no cached skin, trigger loading in background
    if (_activeSkin == null) {
      _loadActiveSkin();
    }
  }

  @override
  void dispose() {
    _skinService.removeListener(_onSkinChanged);
    _disposed = true;
    super.dispose();
  }

  void _onSkinChanged() {
    if (!_disposed && mounted) {
      setState(() {
        _activeSkin = _skinService.activeSkin;
      });
    }
  }

  Future<void> _loadActiveSkin() async {
    try {
      final response = await _skinService.getActiveSkin();
      if (!(response.success && response.skin != null)) {
        print('SkinBackgroundWidget: Failed to load active skin: ${response.error}');
      }
    } catch (e) {
      print('SkinBackgroundWidget: Error loading active skin: $e');
    }
  }

  /// Get the appropriate background image data for the category
  SkinImageData? _getBackgroundImageData() {
    if (_activeSkin == null) return null;

    // First try to get category-specific background
    final categoryKey = '${widget.category}.background';
    final categoryImageData = _activeSkin!.imageData[categoryKey];
    
    if (categoryImageData != null && categoryImageData.hasImage) {
      return categoryImageData;
    }

    // Fall back to global background
    final globalKey = 'global.background';
    final globalImageData = _activeSkin!.imageData[globalKey];
    
    if (globalImageData != null && globalImageData.hasImage) {
      return globalImageData;
    }

    print('SkinBackgroundWidget: No background image found');
    print(_activeSkin?.imageData);
    return null;
  }

  /// Get BoxFit from SkinImageData or use provided fallback
  BoxFit _getBoxFit(SkinImageData imageData) {
    if (widget.boxFit != null) return widget.boxFit!;
    
    switch (imageData.fillMode) {
      case SkinImageFillMode.contain:
        return BoxFit.contain;
      case SkinImageFillMode.stretch:
        return BoxFit.fill;
      case SkinImageFillMode.cover:
        return BoxFit.cover;
      case SkinImageFillMode.fit:
        return BoxFit.fitWidth;
    }
  }

  /// Get opacity from SkinImageData or use provided fallback
  double _getOpacity(SkinImageData imageData) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final isDarkMode = themeNotifier.isDarkMode;
    return widget.opacity ?? imageData.opacity * (isDarkMode ? 0.5 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final imageData = _getBackgroundImageData();
    
    if (imageData == null || imageData.imagePath == null) {
      // No background image available, use fallback color
      return Container(
        // If this is the login category, use the default login background asset
        decoration: BoxDecoration(
          color: widget.fallbackColor ?? Theme.of(context).colorScheme.surface,
          image: widget.category == 'login'
            ? const DecorationImage(
                image: AssetImage('assets/images/default-login-bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.2,
              )
            : null,
        ),
        child: widget.child,
      );
    }

    // Check if image file exists
    if (!File(imageData.imagePath!).existsSync()) {
      return Container(
        // If this is the login category, use the default login background asset
        decoration: BoxDecoration(
          color: widget.fallbackColor ?? Theme.of(context).colorScheme.surface,
          image: widget.category == 'login'
            ? const DecorationImage(
                image: AssetImage('assets/images/default-login-bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.2,
              )
            : null,
        ),
        child: widget.child,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: widget.fallbackColor ?? Colors.purpleAccent,
        image: DecorationImage(
          image: FileImage(File(imageData.imagePath!)),
          fit: _getBoxFit(imageData),
          opacity: _getOpacity(imageData),
        ),
      ),
      child: widget.child,
    );
  }
}
