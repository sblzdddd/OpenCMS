import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

class DynamicGradientBanner extends StatefulWidget {
  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;
  final Color? themeColor;
  final String? themeColorHex;

  const DynamicGradientBanner({
    super.key,
    this.color1 = const ui.Color.fromARGB(255, 49, 182, 226),
    this.color2 = const ui.Color.fromARGB(255, 166, 248, 250),
    this.color3 = const ui.Color.fromARGB(255, 44, 226, 231),
    this.color4 = const ui.Color.fromARGB(255, 131, 227, 255),
    this.themeColor,
    this.themeColorHex,
  });

  @override
  State<DynamicGradientBanner> createState() => _DynamicGradientBannerState();
}

class _DynamicGradientBannerState extends State<DynamicGradientBanner>
    with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  late final Ticker _ticker;
  double _time = 0.0; // seconds

  @override
  void initState() {
    super.initState();
    _loadProgram();
    _ticker = createTicker((elapsed) {
      _time = elapsed.inMilliseconds / 1000.0;
      if (mounted) setState(() {});
    });
    _ticker.start();
  }

  Future<void> _loadProgram() async {
    final program = await ui.FragmentProgram.fromAsset(
      'assets/shaders/dynamic_banner.frag',
    );
    if (mounted) {
      setState(() {
        _program = program;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final program = _program;
    if (program == null) {
      return const SizedBox.expand(child: ColoredBox(color: Colors.white));
    }

    Color? b = Theme.of(context).colorScheme.primary;

    final Color c1;
    final Color c2;
    final Color c3;
    final Color c4;

    c1 = ColorUtils.adjustHsl(
      b,
      hueDelta: 4,
      saturation: 0.6,
      lightness: 0.54,
    );
    c2 = ColorUtils.adjustHsl(b, hueDelta: 2, saturation: 0.5, lightness: 0.8);
    c3 = ColorUtils.adjustHsl(b, hueDelta: 1, saturation: 0.6, lightness: 0.6);
    c4 = ColorUtils.adjustHsl(b, hueDelta: 0, saturation: 0.7, lightness: 0.7);
    return CustomPaint(
      painter: _DynamicGradientPainter(
        program: program,
        time: _time,
        color1: c1,
        color2: c2,
        color3: c3,
        color4: c4,
      ),
      size: Size.infinite,
    );
  }
}

class _DynamicGradientPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final double time;
  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;

  _DynamicGradientPainter({
    required this.program,
    required this.time,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.color4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();

    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time.toDouble());

    void setColor(int baseIndex, Color c) {
      shader.setFloat(baseIndex + 0, c.r);
      shader.setFloat(baseIndex + 1, c.g);
      shader.setFloat(baseIndex + 2, c.b);
    }

    setColor(3, color1);
    setColor(6, color2);
    setColor(9, color3);
    setColor(12, color4);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _DynamicGradientPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2 ||
        oldDelegate.color3 != color3 ||
        oldDelegate.color4 != color4 ||
        oldDelegate.program != program;
  }
}
