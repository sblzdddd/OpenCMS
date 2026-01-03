import 'dart:io';
import 'package:flutter/material.dart';
import 'package:opencms/di/locator.dart';
import '../../models/skin.dart';
import '../../models/skin_image.dart';
import '../../services/skin_service.dart';
import 'package:provider/provider.dart';
import '../../services/theme_services.dart';

/// A widget that displays skin images with fallback to default icons
class SkinIcon extends StatefulWidget {
  final String imageKey;
  final IconData fallbackIcon;
  final Color? fallbackIconColor;
  final Color? fallbackIconBackgroundColor;
  final double size;
  final double? iconSize;
  final BorderRadius? borderRadius;
  final double fill;

  const SkinIcon({
    super.key,
    required this.imageKey,
    required this.fallbackIcon,
    this.fallbackIconColor,
    this.fallbackIconBackgroundColor,
    this.size = 50,
    this.iconSize,
    this.borderRadius,
    this.fill = 0,
  });

  @override
  State<SkinIcon> createState() => _SkinIconState();
}

class _SkinIconState extends State<SkinIcon> {
  Skin? _activeSkin;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    di<SkinService>().addListener(_onSkinChanged);
    // Get the cached active skin immediately
    _activeSkin = di<SkinService>().activeSkin;
    // If no cached skin, trigger loading in background
    if (_activeSkin == null) {
      _loadActiveSkin();
    }
  }

  @override
  void dispose() {
    di<SkinService>().removeListener(_onSkinChanged);
    _disposed = true;
    super.dispose();
  }

  void _onSkinChanged() {
    if (!_disposed && mounted) {
      setState(() {
        _activeSkin = di<SkinService>().activeSkin;
      });
    }
  }

  Future<void> _loadActiveSkin() async {
    try {
      final response = await di<SkinService>().getActiveSkin();
      if (response.success && response.skin != null) {
        // The listener will handle the state update
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get the skin image data for the specified key
  SkinImageData? _getSkinImageData() {
    if (_activeSkin == null) return null;
    return _activeSkin!.imageData[widget.imageKey];
  }

  @override
  Widget build(BuildContext context) {
    final imageData = _getSkinImageData();
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);

    // If no skin image available, show fallback icon
    if (imageData == null ||
        !imageData.hasImage ||
        imageData.imagePath == null) {
      return _buildFallbackIcon(context);
    }

    // Check if image file exists
    if (!File(imageData.imagePath!).existsSync()) {
      return _buildFallbackIcon(context);
    }

    // Show skin image
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipRRect(
        borderRadius:
            widget.borderRadius ?? themeNotifier.getBorderRadiusAll(1),
        child: Opacity(
          opacity: imageData.opacity,
          child: Image.file(
            File(imageData.imagePath!),
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackIcon(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.fallbackIconBackgroundColor,
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(widget.size * 0.2),
      ),
      child: Icon(
        widget.fallbackIcon,
        color: widget.fallbackIconColor,
        fill: widget.fill,
        size:
            widget.iconSize ?? widget.size * 0.54, // 27/50 ratio from original
      ),
    );
  }
}
