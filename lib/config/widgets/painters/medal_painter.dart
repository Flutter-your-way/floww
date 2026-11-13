import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';

enum MedalShape { circle, hexagon, shield, rosette, star }

class MedalPainter extends CustomPainter {
  const MedalPainter({
    required this.shape,
    this.rimGradient,
    this.rimColor,
    this.face,
    this.highlight,
    this.glow,
    this.faceScale = _defaultFaceScale,
  });

  final MedalShape shape;
  final Gradient? rimGradient;
  final Color? rimColor;
  final Color? face;
  final Color? highlight;
  final Color? glow;
  final double faceScale;

  static const double _defaultFaceScale = 0.74;
  static const double _strokeRatio = 0.06;
  static const double _innerStrokeRatio = 0.025;
  static const double _glowBlurRatio = 0.12;
  static const int _hexSides = 6;
  static const int _rosetteLobes = 10;
  static const int _starPoints = 12;
  static const double _rosetteInner = 0.86;
  static const double _rosetteOuter = 1.12;
  static const double _starInner = 0.8;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final center = bounds.center;
    final stroke = size.shortestSide * _strokeRatio;
    final radius = size.shortestSide / 2 - stroke / 2;
    final outer = _shapeOf(center, radius);

    final glow = this.glow;
    if (glow != null) {
      canvas.drawPath(
        outer,
        Paint()
          ..color = glow.withValues(alpha: AppOpacity.buttonGlowStrong)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            size.shortestSide * _glowBlurRatio,
          ),
      );
    }

    Paint rimPaint() {
      final paint = Paint();
      final gradient = rimGradient;
      if (gradient != null) {
        paint.shader = gradient.createShader(bounds);
      } else {
        paint.color = rimColor ?? Colors.transparent;
      }
      return paint;
    }

    canvas.drawPath(outer, rimPaint());
    canvas.drawPath(
      outer,
      rimPaint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeJoin = StrokeJoin.round,
    );

    final face = this.face;
    if (face == null) return;

    final inner = _shapeOf(center, radius * faceScale);
    canvas.drawPath(
      inner,
      Paint()
        ..color = face
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(inner, Paint()..color = face);

    final highlight = this.highlight;
    if (highlight == null) return;

    canvas.drawPath(
      inner,
      Paint()
        ..color = highlight.withValues(alpha: AppOpacity.innerGlow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * _innerStrokeRatio
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Path _shapeOf(Offset center, double radius) => switch (shape) {
    MedalShape.circle =>
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    MedalShape.hexagon => _polygon(center, radius, _hexSides),
    MedalShape.shield => _shield(center, radius),
    MedalShape.rosette => _rosette(center, radius),
    MedalShape.star => _star(center, radius),
  };

  Offset _polar(Offset center, double radius, double angle) =>
      center + Offset(math.cos(angle), math.sin(angle)) * radius;

  double _angleOf(int index, int count) =>
      -math.pi / 2 + 2 * math.pi * index / count;

  Path _polygon(Offset center, double radius, int sides) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final point = _polar(center, radius, _angleOf(i, sides));
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  Path _shield(Offset center, double radius) {
    Offset at(double x, double y) => center + Offset(x, y) * radius;
    final top = at(0, -1);
    final topRight = at(0.86, -0.7);
    final midRight = at(0.86, 0.02);
    final curveRight = at(0.8, 0.66);
    final bottom = at(0, 1);
    final curveLeft = at(-0.8, 0.66);
    final midLeft = at(-0.86, 0.02);
    final topLeft = at(-0.86, -0.7);

    return Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(midRight.dx, midRight.dy)
      ..quadraticBezierTo(curveRight.dx, curveRight.dy, bottom.dx, bottom.dy)
      ..quadraticBezierTo(curveLeft.dx, curveLeft.dy, midLeft.dx, midLeft.dy)
      ..lineTo(topLeft.dx, topLeft.dy)
      ..close();
  }

  Path _rosette(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i <= _rosetteLobes; i++) {
      final point = _polar(
        center,
        radius * _rosetteInner,
        _angleOf(i, _rosetteLobes),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
        continue;
      }
      final control = _polar(
        center,
        radius * _rosetteOuter,
        _angleOf(i * 2 - 1, _rosetteLobes * 2),
      );
      path.quadraticBezierTo(control.dx, control.dy, point.dx, point.dy);
    }
    return path..close();
  }

  Path _star(Offset center, double radius) {
    final path = Path();
    final count = _starPoints * 2;
    for (var i = 0; i < count; i++) {
      final point = _polar(
        center,
        i.isEven ? radius : radius * _starInner,
        _angleOf(i, count),
      );
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(MedalPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.rimGradient != rimGradient ||
      oldDelegate.rimColor != rimColor ||
      oldDelegate.face != face ||
      oldDelegate.highlight != highlight ||
      oldDelegate.glow != glow ||
      oldDelegate.faceScale != faceScale;
}
