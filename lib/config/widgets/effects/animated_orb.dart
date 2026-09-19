import 'dart:ui' as ui;

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_orb.dart';
import 'package:floww/config/theme/app_orb_palette.dart';
import 'package:floww/config/utils/effects/orb_shader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AnimatedOrb extends StatefulWidget {
  const AnimatedOrb({
    super.key,
    required this.size,
    this.spin = AppOrb.spin,
    this.tilt = AppOrb.tilt,
    this.pulse = AppOrb.pulse,
    this.orbit = AppOrb.orbit,
    this.ringGlow = AppOrb.ringGlow,
    this.palette = AppOrbPalette.restore,
    this.animate = true,
  });

  final double size;
  final double spin;
  final double tilt;
  final double pulse;
  final double orbit;
  final double ringGlow;
  final AppOrbPalette palette;
  final bool animate;

  @override
  State<AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<AnimatedOrb>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  ui.FragmentShader? _shader;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _shader = OrbShader.create();
    if (_shader != null && widget.animate) _startClock();
  }

  @override
  void didUpdateWidget(covariant AnimatedOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate == oldWidget.animate) return;
    if (widget.animate) {
      _startClock();
    } else {
      _ticker?.stop();
    }
  }

  void _startClock() {
    _ticker ??= createTicker(_onTick);
    if (!_ticker!.isActive) _ticker!.start();
  }

  void _onTick(Duration elapsed) {
    setState(
      () => _time = elapsed.inMicroseconds / Duration.microsecondsPerSecond,
    );
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.size / AppOrb.textureAspect;
    final shader = _shader;
    final texture = OrbShader.texture;

    if (shader == null || texture == null) {
      return SizedBox(
        width: widget.size,
        height: height,
        child: const Image(
          image: AssetImage(AppImages.restoreOrb),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      );
    }

    return RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.size, height),
        painter: _OrbPainter(
          shader: shader,
          texture: texture,
          time: _time,
          spin: widget.spin,
          tilt: widget.tilt,
          pulse: widget.pulse,
          orbit: widget.orbit,
          ringGlow: widget.ringGlow,
          palette: widget.palette,
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.shader,
    required this.texture,
    required this.time,
    required this.spin,
    required this.tilt,
    required this.pulse,
    required this.orbit,
    required this.ringGlow,
    required this.palette,
  });

  final ui.FragmentShader shader;
  final ui.Image texture;
  final double time;
  final double spin;
  final double tilt;
  final double pulse;
  final double orbit;
  final double ringGlow;
  final AppOrbPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, AppOrb.center.dx)
      ..setFloat(4, AppOrb.center.dy)
      ..setFloat(5, AppOrb.coreRadius)
      ..setFloat(6, spin)
      ..setFloat(7, tilt)
      ..setFloat(8, pulse)
      ..setFloat(9, orbit)
      ..setFloat(10, ringGlow);

    _setColor(11, palette.dark);
    _setColor(14, palette.mid);
    _setColor(17, palette.hot);
    _setColor(20, palette.ring);

    shader.setImageSampler(0, texture);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  void _setColor(int index, Color color) {
    shader
      ..setFloat(index, color.r)
      ..setFloat(index + 1, color.g)
      ..setFloat(index + 2, color.b);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) =>
      oldDelegate.time != time ||
      oldDelegate.spin != spin ||
      oldDelegate.tilt != tilt ||
      oldDelegate.pulse != pulse ||
      oldDelegate.orbit != orbit ||
      oldDelegate.ringGlow != ringGlow ||
      oldDelegate.palette != palette;
}
