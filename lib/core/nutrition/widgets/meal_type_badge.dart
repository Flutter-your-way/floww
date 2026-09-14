import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';
import 'package:floww/config/theme/app_shapes.dart';

class MealTypeBadge extends StatelessWidget {
  const MealTypeBadge({super.key, required this.meal, this.size = AppSizes.s40});

  final MealType meal;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: AppShapes.decoration(
        color: context.colors.backgroundElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(meal.icon, color: meal.colorOf(context), size: size / 2),
    );
  }
}
