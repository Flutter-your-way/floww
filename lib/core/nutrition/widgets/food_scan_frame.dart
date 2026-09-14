import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class FoodScanFrame extends StatelessWidget {
  const FoodScanFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FoodScanFramePainter(color: context.colors.textPrimary),
    );
  }
}

class _FoodScanFramePainter extends CustomPainter {
  const _FoodScanFramePainter({required this.color});

  static const double _strokeWidth = 3;
  static const double _horizontalArm = AppSizes.s80;
  static const double _verticalArm = AppSizes.s60;
  static const double _cornerRadius = AppRadius.xl;
  static const Radius _arc = Radius.circular(_cornerRadius);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const left = _strokeWidth / 2;
    const top = _strokeWidth / 2;
    final right = size.width - _strokeWidth / 2;
    final bottom = size.height - _strokeWidth / 2;

    final path = Path()
      ..moveTo(left, top + _verticalArm)
      ..lineTo(left, top + _cornerRadius)
      ..arcToPoint(const Offset(left + _cornerRadius, top), radius: _arc)
      ..lineTo(left + _horizontalArm, top)
      ..moveTo(right - _horizontalArm, top)
      ..lineTo(right - _cornerRadius, top)
      ..arcToPoint(Offset(right, top + _cornerRadius), radius: _arc)
      ..lineTo(right, top + _verticalArm)
      ..moveTo(right, bottom - _verticalArm)
      ..lineTo(right, bottom - _cornerRadius)
      ..arcToPoint(Offset(right - _cornerRadius, bottom), radius: _arc)
      ..lineTo(right - _horizontalArm, bottom)
      ..moveTo(left + _horizontalArm, bottom)
      ..lineTo(left + _cornerRadius, bottom)
      ..arcToPoint(Offset(left, bottom - _cornerRadius), radius: _arc)
      ..lineTo(left, bottom - _verticalArm);

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_FoodScanFramePainter oldDelegate) =>
      oldDelegate.color != color;
}
