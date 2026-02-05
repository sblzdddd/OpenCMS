import 'package:flutter/material.dart';

class RGB {
  final int r;
  final int g;
  final int b;

  const RGB(this.r, this.g, this.b);
}

class ColorUtils {
  static Color fromHex(String hex) {
    var value = hex.replaceAll('#', '').trim();
    if (value.length == 6) {
      value = 'FF$value';
    }
    final int intValue = int.parse(value, radix: 16);
    return Color(intValue);
  }

  static String toHex(
    Color color, {
    bool leadingHashSign = true,
    bool includeAlpha = false,
  }) {
    final String a = ((color.a * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    final String r = ((color.r * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    final String g = ((color.g * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    final String b = ((color.b * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    final String body = includeAlpha ? '$a$r$g$b' : '$r$g$b';
    return leadingHashSign ? '#$body' : body;
  }

  static RGB hexToRgb(String hex) {
    final color = fromHex(hex);
    return RGB(
      ((color.r * 255.0).round() & 0xff),
      ((color.g * 255.0).round() & 0xff),
      ((color.b * 255.0).round() & 0xff),
    );
  }

  static String rgbToHex(int r, int g, int b, {bool leadingHashSign = true}) {
    final rr = r.clamp(0, 255).toInt().toRadixString(16).padLeft(2, '0');
    final gg = g.clamp(0, 255).toInt().toRadixString(16).padLeft(2, '0');
    final bb = b.clamp(0, 255).toInt().toRadixString(16).padLeft(2, '0');
    final body = '$rr$gg$bb';
    return leadingHashSign ? '#$body' : body;
  }

  static Color adjustHsl(
    Color color, {
    double hueDelta = 0.0, // degrees
    double saturation = 1.0,
    double lightness = 1.0,
  }) {
    final hsl = HSLColor.fromColor(color);
    final double newHue = (hsl.hue + hueDelta) % 360.0;
    final double newSaturation = (saturation).clamp(0.0, 1.0);
    final double newLightness = (lightness).clamp(0.0, 1.0);
    return hsl
        .withHue(newHue)
        .withSaturation(newSaturation)
        .withLightness(newLightness)
        .toColor();
  }
}
