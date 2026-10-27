import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class GuideConnector extends StatelessWidget {
  const GuideConnector({
    super.key,
    required this.length,
    required this.pointsUp,
    required this.visible,
    required this.flow,
  });

  static const double width = AppSizes.s16;

  final double length;
  final bool pointsUp;
  final bool visible;
  final Animation<double> flow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: visible ? 1 : 0),
        duration: AppMotion.guideConnectorDraw,
        curve: AppMotion.guideConnectorCurve,
        builder: (context, progress, child) => CustomPaint(
          size: Size(width, length),
          painter: _GuideConnectorPainter(
            color: colors.primary,
            spark: colors.textPrimary,
            pointsUp: pointsUp,
            progress: progress,
            flow: flow,
          ),
        ),
      ),
    );
  }
}

class _GuideConnectorPainter extends CustomPainter {
  _GuideConnectorPainter({
    required this.color,
    required this.spark,
    required this.pointsUp,
    required this.progress,
    required this.flow,
  }) : super(repaint: flow);

  static const double _nodeRadius = AppSizes.s6;
  static const double _coreRadius = AppSizes.s2;
  static const double _socketRadius = AppSizes.s2;
  static const double _sparkRadius = AppSizes.s2;
  static const double _lineWidth = AppSizes.s2;
  static const double _glowWidth = AppSizes.s6;
  static const double _glowBlur = AppSizes.s4;
  static const double _ringWidth = 1.5;

  final Color color;
  final Color spark;
  final bool pointsUp;
  final double progress;
  final Animation<double> flow;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || size.height <= 0) return;
    final x = size.width / 2;
    final startY = pointsUp ? 0.0 : size.height;
    final endY = pointsUp ? size.height : 0.0;
    final start = Offset(x, startY);
    final reach = Offset(x, startY + (endY - startY) * progress);

    canvas.drawLine(
      start,
      reach,
      Paint()
        ..color = color.withValues(alpha: AppOpacity.guideHalo * progress)
        ..strokeWidth = _glowWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlur),
    );
    canvas.drawLine(
      start,
      reach,
      Paint()
        ..shader = ui.Gradient.linear(start, Offset(x, endY), [
          color,
          color.withValues(alpha: AppOpacity.guideConnectorTail),
        ])
        ..strokeWidth = _lineWidth
        ..strokeCap = StrokeCap.round,
    );

    _paintNode(canvas, start);
    if (progress >= 1) {
      _paintSocket(canvas, Offset(x, endY));
      _paintSpark(canvas, start, Offset(x, endY));
    }
  }

  void _paintNode(Canvas canvas, Offset center) {
    final radius = _nodeRadius * progress;
    canvas.drawCircle(
      center,
      radius * 1.6,
      Paint()
        ..color = color.withValues(alpha: AppOpacity.guideHalo * progress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlur),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringWidth
        ..color = color,
    );
    canvas.drawCircle(
      center,
      _coreRadius * 1.5 * progress,
      Paint()..color = color,
    );
  }

  void _paintSocket(Canvas canvas, Offset center) {
    canvas.drawCircle(
      center,
      _socketRadius * 3,
      Paint()
        ..color = color.withValues(alpha: AppOpacity.guideHalo)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlur),
    );
    canvas.drawCircle(center, _socketRadius, Paint()..color = color);
  }

  void _paintSpark(Canvas canvas, Offset from, Offset to) {
    final t = flow.value;
    final center = Offset.lerp(from, to, t)!;
    final fade = math.sin(math.pi * t);
    canvas.drawCircle(
      center,
      _sparkRadius * 3,
      Paint()
        ..color = color.withValues(alpha: AppOpacity.guideHalo * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlur),
    );
    canvas.drawCircle(
      center,
      _sparkRadius,
      Paint()..color = spark.withValues(alpha: fade),
    );
  }

  @override
  bool shouldRepaint(_GuideConnectorPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.spark != spark ||
      oldDelegate.pointsUp != pointsUp ||
      oldDelegate.progress != progress;
}
