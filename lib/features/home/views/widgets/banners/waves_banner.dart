import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'color_utils.dart';

class WavesBanner extends StatefulWidget {
  final Color color;
  final Color? themeColor;
  final String? themeColorHex;

  const WavesBanner({
    super.key,
    this.color = const ui.Color.fromARGB(255, 131, 227, 255),
    this.themeColor,
    this.themeColorHex,
  });

  @override
  State<WavesBanner> createState() => _WavesBannerState();
}

class _WavesBannerState extends State<WavesBanner>
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
      'assets/shaders/waves.frag',
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

    final Color c1 = ColorUtils.adjustHsl(
      b,
      hueDelta: 4,
      saturation: 0.6,
      lightness: 0.54,
    );
    return CustomPaint(
      painter: _WavesPainter(program: program, time: _time, color: c1),
      size: Size.infinite,
    );
  }
}

class _WavesPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final double time;
  final Color color;

  _WavesPainter({
    required this.program,
    required this.time,
    required this.color,
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

    setColor(3, color);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _WavesPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.color != color ||
        oldDelegate.program != program;
  }
}
