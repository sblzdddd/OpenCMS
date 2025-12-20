import 'dart:io';
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
    double? opacity,
    this.inside = true,
    this.fillMode = SkinImageFillMode.cover,
    this.position = SkinImagePosition.br,
  }) : opacity = opacity ?? (type == SkinImageType.icon ? 1.0 : 0.2);

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
  Map<String, dynamic> toJson({bool useRelativePath = true}) {
    final json = <String, dynamic>{};

    // Only serialize non-default values

    if (imagePath != null && imagePath!.isNotEmpty) {
      if (useRelativePath) {
        // Extract just the filename for export
        json['imagePath'] = imagePath!.split(Platform.pathSeparator).last;
      } else {
        json['imagePath'] = imagePath;
      }
    }

    if (scale != 1.0) {
      json['scale'] = scale;
    }

    if (opacity != (type == SkinImageType.icon ? 1.0 : 0.2)) {
      json['opacity'] = opacity;
    }

    if (inside != true) {
      json['inside'] = inside;
    }

    if (fillMode != SkinImageFillMode.cover) {
      json['fillMode'] = fillMode.name;
    }

    if (position != SkinImagePosition.br) {
      json['position'] = position.name;
    }

    return json;
  }

  /// Create from JSON using provided defaults (type and default values come from defaults)
  factory SkinImageData.fromJsonWithDefaults(
    Map<String, dynamic> json,
    SkinImageData defaults,
  ) {
    final type = defaults.type;
    return SkinImageData(
      type: type,
      imagePath: (json['imagePath'] as String?) ?? defaults.imagePath,
      scale: (json['scale'] as num?)?.toDouble() ?? defaults.scale,
      opacity: (json['opacity'] as num?)?.toDouble() ?? defaults.opacity,
      inside: json['inside'] as bool? ?? defaults.inside,
      fillMode: SkinImageFillMode.values.firstWhere(
        (mode) => mode.name == (json['fillMode'] as String?),
        orElse: () => defaults.fillMode,
      ),
      position: SkinImagePosition.values.firstWhere(
        (pos) => pos.name == (json['position'] as String?),
        orElse: () => defaults.position,
      ),
    );
  }

  /// Check if image exists
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  /// Get validated scale (clamped between 0.2 and 2.0)
  double get validatedScale {
    return scale.clamp(0.2, 2.0);
  }

  /// Get BoxFit based on inside setting
  BoxFit get boxFit {
    return inside ? BoxFit.contain : BoxFit.cover;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkinImageData &&
        other.type == type &&
        other.imagePath == imagePath &&
        other.scale == scale &&
        other.opacity == opacity &&
        other.inside == inside &&
        other.fillMode == fillMode &&
        other.position == position;
  }

  @override
  int get hashCode =>
      Object.hash(type, imagePath, scale, opacity, inside, fillMode, position);

  @override
  String toString() {
    return 'ForegroundImageData(imagePath: $imagePath, scale: $scale, opacity: $opacity, inside: $inside, fillMode: $fillMode, position: $position)';
  }
}
