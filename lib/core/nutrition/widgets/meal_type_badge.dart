import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/images/app_photo_tile.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';

class MealTypeBadge extends StatelessWidget {
  const MealTypeBadge({
    super.key,
    required this.meal,
    this.size = AppSizes.s40,
    this.showPhoto = true,
  });

  final MealType meal;
  final double size;
  final bool showPhoto;

  static const double _chipRatio = 0.45;

  @override
  Widget build(BuildContext context) {
    if (showPhoto) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          AppPhotoTile(url: meal.photo, fallbackIcon: meal.icon, size: size),
          Positioned(
            right: -AppSpacing.xs,
            bottom: -AppSpacing.xs,
            child: _MealTimeChip(meal: meal, size: size * _chipRatio),
          ),
        ],
      );
    }

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

class _MealTimeChip extends StatelessWidget {
  const _MealTimeChip({required this.meal, required this.size});

  final MealType meal;
  final double size;

  static const double _iconRatio = 0.6;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: context.colors.backgroundPrimary,
        shape: CircleBorder(
          side: BorderSide(
            color: context.colors.borderSubtle,
            width: AppSizes.s1,
          ),
        ),
      ),
      child: Icon(
        meal.icon,
        color: meal.colorOf(context),
        size: size * _iconRatio,
      ),
    );
  }
}
