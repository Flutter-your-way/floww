import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class HeartRateChart extends StatelessWidget {
  const HeartRateChart({
    super.key,
    required this.samples,
    required this.axisLabels,
    this.plotHeight = AppSizes.s64,
  });

  final List<double> samples;
  final List<String> axisLabels;
  final double plotHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: plotHeight,
          child: CustomPaint(
            painter: HeartRateChartPainter(
              samples: samples,
              markerCount: axisLabels.length,
              lineColor: colors.primary,
              areaGradient: context.gradients.chartArea,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final label in axisLabels)
              Text(
                label,
                style: AppTypography.bodyXSmallRegular.copyWith(
                  color: colors.textQuiet,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class HeartRateChartPainter extends CustomPainter {
  const HeartRateChartPainter({
    required this.samples,
    required this.markerCount,
    required this.lineColor,
    required this.areaGradient,
  });

  static const double _strokeWidth = 2.07;
  static const double _dotRadius = 3.33;
  static const double _verticalInset = AppSizes.s4;

  final List<double> samples;
  final int markerCount;
  final Color lineColor;
  final Gradient areaGradient;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;

    final minValue = samples.reduce(math.min);
    final maxValue = samples.reduce(math.max);
    final span = maxValue - minValue;
    final usableHeight = size.height - _verticalInset * 2;
    final left = _dotRadius;
    final usableWidth = size.width - _dotRadius * 2;
    final stepX = usableWidth / (samples.length - 1);

    final points = <Offset>[
      for (var i = 0; i < samples.length; i++)
        Offset(
          left + stepX * i,
          span == 0
              ? size.height / 2
              : _verticalInset +
                    usableHeight * (1 - (samples[i] - minValue) / span),
        ),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()..shader = areaGradient.createShader(Offset.zero & size),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = lineColor,
    );

    if (markerCount < 2) return;
    final markerStep = (samples.length - 1) / (markerCount - 1);
    final dotPaint = Paint()..color = lineColor;
    for (var i = 0; i < markerCount; i++) {
      final index = (markerStep * i).round().clamp(0, points.length - 1);
      canvas.drawCircle(points[index], _dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(HeartRateChartPainter oldDelegate) =>
      oldDelegate.samples != samples ||
      oldDelegate.markerCount != markerCount ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.areaGradient != areaGradient;
}
