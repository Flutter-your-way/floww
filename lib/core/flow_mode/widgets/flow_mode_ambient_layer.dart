import 'dart:math' as math;

import 'package:floww/config/theme/app_mode_intensity.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

class FlowModeAmbientLayer extends StatefulWidget {
  const FlowModeAmbientLayer({super.key});

  @override
  State<FlowModeAmbientLayer> createState() => _FlowModeAmbientLayerState();
}

class _FlowModeAmbientLayerState extends State<FlowModeAmbientLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppModeIntensity.flow.ambientDriftPeriod,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncMotion(AppModeIntensity intensity, bool reducedMotion) {
    if (reducedMotion) {
      if (_controller.isAnimating) _controller.stop();
      return;
    }

    if (_controller.duration != intensity.ambientDriftPeriod) {
      _controller.duration = intensity.ambientDriftPeriod;
      _controller.repeat();
      return;
    }

    if (!_controller.isAnimating) _controller.repeat();
  }

  static const double _repaintsPerSecond = 15;

  double _quantizedPhase(AppModeIntensity intensity) {
    final steps =
        (intensity.ambientDriftPeriod.inMilliseconds *
                _repaintsPerSecond /
                1000)
            .round()
            .clamp(1, 1000);
    return (_controller.value * steps).floorToDouble() / steps;
  }

  @override
  Widget build(BuildContext context) {
    final intensity = context.intensity;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    _syncMotion(intensity, reducedMotion);

    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            isComplex: true,
            painter: _AmbientPainter(
              phase: _quantizedPhase(intensity),
              primary: context.colors.primary,
              deep: context.colors.primaryDeep,
              opacity: intensity.ambientOpacity,
              radiusFactor: intensity.ambientRadiusFactor,
              glow: intensity.glowStrength,
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({
    required this.phase,
    required this.primary,
    required this.deep,
    required this.opacity,
    required this.radiusFactor,
    required this.glow,
  });

  static const double _driftX = 0.16;
  static const double _driftY = 0.1;
  static const double _topAnchor = 0.18;
  static const double _bottomAnchor = 0.86;

  final double phase;
  final Color primary;
  final Color deep;
  final double opacity;
  final double radiusFactor;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final angle = phase * 2 * math.pi;
    final radius = size.shortestSide * radiusFactor;

    _paintBloom(
      canvas,
      Offset(
        size.width * (0.5 + math.cos(angle) * _driftX),
        size.height * (_topAnchor + math.sin(angle) * _driftY),
      ),
      radius,
      primary,
      opacity * glow,
    );

    _paintBloom(
      canvas,
      Offset(
        size.width * (0.5 - math.sin(angle) * _driftX),
        size.height * (_bottomAnchor - math.cos(angle) * _driftY),
      ),
      radius * 0.78,
      deep,
      opacity * glow * 0.7,
    );
  }

  void _paintBloom(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double alpha,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha.clamp(0.0, 1.0)),
            color.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.primary != primary ||
      oldDelegate.deep != deep ||
      oldDelegate.opacity != opacity ||
      oldDelegate.radiusFactor != radiusFactor ||
      oldDelegate.glow != glow;
}
