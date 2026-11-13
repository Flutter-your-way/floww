import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/effects/dashed_border.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/flame_painter.dart';

extension WorkoutDayMarkLabel on WorkoutDayMark {
  String get label => switch (this) {
    WorkoutDayMark.completed => 'Done',
    WorkoutDayMark.partial => 'Unfinished',
    WorkoutDayMark.missed => 'Missed',
    WorkoutDayMark.rest => 'Rest',
    WorkoutDayMark.planned => 'Planned',
  };
}

class WorkoutDayMarker extends StatelessWidget {
  const WorkoutDayMarker({
    super.key,
    required this.mark,
    this.label,
    this.isToday = false,
    this.size = AppSizes.s28,
  });

  final WorkoutDayMark mark;
  final String? label;
  final bool isToday;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = this.label;
    if (mark == WorkoutDayMark.completed) {
      return _FireDayMarker(label: label, isToday: isToday, size: size);
    }
    final (fill, border, foreground) = switch (mark) {
      WorkoutDayMark.completed => (
        colors.primary,
        colors.primary,
        colors.backgroundPrimary,
      ),
      WorkoutDayMark.missed => (
        colors.destructiveTint,
        colors.destructiveBorder,
        colors.destructiveBorder,
      ),
      WorkoutDayMark.partial => (
        colors.tint,
        colors.borderAccent,
        colors.primaryAlt,
      ),
      WorkoutDayMark.planned => (
        colors.tint,
        label == null ? colors.borderAccent : Colors.transparent,
        colors.primaryAlt,
      ),
      WorkoutDayMark.rest => (
        Colors.transparent,
        colors.borderSubtle,
        colors.textMuted,
      ),
    };
    final isMissed = mark == WorkoutDayMark.missed;
    final isPlanned =
        mark == WorkoutDayMark.planned && !isToday && label != null;

    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(
          color: isToday ? colors.textPrimary : border,
          width: isToday ? AppSizes.s2 : AppSizes.s1,
        ),
        boxShadow: isMissed && label != null
            ? [
                BoxShadow(
                  color: colors.destructive.withValues(
                    alpha: AppOpacity.buttonGlowStrong,
                  ),
                  blurRadius: AppSizes.s8,
                ),
              ]
            : null,
      ),
      child: label == null
          ? null
          : Text(
              label,
              style: AppTypography.captionSemiBold.copyWith(color: foreground),
            ),
    );

    if (!isPlanned) return circle;
    return DashedBorder(
      color: colors.borderAccent,
      radius: size / 2,
      dashLength: AppSizes.s4,
      gapLength: AppSizes.s3,
      child: circle,
    );
  }
}

class _FireDayMarker extends StatefulWidget {
  const _FireDayMarker({this.label, required this.isToday, required this.size});

  final String? label;
  final bool isToday;
  final double size;

  @override
  State<_FireDayMarker> createState() => _FireDayMarkerState();
}

class _FireDayMarkerState extends State<_FireDayMarker>
    with SingleTickerProviderStateMixin {
  static const double _flameWidthRatio = 0.84;
  static const double _flameHeightRatio = 1.0;
  static const double _flameLift = 0.17;
  static const double _todayDotRatio = 0.16;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.dayFireGlow,
  )..repeat(reverse: true);
  late final Animation<double> _glow = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.dayFireGlowCurve,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradients = context.gradients;
    final size = widget.size;
    final flameWidth = size * _flameWidthRatio;
    final flameHeight = size * _flameHeightRatio;
    final dotSize = size * _todayDotRatio;

    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            OverflowBox(
              minWidth: flameWidth,
              minHeight: flameHeight,
              maxWidth: flameWidth,
              maxHeight: flameHeight,
              child: Transform.translate(
                offset: Offset(
                  0,
                  widget.label == null ? 0 : -flameHeight * _flameLift,
                ),
                child: SizedBox(
                  width: flameWidth,
                  height: flameHeight,
                  child: AnimatedBuilder(
                    animation: _glow,
                    builder: (context, child) {
                      final t = _glow.value;
                      return CustomPaint(
                        painter: FlamePainter(
                          outerGradient: gradients.dayFire,
                          middleGradient: gradients.dayFireMiddle,
                          coreGradient: gradients.dayFireCore,
                          glowColor: colors.destructive.withValues(
                            alpha: lerpDouble(
                              AppOpacity.dayFireGlowMin,
                              AppOpacity.dayFireGlowMax,
                              t,
                            ),
                          ),
                          glowBlur: lerpDouble(AppSizes.s4, AppSizes.s10, t)!,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (widget.label case final label?)
              Text(
                label,
                style: AppTypography.captionSemiBold.copyWith(
                  color: colors.backgroundPrimary,
                ),
              ),
            if (widget.isToday)
              Positioned(
                bottom: -dotSize * 2,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: colors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
