import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';

class InnerGlow extends StatelessWidget {
  const InnerGlow({
    super.key,
    required this.color,
    required this.radius,
    this.blur = AppSizes.s8,
  });

  final Color color;
  final double radius;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        isComplex: true,
        willChange: false,
        painter: _InnerGlowPainter(color: color, radius: radius, blur: blur),
      ),
    );
  }
}

class _InnerGlowPainter extends CustomPainter {
  const _InnerGlowPainter({
    required this.color,
    required this.radius,
    required this.blur,
  });

  static const double _sigmaFactor = 3;
  static const double _strokeFactor = 1;

  final Color color;
  final double radius;
  final double blur;

  @override
  void paint(Canvas canvas, Size size) {
    final path = AppShapes.border(
      borderRadius: BorderRadius.circular(radius),
    ).getOuterPath(Offset.zero & size);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = blur * _strokeFactor
      ..color = color
      ..maskFilter = ui.MaskFilter.blur(
        ui.BlurStyle.normal,
        blur / _sigmaFactor,
      );

    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InnerGlowPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.blur != blur;
}
