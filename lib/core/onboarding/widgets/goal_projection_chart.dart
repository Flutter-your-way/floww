import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class GoalChartFrame {
  const GoalChartFrame({
    required this.samples,
    required this.axisMin,
    required this.axisMax,
    this.bandMin,
    this.bandMax,
  });

  final List<double> samples;
  final double axisMin;
  final double axisMax;
  final double? bandMin;
  final double? bandMax;

  static GoalChartFrame lerp(GoalChartFrame a, GoalChartFrame b, double t) {
    final samples = a.samples.length == b.samples.length
        ? [
            for (var i = 0; i < b.samples.length; i++)
              ui.lerpDouble(a.samples[i], b.samples[i], t)!,
          ]
        : b.samples;
    return GoalChartFrame(
      samples: samples,
      axisMin: ui.lerpDouble(a.axisMin, b.axisMin, t)!,
      axisMax: ui.lerpDouble(a.axisMax, b.axisMax, t)!,
      bandMin: ui.lerpDouble(a.bandMin, b.bandMin, t),
      bandMax: ui.lerpDouble(a.bandMax, b.bandMax, t),
    );
  }

  double fractionOf(double value) {
    final span = axisMax - axisMin;
    if (span == 0) return 0.5;
    return 1 - (value - axisMin) / span;
  }
}

class _GoalChartFrameTween extends Tween<GoalChartFrame> {
  _GoalChartFrameTween({required GoalChartFrame end}) : super(end: end);

  @override
  GoalChartFrame lerp(double t) => GoalChartFrame.lerp(begin!, end!, t);
}

class GoalProjectionChart extends StatefulWidget {
  const GoalProjectionChart({
    super.key,
    required this.frame,
    required this.startLabel,
    required this.endLabel,
    required this.startCaption,
    required this.endCaption,
    this.plotHeight = AppSizes.s160,
  });

  static const double plotInset = AppSizes.s12;

  final GoalChartFrame frame;
  final String startLabel;
  final String endLabel;
  final String startCaption;
  final String endCaption;
  final double plotHeight;

  @override
  State<GoalProjectionChart> createState() => _GoalProjectionChartState();
}

