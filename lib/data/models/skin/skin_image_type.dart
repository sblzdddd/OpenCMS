import 'package:flutter/material.dart';

/// Enum representing different types of skin elements
enum SkinImageType { background, foreground, icon }

/// Enum for background image positioning
enum SkinImageFillMode { contain, stretch, cover, fit }

/// Enum for foreground image positioning
enum SkinImagePosition {
  tl, // top-left
  tc, // top-center
  tr, // top-right
  ml, // middle-left
  mc, // middle-center
  mr, // middle-right
  bl, // bottom-left
  bc, // bottom-center
  br, // bottom-right
}

/// Extension to get display names and descriptions for skin types
extension SkinImageTypeExtension on SkinImageType {
  String get displayName {
    switch (this) {
      case SkinImageType.background:
        return 'Background';
      case SkinImageType.foreground:
        return 'Foreground';
      case SkinImageType.icon:
        return 'Icon';
    }
  }

  String get fieldName {
    switch (this) {
      case SkinImageType.background:
        return 'backgroundImage';
      case SkinImageType.foreground:
        return 'foregroundImage';
      case SkinImageType.icon:
        return 'iconImage';
    }
  }
}

/// Extension for background position display names
extension SkinImageFillModeExtension on SkinImageFillMode {
  String get displayName {
    switch (this) {
      case SkinImageFillMode.contain:
        return 'Contain';
      case SkinImageFillMode.stretch:
        return 'Stretch';
      case SkinImageFillMode.cover:
        return 'Cover';
      case SkinImageFillMode.fit:
        return 'Fit';
    }
  }
}

/// Extension for foreground position display names
extension SkinImagePositionExtension on SkinImagePosition {
  String get displayName {
    switch (this) {
      case SkinImagePosition.tl:
        return 'Top Left';
      case SkinImagePosition.tc:
        return 'Top Center';
      case SkinImagePosition.tr:
        return 'Top Right';
      case SkinImagePosition.ml:
        return 'Middle Left';
      case SkinImagePosition.mc:
        return 'Middle Center';
      case SkinImagePosition.mr:
        return 'Middle Right';
      case SkinImagePosition.bl:
        return 'Bottom Left';
      case SkinImagePosition.bc:
        return 'Bottom Center';
      case SkinImagePosition.br:
        return 'Bottom Right';
    }
  }

  Alignment get alignment {
    switch (this) {
      case SkinImagePosition.tl:
        return Alignment.topLeft;
      case SkinImagePosition.tc:
        return Alignment.topCenter;
      case SkinImagePosition.tr:
        return Alignment.topRight;
      case SkinImagePosition.ml:
        return Alignment.centerLeft;
      case SkinImagePosition.mc:
        return Alignment.center;
      case SkinImagePosition.mr:
        return Alignment.centerRight;
      case SkinImagePosition.bl:
        return Alignment.bottomLeft;
      case SkinImagePosition.bc:
        return Alignment.bottomCenter;
      case SkinImagePosition.br:
        return Alignment.bottomRight;
    }
  }
}
