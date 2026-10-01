import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';

class MealTimeIcon extends StatelessWidget {
  const MealTimeIcon({super.key, required this.meal, this.size = AppSizes.s44});

  final MealType meal;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      meal.iconAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
