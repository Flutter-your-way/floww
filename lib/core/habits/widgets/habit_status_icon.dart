import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/progress/app_progress_ring.dart';
import 'package:floww/core/habits/models/habit_day.dart';

class HabitStatusIcon extends StatelessWidget {
  const HabitStatusIcon({
    super.key,
    required this.status,
    required this.progress,
    this.size = AppSizes.s18,
    this.strokeWidth = AppSizes.s2,
  });

  final HabitDayStatus status;
  final double progress;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    switch (status) {
      case HabitDayStatus.completed:
        return Icon(
          Icons.check_circle_rounded,
          size: size,
          color: colors.primaryDeep,
        );
      case HabitDayStatus.missed:
        return Icon(
          Icons.cancel_rounded,
          size: size,
          color: colors.destructive,
        );
      case HabitDayStatus.upcoming:
        return Icon(
          Icons.circle_rounded,
          size: size,
          color: colors.borderSubtle,
        );
      case HabitDayStatus.partial:
        return AppProgressRing(
          progress: progress,
          size: size,
          strokeWidth: strokeWidth,
          color: colors.primaryDeep,
          trackColor: colors.borderSubtle,
          child: const SizedBox.shrink(),
        );
    }
  }
}
