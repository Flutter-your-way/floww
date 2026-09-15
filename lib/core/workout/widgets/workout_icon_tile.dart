import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class WorkoutIconTile extends StatelessWidget {
  const WorkoutIconTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.s48,
      height: AppSizes.s48,
      decoration: AppShapes.decoration(
        color: context.colors.backgroundElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        Icons.fitness_center,
        color: context.colors.textMuted,
        size: AppSizes.s24,
      ),
    );
  }
}
