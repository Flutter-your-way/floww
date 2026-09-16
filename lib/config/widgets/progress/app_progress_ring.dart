import 'dart:math' as math;

import 'package:flutter/material.dart';
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
  });

  final double progress;
  final Widget child;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          trackColor: trackColor ?? context.colors.backgroundElevated,
          color: color ?? context.colors.primary,
          gradient: gradient,
        ),
        child: Center(child: child),
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
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color color;
  final Gradient? gradient;

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
    if (progress > 0) {
      final gradient = this.gradient;
      paint.color = color;
      paint.shader = gradient?.createShader(rect);
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.gradient != gradient ||
      oldDelegate.trackColor != trackColor;
}
