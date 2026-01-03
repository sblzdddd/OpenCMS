import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencms/di/locator.dart';
import 'dart:io';
import '../../../models/skin.dart';
import '../../../models/skin_image.dart';
import '../../../models/skin_image_type.dart';
import '../../../services/skin_service.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../shared/views/custom_snackbar/snackbar_utils.dart';
import '../../dialogs/image_settings_dialog.dart';
import 'package:logging/logging.dart';

final logger = Logger('BaseImageCustomizer');

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    di<SkinService>().initialize();
  }

  @override
  void didUpdateWidget(BaseImageCustomizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force rebuild when skin changes
    if (mounted &&
        (oldWidget.skin != widget.skin ||
            oldWidget.skin.updatedAt != widget.skin.updatedAt ||
            oldWidget.imageKey != widget.imageKey)) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Pick and set an image for the skin
  Future<void> pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await di<SkinService>().pickAndSetImage(
        skinId: widget.skin.id,
        key: widget.imageKey,
        source: ImageSource.gallery,
      );

      if (response.success && response.skin != null) {
        widget.onSkinUpdated?.call(response.skin!);
        logger.info('${widget.imageKey} image set successfully');
      } else {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            'Error setting image: ${response.error ?? 'Failed to set image'}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error: $e');
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
      final response = await di<SkinService>().removeSkinImage(
        skinId: widget.skin.id,
        key: widget.imageKey,
      );

      if (response.success && response.skin != null) {
        widget.onSkinUpdated?.call(response.skin!);
        logger.info('${widget.imageKey} image removed');
      } else {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            'Error removing image: ${response.error ?? 'Failed to remove image'}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  SkinImageData? get currentImageData {
    return widget.skin.imageData[widget.imageKey];
  }

  String? get currentImagePath {
    return currentImageData?.imagePath;
  }

  bool get hasCurrentImage {
    final path = currentImagePath;
    if (path == null || path.isEmpty) {
      logger.info('${widget.imageKey}: No image path found');
      return false;
    }

    final file = File(path);
    final exists = file.existsSync();
    return exists;
  }

  SkinImageType get imageType {
    return currentImageData?.type ?? SkinImageType.background;
  }

  Widget buildImagePreview({
    double? height,
    double? width,
    BoxFit? fit,
    BorderRadius? borderRadius,
  }) {
    if (!hasCurrentImage) {
      return _buildImagePlaceholder(
        height: height,
        width: width,
        borderRadius: borderRadius,
      );
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
            // Apply opacity and scale transformations
            Opacity(
              opacity: imageData.opacity,
              child: Transform.scale(
                scale: imageData.validatedScale,
                child: Image.file(
                  File(currentImagePath!),
                  fit: effectiveFit,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder(
                      height: height,
                      width: width,
                      borderRadius: borderRadius,
                    );
                  },
                ),
              ),
            ),
            // Show scale indicator if not 100%
            if (imageData.scale != 1.0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
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
            // Show opacity indicator if not 100%
            if (imageData.opacity != 1.0)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(imageData.opacity * 100).round()}%',
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
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 4),
          Text(
            imageType.displayName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlaceholderIcon() {
    switch (imageType) {
      case SkinImageType.background:
        return Symbols.photo_library_rounded;
      case SkinImageType.icon:
        return Symbols.image_rounded;
    }
  }

  Widget buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Change Image',
            onPressed: _isLoading ? null : pickImage,
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
            onPressed: _showImageSettingsDialog,
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
        ],
      ],
    );
  }

  Future<void> _showImageSettingsDialog() async {
    if (currentImageData == null || !mounted) return;

    final result = await showDialog<SkinImageData>(
      context: context,
      builder: (context) => ImageSettingsDialog(imageData: currentImageData!),
    );

    if (result != null && mounted) {
      await _updateImageDataInSkin(result);
    }
  }

  Future<void> _updateImageDataInSkin(SkinImageData updatedData) async {
    if (!mounted) return;

    try {
      final response = await di<SkinService>().updateSkinImageData(
        skinId: widget.skin.id,
        imageKey: widget.imageKey,
        updatedImageData: updatedData,
      );

      if (response.success && response.skin != null) {
        if (mounted) {
          setState(() {
            widget.onSkinUpdated?.call(response.skin!);
          });
        }
      } else {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            response.message ?? 'Failed to update image data',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to update image data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: Padding(padding: const EdgeInsets.all(12), child: content),
      ),
    );
  }
}
