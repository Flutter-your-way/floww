import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class WeightLineChart extends StatelessWidget {
  const WeightLineChart({
    super.key,
    required this.samples,
    required this.axisLabels,
    required this.dateLabels,
    required this.minValue,
    required this.maxValue,
    this.plotHeight = AppSizes.s160,
  });

  final List<double> samples;
  final List<String> axisLabels;
  final List<String> dateLabels;
  final double minValue;
  final double maxValue;
  final double plotHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: plotHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final label in axisLabels)
                    Text(
                      label,
                      style: AppTypography.captionMediumSmall.copyWith(
                        color: colors.textFaint,
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomPaint(
                  painter: WeightLineChartPainter(
                    samples: samples,
                    minValue: minValue,
                    maxValue: maxValue,
                    gridLineCount: axisLabels.length,
                    columnCount: dateLabels.length,
                    gridColor: colors.borderSubtle,
                    lineColor: colors.primaryAlt,
                    dotColor: colors.textPrimary,
                    areaGradient: context.gradients.chartArea,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final label in dateLabels)
              Text(
                label,
                style: AppTypography.captionMediumSmall.copyWith(
                  color: colors.textFaint,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class WeightLineChartPainter extends CustomPainter {
  const WeightLineChartPainter({
    required this.samples,
    required this.minValue,
    required this.maxValue,
    required this.gridLineCount,
    required this.columnCount,
    required this.gridColor,
    required this.lineColor,
    required this.dotColor,
    required this.areaGradient,
  });

  static const double _strokeWidth = 2;
  static const double _dotRadius = AppSizes.s4;
  static const double _dotStroke = 1;

  final List<double> samples;
  final double minValue;
  final double maxValue;
  final int gridLineCount;
  final int columnCount;
  final Color gridColor;
  final Color lineColor;
  final Color dotColor;
  final Gradient areaGradient;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = _dotStroke;

    if (gridLineCount > 1) {
      final rowStep = size.height / (gridLineCount - 1);
      for (var index = 0; index < gridLineCount; index++) {
        final dy = rowStep * index;
        canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
      }
    }

    if (columnCount > 1) {
      final columnStep = size.width / (columnCount - 1);
      for (var index = 0; index < columnCount; index++) {
        final dx = columnStep * index;
        canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
      }
    }

    final span = maxValue - minValue;
    final stepX = size.width / (samples.length - 1);
    final points = <Offset>[
      for (var index = 0; index < samples.length; index++)
        Offset(
          stepX * index,
          span == 0
              ? size.height / 2
              : size.height * (1 - (samples[index] - minValue) / span),
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

    final fillPaint = Paint()..color = dotColor;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _dotStroke
      ..color = lineColor;
    for (final point in points) {
      canvas.drawCircle(point, _dotRadius, fillPaint);
      canvas.drawCircle(point, _dotRadius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(WeightLineChartPainter oldDelegate) =>
      oldDelegate.samples != samples ||
      oldDelegate.minValue != minValue ||
      oldDelegate.maxValue != maxValue ||
      oldDelegate.gridLineCount != gridLineCount ||
      oldDelegate.columnCount != columnCount ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.dotColor != dotColor ||
      oldDelegate.areaGradient != areaGradient;
}
