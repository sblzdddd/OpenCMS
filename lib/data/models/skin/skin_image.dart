import 'package:flutter/material.dart';
import 'skin_image_type.dart';

/// Data class for foreground image with scale and positioning settings
class SkinImageData {
  final SkinImageType type;
  final String? imagePath;
  final double scale;
  final double opacity;
  final bool inside;
  final SkinImageFillMode fillMode;
  final SkinImagePosition position;

  const SkinImageData({
    this.type = SkinImageType.background,
    this.imagePath,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.inside = true,
    this.fillMode = SkinImageFillMode.cover,
    this.position = SkinImagePosition.mc,
  });

  /// Create a copy with updated fields
  SkinImageData copyWith({
    SkinImageType? type,
    String? imagePath,
    double? scale,
    double? opacity,
    bool? inside,
    SkinImageFillMode? fillMode,
    SkinImagePosition? position,
  }) {
    return SkinImageData(
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      scale: scale ?? this.scale,
      opacity: opacity ?? this.opacity,
      inside: inside ?? this.inside,
      fillMode: fillMode ?? this.fillMode,
      position: position ?? this.position,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    // Only serialize non-default values
    if (type != SkinImageType.background) {
      json['type'] = type.name;
    }
    
    if (imagePath != null && imagePath!.isNotEmpty) {
      json['imagePath'] = imagePath;
    }
    
    if (scale != 1.0) {
      json['scale'] = scale;
    }
    
    if (opacity != 1.0) {
      json['opacity'] = opacity;
    }
    
    if (inside != true) {
      json['inside'] = inside;
    }
    
    if (fillMode != SkinImageFillMode.cover) {
      json['fillMode'] = fillMode.name;
    }
    
    if (position != SkinImagePosition.mc) {
      json['position'] = position.name;
    }
    
    return json;
  }

  /// Create from JSON
  factory SkinImageData.fromJson(Map<String, dynamic> json) {
    return SkinImageData(
      type: SkinImageType.values.firstWhere(
        (type) => type.name == (json['type'] as String?),
        orElse: () => SkinImageType.background,
      ),
      imagePath: json['imagePath'] as String?,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      inside: json['inside'] as bool? ?? true,
      fillMode: SkinImageFillMode.values.firstWhere(
        (mode) => mode.name == (json['fillMode'] as String?),
        orElse: () => SkinImageFillMode.cover,
      ),
      position: SkinImagePosition.values.firstWhere(
        (pos) => pos.name == (json['position'] as String?),
        orElse: () => SkinImagePosition.mc,
      ),
    );
  }

  /// Check if image exists
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  /// Get validated scale (clamped between 0.5 and 2.0)
  double get validatedScale {
    return scale.clamp(0.5, 2.0);
  }

  /// Get BoxFit based on inside setting
  BoxFit get boxFit {
    return inside ? BoxFit.contain : BoxFit.cover;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkinImageData &&
        other.imagePath == imagePath &&
        other.scale == scale &&
        other.opacity == opacity &&
        other.inside == inside &&
        other.fillMode == fillMode &&
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(imagePath, scale, opacity, inside, fillMode, position);

  @override
  String toString() {
    return 'ForegroundImageData(imagePath: $imagePath, scale: $scale, opacity: $opacity, inside: $inside, fillMode: $fillMode, position: $position)';
  }
}
