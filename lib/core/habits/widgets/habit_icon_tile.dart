import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/widgets/habit_icon.dart';

class HabitIconTile extends StatelessWidget {
  const HabitIconTile({super.key, required this.icon});

  final HabitIconKind icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: AppSizes.s48,
      height: AppSizes.s48,
      alignment: Alignment.center,
      decoration: AppShapes.decoration(
        color: colors.bgTinted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
      ),
      child: HabitIcon(kind: icon, size: AppSizes.s24, color: colors.primary),
    );
  }
}