class _GoalProjectionChartState extends State<GoalProjectionChart>
    with TickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: AppMotion.goalChartReveal,
  )..forward();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppMotion.goalDotPulse,
  )..repeat();

  late final Animation<double> _drawn = CurvedAnimation(
    parent: _reveal,
    curve: AppMotion.goalChartCurve,
  );

  late final Animation<double> _bubbles = CurvedAnimation(
    parent: _reveal,
    curve: AppMotion.goalChartBubbleIn,
  );

  @override
  void dispose() {
    _reveal.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.plotHeight,
          child: TweenAnimationBuilder<GoalChartFrame>(
            tween: _GoalChartFrameTween(end: widget.frame),
            duration: AppMotion.goalChartMorph,
            curve: AppMotion.expandCurve,
            builder: (context, frame, _) => LayoutBuilder(
              builder: (context, constraints) {
                final plotSpan =
                    constraints.maxHeight - GoalProjectionChart.plotInset * 2;
                double yOf(double value) =>
                    GoalProjectionChart.plotInset +
                    plotSpan * frame.fractionOf(value);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: GoalProjectionChartPainter(
                            frame: frame,
                            drawn: _drawn,
                            pulse: _pulse,
                            inset: GoalProjectionChart.plotInset,
                            lineColor: colors.primary,
                            startDotColor: colors.textPrimary,
                            gridColor: colors.borderSubtle,
                            bandColor: colors.tint,
                            bandEdgeColor: colors.borderGlow,
                            areaGradient: context.gradients.chartArea,
                          ),
                        ),
                      ),
                    ),
                    _GoalChartBubble(
                      label: widget.startLabel,
                      pointY: yOf(frame.samples.first),
                      height: constraints.maxHeight,
                      alignStart: true,
                      opacity: _bubbles,
                      highlighted: false,
                    ),
                    _GoalChartBubble(
                      label: widget.endLabel,
                      pointY: yOf(frame.samples.last),
                      height: constraints.maxHeight,
                      alignStart: false,
                      opacity: _bubbles,
                      highlighted: true,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.startCaption,
              style: AppTypography.bodySmallMedium.copyWith(
                color: colors.textQuiet,
              ),
            ),
            Text(
              widget.endCaption,
              style: AppTypography.bodySmallMedium.copyWith(
                color: colors.textQuiet,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoalChartBubble extends StatelessWidget {
  const _GoalChartBubble({
    required this.label,
    required this.pointY,
    required this.height,
    required this.alignStart,
    required this.opacity,
    required this.highlighted,
  });

  static const double _gap = AppSizes.s10;

  final String label;
  final double pointY;
  final double height;
  final bool alignStart;
  final Animation<double> opacity;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final below = pointY < height / 2;

    return Positioned(
      left: alignStart ? 0 : null,
      right: alignStart ? null : 0,
      top: below ? pointY + _gap : null,
      bottom: below ? null : height - pointY + _gap,
      child: FadeTransition(
        opacity: opacity,
        child: AnimatedContainer(
          duration: AppMotion.expand,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: AppShapes.decoration(
            color: highlighted ? colors.primary : colors.backgroundElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            label,
            style: AppTypography.bodySmallSemiBold.copyWith(
              color: highlighted ? colors.onBrandLight : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class GoalProjectionChartPainter extends CustomPainter {
  GoalProjectionChartPainter({
    required this.frame,
    required this.drawn,
    required this.pulse,
    required this.inset,
    required this.lineColor,
    required this.startDotColor,
    required this.gridColor,
    required this.bandColor,
    required this.bandEdgeColor,
    required this.areaGradient,
  }) : super(repaint: Listenable.merge([drawn, pulse]));

  static const double _strokeWidth = 3;
  static const double _dotRadius = AppSizes.s6;
  static const double _haloSpread = AppSizes.s14;
  static const double _haloOpacity = 0.45;
  static const int _gridLines = 4;

  final GoalChartFrame frame;
  final Animation<double> drawn;
  final Animation<double> pulse;
  final double inset;
  final Color lineColor;
  final Color startDotColor;
  final Color gridColor;
  final Color bandColor;
  final Color bandEdgeColor;
  final Gradient areaGradient;

  @override
  void paint(Canvas canvas, Size size) {
    final samples = frame.samples;
    if (samples.length < 2) return;

    final span = size.height - inset * 2;
    double yOf(double value) => inset + span * frame.fractionOf(value);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = AppSizes.s1;
    for (var i = 0; i < _gridLines; i++) {
      final dy = inset + span * i / (_gridLines - 1);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final bandMin = frame.bandMin;
    final bandMax = frame.bandMax;
    if (bandMin != null && bandMax != null) {
      final top = yOf(bandMax);
      final bottom = yOf(bandMin);
      canvas.drawRect(
        Rect.fromLTRB(0, top, size.width, bottom),
        Paint()..color = bandColor,
      );
      final edgePaint = Paint()
        ..color = bandEdgeColor
        ..strokeWidth = AppSizes.s1;
      canvas.drawLine(Offset(0, top), Offset(size.width, top), edgePaint);
      canvas.drawLine(Offset(0, bottom), Offset(size.width, bottom), edgePaint);
    }

    final stepX = size.width / (samples.length - 1);
    final points = [
      for (var i = 0; i < samples.length; i++)
        Offset(stepX * i, yOf(samples[i])),
    ];

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final midX = (previous.dx + current.dx) / 2;
      line.cubicTo(midX, previous.dy, midX, current.dy, current.dx, current.dy);
    }

    final area = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final progress = drawn.value;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));
    canvas.drawPath(
      area,
      Paint()..shader = areaGradient.createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = lineColor,
    );
    canvas.restore();

    canvas.drawCircle(points.first, _dotRadius, Paint()..color = startDotColor);
    canvas.drawCircle(
      points.first,
      _dotRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..color = lineColor,
    );

    if (progress < 1) return;
    final wave = pulse.value;
    canvas.drawCircle(
      points.last,
      _dotRadius + _haloSpread * wave,
      Paint()..color = lineColor.withValues(alpha: _haloOpacity * (1 - wave)),
    );
    canvas.drawCircle(points.last, _dotRadius, Paint()..color = lineColor);
    canvas.drawCircle(
      points.last,
      _dotRadius / 2,
      Paint()..color = startDotColor,
    );
  }

  @override
  bool shouldRepaint(GoalProjectionChartPainter oldDelegate) =>
      oldDelegate.frame != frame ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.startDotColor != startDotColor ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.bandColor != bandColor ||
      oldDelegate.bandEdgeColor != bandEdgeColor ||
      oldDelegate.areaGradient != areaGradient;
}
