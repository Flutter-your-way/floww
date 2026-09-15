import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.bars,
    required this.color,
    this.barAreaHeight = AppSizes.s96,
  });

  static const double badgeHeight = AppSizes.s6;
  static const double minBarHeight = AppSizes.s6;

  final List<ChartBar> bars;
  final Color color;
  final double barAreaHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxValue = bars.fold<double>(
      0,
      (current, bar) => math.max(current, bar.value),
    );
    final hasBadges = bars.any((bar) => bar.valueLabel != null);

    return Column(
      children: [
        SizedBox(
          height: hasBadges ? barAreaHeight + badgeHeight : barAreaHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final bar in bars)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                    child: CustomPaint(
                      painter: WeeklyBarPainter(
                        color: color,
                        barHeight: maxValue == 0
                            ? minBarHeight
                            : math.max(
                                barAreaHeight *
                                    (bar.value / maxValue).clamp(0.0, 1.0),
                                minBarHeight,
                              ),
                        badgeLabel: bar.valueLabel,
                        badgeBackground: colors.backgroundSecondary,
                        badgeStyle: context.textTheme.labelSmall!.copyWith(
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final bar in bars)
              Expanded(
                child: Text(
                  bar.label,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: bar.isHighlighted
                        ? colors.primary
                        : colors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class WeeklyBarPainter extends CustomPainter {
  const WeeklyBarPainter({
    required this.color,
    required this.barHeight,
    required this.badgeLabel,
    required this.badgeBackground,
    required this.badgeStyle,
  });

  final Color color;
  final double barHeight;
  final String? badgeLabel;
  final Color badgeBackground;
  final TextStyle badgeStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final barTop = size.height - barHeight;
    var barPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, barTop, size.width, barHeight),
          topLeft: const Radius.circular(AppRadius.sm),
          topRight: const Radius.circular(AppRadius.sm),
        ),
      );

    final label = badgeLabel;
    if (label == null) {
      canvas.drawPath(barPath, Paint()..color = color);
      return;
    }

    final textPainter = TextPainter(
      text: TextSpan(text: label, style: badgeStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    const badgeRadius = Radius.circular(AppRadius.full);
    final cutHeight = WeeklyBarChart.badgeHeight + AppSpacing.xs * 2;
    final notchesBar = barHeight > cutHeight;
    final badgeRect = Rect.fromCenter(
      center: Offset(
        size.width / 2,
        math.max(
          notchesBar ? barTop : barTop - cutHeight / 2,
          cutHeight / 2,
        ),
      ),
      width: textPainter.width + AppSpacing.md,
      height: WeeklyBarChart.badgeHeight,
    );

    if (notchesBar) {
      barPath = Path.combine(
        PathOperation.difference,
        barPath,
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              badgeRect.inflate(AppSpacing.xs),
              badgeRadius,
            ),
          ),
      );
    }

    canvas.drawPath(barPath, Paint()..color = color);
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, badgeRadius),
      Paint()..color = badgeBackground,
    );
    textPainter.paint(
      canvas,
      badgeRect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(WeeklyBarPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.barHeight != barHeight ||
      oldDelegate.badgeLabel != badgeLabel ||
      oldDelegate.badgeBackground != badgeBackground ||
      oldDelegate.badgeStyle != badgeStyle;
}
