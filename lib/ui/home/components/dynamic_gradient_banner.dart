import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DynamicGradientBanner extends StatefulWidget {
  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;

  const DynamicGradientBanner({
    super.key,
    this.color1 = const ui.Color.fromARGB(255, 49, 182, 226),
    this.color2 = const ui.Color.fromARGB(255, 166, 248, 250),
    this.color3 = const ui.Color.fromARGB(255, 44, 226, 231),
    this.color4 = const ui.Color.fromARGB(255, 131, 227, 255),
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
      // Target ~30fps updates
      _time = elapsed.inMilliseconds / 1000.0;
      if (mounted) setState(() {});
    });
    _ticker.start();
  }

  Future<void> _loadProgram() async {
    final program = await ui.FragmentProgram.fromAsset('assets/shaders/dynamic_banner.frag');
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
    return CustomPaint(
      painter: _DynamicGradientPainter(
        program: program,
        time: _time,
        color1: widget.color1,
        color2: widget.color2,
        color3: widget.color3,
        color4: widget.color4,
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

    // Uniform packing must match shader declaration order
    // uResolution (2), uTime(1), then 4 vec3 colors (12 floats)
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


