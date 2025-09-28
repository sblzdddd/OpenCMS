import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../data/models/skin/skin_image.dart';
import '../../data/models/skin/skin_image_type.dart';

/// Dialog for configuring image settings
class ImageSettingsDialog extends StatefulWidget {
  final SkinImageData imageData;
  final Function(SkinImageData)? onImageDataChanged;

  const ImageSettingsDialog({
    super.key,
    required this.imageData,
    this.onImageDataChanged,
  });

  @override
  State<ImageSettingsDialog> createState() => _ImageSettingsDialogState();
}

class _ImageSettingsDialogState extends State<ImageSettingsDialog> {
  late SkinImageData _currentImageData;
  late double _scale;
  late double _opacity;
  late bool _inside;
  late SkinImageFillMode _fillMode;
  late SkinImagePosition _position;

  @override
  void initState() {
    super.initState();
    _currentImageData = widget.imageData;
    _scale = _currentImageData.scale;
    _opacity = _currentImageData.opacity;
    _inside = _currentImageData.inside;
    _fillMode = _currentImageData.fillMode;
    _position = _currentImageData.position;
  }

  void _updateImageData() {
    final updatedData = _currentImageData.copyWith(
      scale: _scale,
      opacity: _opacity,
      inside: _inside,
      fillMode: _fillMode,
      position: _position,
    );
    
    setState(() {
      _currentImageData = updatedData;
    });
    
    // Only call the callback if the dialog is still mounted
    if (mounted) {
      widget.onImageDataChanged?.call(updatedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Symbols.settings_rounded),
          const SizedBox(width: 8),
          Text('${_currentImageData.type.displayName} Settings'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scale Settings
              _buildSectionHeader('Scale', Symbols.zoom_in_rounded),
              _buildScaleSlider(),
              const SizedBox(height: 16),
              
              // Opacity Settings
              _buildSectionHeader('Opacity', Symbols.opacity_rounded),
              _buildOpacitySlider(),
              const SizedBox(height: 16),
              
              
              // Fill Mode (for background images)
              if (_currentImageData.type == SkinImageType.background) ...[
                _buildFillModeSelector(),
                const SizedBox(height: 16),
              ],
              
              // Position (for foreground images)
              if (_currentImageData.type == SkinImageType.foreground) ...[
                _buildInsideToggle(),
                const SizedBox(height: 16),
                _buildPositionSelector(),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            _updateImageData();
            Navigator.of(context).pop(_currentImageData);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleSlider() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                value: _scale,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                label: '${(_scale * 100).round()}%',
                onChanged: (value) {
                  setState(() {
                    _scale = value;
                  });
                  _updateImageData();
                },
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${(_scale * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpacitySlider() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                value: _opacity,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                label: '${(_opacity * 100).round()}%',
                onChanged: (value) {
                  setState(() {
                    _opacity = value;
                  });
                  _updateImageData();
                },
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${(_opacity * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsideToggle() {
    return DropdownButtonFormField<bool>(
      value: _inside,
      decoration: const InputDecoration(
        labelText: 'Fit Mode',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem<bool>(
          value: true,
          child: Text('Inside'),
        ),
        DropdownMenuItem<bool>(
          value: false,
          child: Text('Outside'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _inside = value!;
        });
        _updateImageData();
      },
    );
  }

  Widget _buildFillModeSelector() {
    return DropdownButtonFormField<SkinImageFillMode>(
      value: _fillMode,
      decoration: const InputDecoration(
        labelText: 'Fill Mode',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: SkinImageFillMode.values.map((mode) {
        return DropdownMenuItem<SkinImageFillMode>(
          value: mode,
          child: Text(mode.displayName),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _fillMode = value!;
        });
        _updateImageData();
      },
    );
  }

  Widget _buildPositionSelector() {
    return DropdownButtonFormField<SkinImagePosition>(
      value: _position,
      decoration: const InputDecoration(
        labelText: 'Position',
        helperText: 'Where to position the foreground image',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: SkinImagePosition.values.map((position) {
        return DropdownMenuItem<SkinImagePosition>(
          value: position,
          child: Text(position.displayName),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _position = value!;
        });
        _updateImageData();
      },
    );
  }
}
