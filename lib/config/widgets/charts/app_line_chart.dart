import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/charts/app_line_chart_point_label.dart';

class AppLineChart extends StatefulWidget {
  const AppLineChart({
    super.key,
    required this.samples,
    required this.axisLabels,
    required this.dateLabels,
    required this.minValue,
    required this.maxValue,
    this.plotHeight = AppSizes.s160,
    this.showDots = true,
    this.pointLabels,
  });

  final List<double> samples;
  final List<String> axisLabels;
  final List<String> dateLabels;
  final double minValue;
  final double maxValue;
  final double plotHeight;
  final bool showDots;
  final List<AppLineChartPointLabel>? pointLabels;

  @override
  State<AppLineChart> createState() => _AppLineChartState();
}

class _AppLineChartState extends State<AppLineChart> {
  int? _selected;

  bool get _isInteractive {
    final labels = widget.pointLabels;
    return labels != null &&
        widget.samples.length > 1 &&
        labels.length == widget.samples.length;
  }

  void _select(double dx, double width) {
    final last = widget.samples.length - 1;
    final index = (dx / width * last).round().clamp(0, last);
    if (index == _selected) return;
    HapticManager.selection();
    setState(() => _selected = index);
  }

  void _clear() {
    if (_selected == null) return;
    setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = _isInteractive ? _selected : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.plotHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final label in widget.axisLabels)
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final chart = Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: AppLineChartPainter(
                              samples: widget.samples,
                              minValue: widget.minValue,
                              maxValue: widget.maxValue,
                              gridLineCount: widget.axisLabels.length,
                              columnCount: widget.dateLabels.length,
                              gridColor: colors.borderSubtle,
                              lineColor: colors.primaryAlt,
                              dotColor: colors.textPrimary,
                              guideColor: colors.textTertiary,
                              areaGradient: context.gradients.chartArea,
                              showDots: widget.showDots,
                              selectedIndex: selected,
                            ),
                          ),
                        ),
                        if (selected != null)
                          Align(
                            alignment: Alignment(
                              selected / (widget.samples.length - 1) * 2 - 1,
                              -1,
                            ),
                            child: AppLineChartTooltip(
                              label: widget.pointLabels![selected],
                            ),
                          ),
                      ],
                    );
                    if (!_isInteractive) return chart;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (details) =>
                          _select(details.localPosition.dx, width),
                      onHorizontalDragUpdate: (details) =>
                          _select(details.localPosition.dx, width),
                      onHorizontalDragEnd: (_) => _clear(),
                      onHorizontalDragCancel: _clear,
                      onLongPressStart: (details) =>
                          _select(details.localPosition.dx, width),
                      onLongPressMoveUpdate: (details) =>
                          _select(details.localPosition.dx, width),
                      onLongPressEnd: (_) => _clear(),
                      child: chart,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final label in widget.dateLabels)
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: AppTypography.captionMediumSmall.copyWith(
                      color: colors.textFaint,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class AppLineChartTooltip extends StatelessWidget {
  const AppLineChartTooltip({super.key, required this.label});

  final AppLineChartPointLabel label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.value,
            style: AppTypography.bodySmallBoldTight.copyWith(
              color: colors.textPrimary,
            ),
          ),
          Text(
            label.caption,
            style: AppTypography.captionMediumSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class AppLineChartPainter extends CustomPainter {
  const AppLineChartPainter({
    required this.samples,
    required this.minValue,
    required this.maxValue,
    required this.gridLineCount,
    required this.columnCount,
    required this.gridColor,
    required this.lineColor,
    required this.dotColor,
    required this.guideColor,
    required this.areaGradient,
    this.showDots = true,
    this.selectedIndex,
  });

  static const double _strokeWidth = 2;
  static const double _dotRadius = AppSizes.s4;
  static const double _selectedDotRadius = AppSizes.s6;
  static const double _dotStroke = 1;
  static const double _selectedDotStroke = 2;
  static const double _minDotSpacing = AppSizes.s16;

  final List<double> samples;
  final double minValue;
  final double maxValue;
  final int gridLineCount;
  final int columnCount;
  final Color gridColor;
  final Color lineColor;
  final Color dotColor;
  final Color guideColor;
  final Gradient areaGradient;
  final bool showDots;
  final int? selectedIndex;

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

    final selected = selectedIndex;
    if (showDots) {
      final dots = stepX < _minDotSpacing
          ? [if (selected == null) points.last]
          : points;
      for (final point in dots) {
        canvas.drawCircle(point, _dotRadius, fillPaint);
        canvas.drawCircle(point, _dotRadius, borderPaint);
      }
    }

    if (selected == null || selected < 0 || selected >= points.length) return;
    final point = points[selected];
    canvas.drawLine(
      Offset(point.dx, 0),
      Offset(point.dx, size.height),
      Paint()
        ..color = guideColor
        ..strokeWidth = _dotStroke,
    );
    canvas.drawCircle(point, _selectedDotRadius, fillPaint);
    canvas.drawCircle(
      point,
      _selectedDotRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _selectedDotStroke
        ..color = lineColor,
    );
  }

  @override
  bool shouldRepaint(AppLineChartPainter oldDelegate) =>
      oldDelegate.samples != samples ||
      oldDelegate.minValue != minValue ||
      oldDelegate.maxValue != maxValue ||
      oldDelegate.gridLineCount != gridLineCount ||
      oldDelegate.columnCount != columnCount ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.dotColor != dotColor ||
      oldDelegate.guideColor != guideColor ||
      oldDelegate.areaGradient != areaGradient ||
      oldDelegate.showDots != showDots ||
      oldDelegate.selectedIndex != selectedIndex;
}
