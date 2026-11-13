import 'package:flutter/material.dart';

class FlamePainter extends CustomPainter {
  const FlamePainter({
    required this.outerGradient,
    required this.middleGradient,
    required this.coreGradient,
    required this.glowColor,
    required this.glowBlur,
  });

  final Gradient outerGradient;
  final Gradient middleGradient;
  final Gradient coreGradient;
  final Color glowColor;
  final double glowBlur;

  static const Rect _middleBounds = Rect.fromLTWH(0.17, 0.4, 0.66, 0.6);
  static const Rect _coreBounds = Rect.fromLTWH(0.32, 0.62, 0.36, 0.34);
  static const double _innerTipX = 0.56;

  static Path _outerPath(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.5, h)
      ..cubicTo(w * 0.2, h, 0, h * 0.82, w * 0.02, h * 0.6)
      ..cubicTo(w * 0.03, h * 0.5, w * 0.08, h * 0.42, w * 0.14, h * 0.35)
      ..cubicTo(w * 0.16, h * 0.43, w * 0.2, h * 0.49, w * 0.27, h * 0.52)
      ..cubicTo(w * 0.22, h * 0.3, w * 0.38, h * 0.12, w * 0.64, 0)
      ..cubicTo(w * 0.56, h * 0.18, w * 0.6, h * 0.32, w * 0.74, h * 0.44)
      ..cubicTo(w * 0.8, h * 0.41, w * 0.86, h * 0.36, w * 0.9, h * 0.29)
      ..cubicTo(w * 0.98, h * 0.42, w * 1.02, h * 0.56, w * 0.98, h * 0.68)
      ..cubicTo(w * 0.94, h * 0.88, w * 0.76, h, w * 0.5, h)
      ..close();
  }

  static Path _innerPath(Rect rect) {
    final x = rect.left;
    final y = rect.top;
    final w = rect.width;
    final h = rect.height;
    final tip = x + w * _innerTipX;
    return Path()
      ..moveTo(tip, y)
      ..cubicTo(
        tip + w * 0.04,
        y + h * 0.22,
        x + w,
        y + h * 0.36,
        x + w,
        y + h * 0.64,
      )
      ..cubicTo(x + w, y + h * 0.86, x + w * 0.78, y + h, x + w * 0.5, y + h)
      ..cubicTo(x + w * 0.22, y + h, x, y + h * 0.86, x, y + h * 0.64)
      ..cubicTo(x, y + h * 0.4, x + w * 0.3, y + h * 0.3, tip, y)
      ..close();
  }

  static Rect _scaled(Rect unit, Size size) => Rect.fromLTWH(
    unit.left * size.width,
    unit.top * size.height,
    unit.width * size.width,
    unit.height * size.height,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final outer = _outerPath(size);
    final middleRect = _scaled(_middleBounds, size);
    final coreRect = _scaled(_coreBounds, size);
    canvas.drawPath(
      outer,
      Paint()
        ..color = glowColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur),
    );
    canvas.drawPath(
      outer,
      Paint()..shader = outerGradient.createShader(bounds),
    );
    canvas.drawPath(
      _innerPath(middleRect),
      Paint()..shader = middleGradient.createShader(middleRect),
    );
    canvas.drawPath(
      _innerPath(coreRect),
      Paint()..shader = coreGradient.createShader(coreRect),
    );
  }

  @override
  bool shouldRepaint(FlamePainter oldDelegate) =>
      oldDelegate.outerGradient != outerGradient ||
      oldDelegate.middleGradient != middleGradient ||
      oldDelegate.coreGradient != coreGradient ||
      oldDelegate.glowColor != glowColor ||
      oldDelegate.glowBlur != glowBlur;
}
