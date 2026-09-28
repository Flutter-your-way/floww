import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';

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
    final (fill, border, foreground) = switch (mark) {
      WorkoutDayMark.completed => (
        colors.primary,
        colors.primary,
        colors.backgroundPrimary,
      ),
      WorkoutDayMark.missed => (
        colors.destructiveTint,
        colors.destructiveOutline,
        colors.destructiveBorder,
      ),
      WorkoutDayMark.partial => (
        Colors.transparent,
        colors.borderAccent,
        colors.primaryAlt,
      ),
      WorkoutDayMark.planned => (
        Colors.transparent,
        colors.borderMedium,
        colors.textSecondary,
      ),
      WorkoutDayMark.rest => (
        colors.backgroundSurface,
        colors.backgroundSurface,
        colors.textDim,
      ),
    };

    return Container(
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
      ),
      child: label == null
          ? null
          : Text(
              label,
              style: AppTypography.captionSemiBold.copyWith(color: foreground),
            ),
    );
  }
}
