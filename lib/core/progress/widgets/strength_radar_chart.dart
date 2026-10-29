import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/progress/models/strength_view_data.dart';

class StrengthRadarChart extends StatelessWidget {
  const StrengthRadarChart({
    super.key,
    required this.axes,
    this.height = AppSizes.s160 * 2,
  });

  final List<StrengthRadarAxis> axes;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final values = [for (final axis in axes) axis.value];

    return SizedBox(
      height: height,
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: AppMotion.medium,
        curve: AppMotion.expandCurve,
        builder: (context, reveal, child) => CustomPaint(
          painter: StrengthRadarPainter(
            labels: [for (final axis in axes) axis.label],
            values: values,
            reveal: reveal,
            gridColor: colors.borderMedium,
            accent: colors.primary,
            fillOpacity: AppOpacity.tintBorder,
            labelStyle: AppTypography.bodyMediumMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class StrengthRadarPainter extends CustomPainter {
  const StrengthRadarPainter({
    required this.labels,
    required this.values,
    required this.reveal,
    required this.gridColor,
    required this.accent,
    required this.fillOpacity,
    required this.labelStyle,
  });

  static const int _rings = 5;
  static const double _labelGap = AppSpacing.lg;
  static const double _labelOverhang = 0.8;
  static const double _gridStroke = 1;
  static const double _lineStroke = 2;
  static const double _dotRadius = AppSizes.s4;
  static const double _centerRadius = AppSizes.s6;

  final List<String> labels;
  final List<double> values;
  final double reveal;
  final Color gridColor;
  final Color accent;
  final double fillOpacity;
  final TextStyle labelStyle;

  Offset _pointAt(Offset center, double radius, int index) {
    final angle = -math.pi / 2 + 2 * math.pi * index / labels.length;
    return center + Offset(math.cos(angle), math.sin(angle)) * radius;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (labels.length < 3) return;
    final center = size.center(Offset.zero);
    final painters = [
      for (final label in labels)
        TextPainter(
          text: TextSpan(text: label, style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];
    final widest = painters.fold<double>(
      0,
      (widest, painter) => math.max(widest, painter.width),
    );
    final tallest = painters.fold<double>(
      0,
      (tallest, painter) => math.max(tallest, painter.height),
    );
    final radius = math.max(
      0.0,
      math.min(
        size.width / 2 - _labelGap - widest * _labelOverhang,
        size.height / 2 - _labelGap - tallest,
      ),
    );

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _gridStroke
      ..color = gridColor;
    for (var ring = 1; ring <= _rings; ring++) {
      canvas.drawCircle(center, radius * ring / _rings, grid);
    }
    for (var index = 0; index < labels.length; index++) {
      canvas.drawLine(
        _pointAt(center, radius / _rings, index),
        _pointAt(center, radius, index),
        grid,
      );
    }

    final hasData = values.any((value) => value > 0);
    if (hasData) {
      final points = [
        for (var index = 0; index < values.length; index++)
          _pointAt(center, radius * values[index] * reveal, index),
      ];
      final shape = Path()..addPolygon(points, true);
      canvas.drawPath(
        shape,
        Paint()..color = accent.withValues(alpha: fillOpacity),
      );
      canvas.drawPath(
        shape,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _lineStroke
          ..strokeJoin = StrokeJoin.round
          ..color = accent,
      );
      final dot = Paint()..color = accent;
      for (final point in points) {
        canvas.drawCircle(point, _dotRadius, dot);
      }
    } else {
      canvas.drawCircle(center, _centerRadius, Paint()..color = accent);
      canvas.drawCircle(
        center,
        _centerRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _lineStroke
          ..color = labelStyle.color ?? accent,
      );
    }

    for (var index = 0; index < labels.length; index++) {
      final painter = painters[index];
      final anchor = _pointAt(center, radius + _labelGap, index);
      final dx = anchor.dx - center.dx;
      final dy = anchor.dy - center.dy;
      final x = dx.abs() < AppSpacing.xs
          ? anchor.dx - painter.width / 2
          : dx > 0
          ? anchor.dx - painter.width * (1 - _labelOverhang)
          : anchor.dx - painter.width * _labelOverhang;
      final y = dy < 0
          ? anchor.dy - painter.height
          : dy.abs() < radius / 2
          ? anchor.dy - painter.height / 2
          : anchor.dy;
      painter.paint(canvas, Offset(x, y));
      painter.dispose();
    }
  }

  @override
  bool shouldRepaint(StrengthRadarPainter oldDelegate) =>
      !listEquals(oldDelegate.values, values) ||
      !listEquals(oldDelegate.labels, labels) ||
      oldDelegate.reveal != reveal ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.accent != accent ||
      oldDelegate.labelStyle != labelStyle;
}
