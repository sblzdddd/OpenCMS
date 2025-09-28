import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../data/models/skin/skin.dart';
import '../../data/models/skin/skin_image.dart';
import '../../data/models/skin/skin_image_type.dart';
import '../../services/skin/skin_service.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../ui/shared/custom_snackbar/snackbar_utils.dart';
import 'image_settings_dialog.dart';

/// Base class for image customization functionality
class BaseImageCustomizer extends StatefulWidget {
  final Skin skin;
  final String imageKey;
  final Function(Skin)? onSkinUpdated;
  final String? title;
  final IconData? icon;
  final double? width;
  final bool showCard;

  const BaseImageCustomizer({
    super.key,
    required this.skin,
    required this.imageKey,
    this.onSkinUpdated,
    this.title,
    this.icon,
    this.width,
    this.showCard = true,
  });

  @override
  State<BaseImageCustomizer> createState() => _BaseImageCustomizerState();
}

class _BaseImageCustomizerState extends State<BaseImageCustomizer> {
  final SkinService _skinService = SkinService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _skinService.initialize();
  }

  @override
  void didUpdateWidget(BaseImageCustomizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force rebuild when skin changes
    if (mounted && (oldWidget.skin != widget.skin || 
        oldWidget.skin.updatedAt != widget.skin.updatedAt ||
        oldWidget.imageKey != widget.imageKey)) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }

  /// Pick and set an image for the skin
  Future<void> pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _skinService.pickAndSetImage(
        skinId: widget.skin.id,
        key: widget.imageKey,
        source: ImageSource.gallery,
      );

      if (response.success && response.skin != null) {
        widget.onSkinUpdated?.call(response.skin!);
        debugPrint('${widget.imageKey} image set successfully');
      } else {
        if (mounted) {
          _onImageSetError(response.error ?? 'Failed to set image');
        }
      }
    } catch (e) {
      if (mounted) {
        _onImageSetError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Remove the current image
  Future<void> removeImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _skinService.removeSkinImage(
        skinId: widget.skin.id,
        key: widget.imageKey,
      );

      if (response.success && response.skin != null) {
        widget.onSkinUpdated?.call(response.skin!);
        debugPrint('${widget.imageKey} image removed');
      } else {
        if (mounted) {
          _onImageRemovedError(response.error ?? 'Failed to remove image');
        }
      }
    } catch (e) {
      if (mounted) {
        _onImageRemovedError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Get the current image data for the key
  SkinImageData? get currentImageData {
    return widget.skin.imageData[widget.imageKey];
  }

  /// Get the current image path for the key
  String? get currentImagePath {
    return currentImageData?.imagePath;
  }

  /// Check if there's a current image
  bool get hasCurrentImage {
    final path = currentImagePath;
    if (path == null || path.isEmpty) {
      debugPrint('${widget.imageKey}: No image path found');
      return false;
    }
    
    // Check if file exists
    final file = File(path);
    final exists = file.existsSync();
    debugPrint('${widget.imageKey}: Image path: $path, exists: $exists');
    return exists;
  }

  /// Get the image type for this key
  SkinImageType get imageType {
    return currentImageData?.type ?? SkinImageType.background;
  }

  /// Build image preview widget
  Widget buildImagePreview({
    double? height,
    double? width,
    BoxFit? fit,
    BorderRadius? borderRadius,
  }) {
    if (!hasCurrentImage) {
      return _buildImagePlaceholder(height: height, width: width, borderRadius: borderRadius);
    }

    final imageData = currentImageData!;
    final effectiveFit = fit ?? imageData.boxFit;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: Stack(
          children: [
            Image.file(
              File(currentImagePath!),
              fit: effectiveFit,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder(height: height, width: width, borderRadius: borderRadius);
              },
            ),
            if (imageData.scale != 1.0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(imageData.scale * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build image placeholder widget
  Widget _buildImagePlaceholder({
    double? height,
    double? width,
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height ?? 100,
      width: width ?? 100,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getPlaceholderIcon(),
            size: 32,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 4),
          Text(
            imageType.displayName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Get appropriate placeholder icon based on image type
  IconData _getPlaceholderIcon() {
    switch (imageType) {
      case SkinImageType.background:
        return Symbols.photo_library_rounded;
      case SkinImageType.foreground:
        return Symbols.layers_rounded;
      case SkinImageType.icon:
        return Symbols.image_rounded;
    }
  }

  /// Build action buttons for image operations
  Widget buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Change Image',
            onPressed: _isLoading ? null : () => pickImage(),
            icon: const Icon(Symbols.edit_rounded),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        if (hasCurrentImage) ...[
          const SizedBox(width: 4),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Settings',
            onPressed: () => _showImageSettingsDialog(),
            icon: const Icon(Symbols.settings_rounded, size: 16),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: _isLoading ? null : removeImage,
            icon: const Icon(Symbols.delete_rounded, size: 16),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ]
      ],
    );
  }

  /// Callback when image set fails
  void _onImageSetError(String error) {
    SnackbarUtils.showError(context, 'Error setting image: $error');
  }

  /// Callback when image removal fails
  void _onImageRemovedError(String error) {
    SnackbarUtils.showError(context, 'Error removing image: $error');
  }

  /// Show image settings dialog
  Future<void> _showImageSettingsDialog() async {
    if (currentImageData == null || !mounted) return;

    final result = await showDialog<SkinImageData>(
      context: context,
      builder: (context) => ImageSettingsDialog(
        imageData: currentImageData!,
        onImageDataChanged: (updatedData) {
          // Update the image data in real-time for preview
          if (mounted) {
            _updateImageDataInSkin(updatedData);
          }
        },
      ),
    );

    if (result != null && mounted) {
      // Final update when dialog is closed with Apply
      _updateImageDataInSkin(result);
    }
  }

  /// Update image data in the skin
  void _updateImageDataInSkin(SkinImageData updatedData) {
    if (!mounted) return;
    
    setState(() {
      // Create a new skin with updated image data
      final updatedImageData = Map<String, SkinImageData>.from(widget.skin.imageData);
      updatedImageData[widget.imageKey] = updatedData;
      
      final updatedSkin = widget.skin.copyWith(
        imageData: updatedImageData,
        updatedAt: DateTime.now(),
      );
      
      widget.onSkinUpdated?.call(updatedSkin);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('${widget.imageKey}: Building BaseImageCustomizer');
    debugPrint('${widget.imageKey}: hasCurrentImage = $hasCurrentImage');
    
    final content = Column(
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        buildImagePreview(),
        const SizedBox(height: 12),
        buildActionButtons(context),
      ],
    );

    if (!widget.showCard) {
      return content;
    }

    return SizedBox(
      width: widget.width ?? 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: content,
        ),
      ),
    );
  }
}