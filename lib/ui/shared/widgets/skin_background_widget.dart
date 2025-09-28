import 'dart:io';
import 'package:flutter/material.dart';
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
      if (response.success && response.skin != null) {
        print('SkinBackgroundWidget: Loaded active skin: ${response.skin!.name}');
        // The listener will handle the state update
      } else {
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
    
    print('SkinBackgroundWidget: Looking for category key: $categoryKey');
    print('SkinBackgroundWidget: Category image data: ${categoryImageData?.hasImage}');
    
    if (categoryImageData != null && categoryImageData.hasImage) {
      print('SkinBackgroundWidget: Using category background: $categoryKey');
      return categoryImageData;
    }

    // Fall back to global background
    final globalKey = 'global.background';
    final globalImageData = _activeSkin!.imageData[globalKey];
    
    print('SkinBackgroundWidget: Looking for global key: $globalKey');
    print('SkinBackgroundWidget: Global image data: ${globalImageData?.hasImage}');
    
    if (globalImageData != null && globalImageData.hasImage) {
      print('SkinBackgroundWidget: Using global background: $globalKey');
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
    return widget.opacity ?? imageData.opacity;
  }

  @override
  Widget build(BuildContext context) {
    final imageData = _getBackgroundImageData();
    
    if (imageData == null || imageData.imagePath == null) {
      // No background image available, use fallback color
      return Container(
        color: widget.fallbackColor ?? Theme.of(context).colorScheme.surface,
        child: widget.child,
      );
    }

    // Check if image file exists
    if (!File(imageData.imagePath!).existsSync()) {
      return Container(
        color: widget.fallbackColor ?? Colors.purpleAccent,
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
