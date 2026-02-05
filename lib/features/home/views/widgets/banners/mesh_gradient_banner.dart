import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'color_utils.dart';

class MeshGradientBanner extends StatefulWidget {
  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;
  final Color? themeColor;
  final String? themeColorHex;

  const MeshGradientBanner({
    super.key,
    this.color1 = const ui.Color.fromARGB(255, 49, 182, 226),
    this.color2 = const ui.Color.fromARGB(255, 166, 248, 250),
    this.color3 = const ui.Color.fromARGB(255, 44, 226, 231),
    this.color4 = const ui.Color.fromARGB(255, 131, 227, 255),
    this.themeColor,
    this.themeColorHex,
  });

  @override
  State<MeshGradientBanner> createState() => _MeshGradientBannerState();
}

class _MeshGradientBannerState extends State<MeshGradientBanner>
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
      'assets/shaders/mesh_gradient.frag',
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

    c1 = ColorUtils.adjustHsl(b, hueDelta: 4, saturation: 0.6, lightness: 0.54);
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
