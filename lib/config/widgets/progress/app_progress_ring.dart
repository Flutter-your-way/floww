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
    this.trackColor,
    this.glowColor,
    this.duration = AppMotion.medium,
  });

  final double progress;
  final Widget child;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final Color? glowColor;
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
            painter: AppProgressRingPainter(
              progress: value,
              strokeWidth: strokeWidth,
              trackColor: trackColor ?? context.colors.backgroundElevated,
              gradients: context.gradients,
              glowColor: glowColor,
            ),
            child: child,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class AppProgressRingPainter extends CustomPainter {
  const AppProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.gradients,
    this.glowColor,
  });

  static const double _start = -math.pi / 2;
  static const double _glowBlur = AppSizes.s8;
  static const double _glowAlpha = 0.45;
  static const double _glowTailFraction = 0.16;
  static const double _fullIntensityProgress = 0.4;

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final AppGradientTokens gradients;
  final Color? glowColor;

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
      final intensity = (progress / _fullIntensityProgress).clamp(0.0, 1.0);
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = glowColor.withValues(alpha: _glowAlpha * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlur);
      canvas.drawArc(rect, _start + sweep - tail, tail, false, glow);
    }

    final tipHold = (strokeWidth / rect.width) / (2 * math.pi);
    paint
      ..color = trackColor.withValues(alpha: 1)
      ..shader = gradients
          .progressSweep(progress, tipHold: tipHold)
          .createShader(rect);
    canvas.drawArc(rect, _start, sweep, false, paint);
  }

  @override
  bool shouldRepaint(AppProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.gradients != gradients ||
      oldDelegate.glowColor != glowColor ||
      oldDelegate.trackColor != trackColor;
}
