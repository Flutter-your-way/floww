import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class AppProgressRing extends StatelessWidget {
  const AppProgressRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = AppSizes.s120,
    this.strokeWidth = AppSizes.s12,
    this.color,
    this.trackColor,
    this.gradient,
    this.glowColor,
    this.endColor,
    this.duration = AppMotion.medium,
  });

  final double progress;
  final Widget child;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;
  final Gradient? gradient;
  final Color? glowColor;
  final Color? endColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
          duration: duration,
          curve: AppMotion.expandCurve,
          builder: (context, value, child) => CustomPaint(
            painter: _RingPainter(
              progress: value,
              strokeWidth: strokeWidth,
              trackColor: trackColor ?? context.colors.backgroundElevated,
              color: color ?? context.colors.primary,
              gradient: gradient,
              glowColor: glowColor,
              endColor: endColor,
            ),
            child: child,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.color,
    this.gradient,
    this.glowColor,
    this.endColor,
  });

  static const double _start = -math.pi / 2;
  static const double _glowBlur = AppSizes.s8;
  static const double _glowAlpha = 0.45;
  static const double _glowTailFraction = 0.16;
  static const double _endRampLength = 0.16;
  static const double _endRampRelease = 0.02;
  static const double _fullIntensityProgress = 0.4;

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color color;
  final Gradient? gradient;
  final Color? glowColor;
  final Color? endColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = trackColor);
    if (progress <= 0) return;

    final sweep = math.pi * 2 * progress;
    final glowColor = this.glowColor;

    if (glowColor != null) {
      final tail = sweep * _glowTailFraction;
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = glowColor.withValues(alpha: _glowAlpha * _intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlur);
      canvas.drawArc(rect, _start + sweep - tail, tail, false, glow);
    }

    paint.color = color;
    paint.shader = gradient?.createShader(rect) ?? _endRampShader(rect);
    canvas.drawArc(rect, _start, sweep, false, paint);
  }

  double get _intensity => (progress / _fullIntensityProgress).clamp(0.0, 1.0);

  Shader? _endRampShader(Rect rect) {
    final endColor = this.endColor;
    if (endColor == null) return null;

    final tip = Color.lerp(color, endColor, _intensity)!;
    final hold = (strokeWidth / rect.width) / (2 * math.pi);
    final whiteStart = math.max(progress - hold, 0.0);
    final rampStart = math.max(whiteStart - _endRampLength, 0.0);
    final whiteEnd = math.min(progress + hold, 1.0);
    final release = math.min(whiteEnd + _endRampRelease, 1.0);

    return SweepGradient(
      colors: [color, color, tip, tip, color],
      stops: [0.0, rampStart, whiteStart, whiteEnd, release],
      transform: const GradientRotation(_start),
    ).createShader(rect);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.gradient != gradient ||
      oldDelegate.glowColor != glowColor ||
      oldDelegate.endColor != endColor ||
      oldDelegate.trackColor != trackColor;
}
