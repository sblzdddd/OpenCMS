import 'package:flutter/material.dart';
import 'dart:ui'; // for lerpDouble

@immutable
class AppInteractionTheme extends ThemeExtension<AppInteractionTheme> {
  final double scaleDownFactor;

  const AppInteractionTheme({this.scaleDownFactor = 0.9});

  @override
  AppInteractionTheme copyWith({double? scaleDownFactor}) {
    return AppInteractionTheme(
      scaleDownFactor: scaleDownFactor ?? this.scaleDownFactor,
    );
  }

  @override
  AppInteractionTheme lerp(
    ThemeExtension<AppInteractionTheme>? other,
    double t,
  ) {
    if (other is! AppInteractionTheme) return this;
    return AppInteractionTheme(
      scaleDownFactor: lerpDouble(scaleDownFactor, other.scaleDownFactor, t)!,
    );
  }
}
