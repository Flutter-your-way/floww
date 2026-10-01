import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/placeholders/app_spinner.dart';
import 'package:floww/core/nutrition/widgets/food_photo.dart';

class CatalogFoodRow extends StatelessWidget {
  const CatalogFoodRow({
    super.key,
    required this.name,
    required this.photoName,
    required this.macrosLabel,
    required this.caloriesLabel,
    required this.isAdded,
    required this.isSaving,
    this.onTap,
  });

  final String name;
  final String photoName;
  final String macrosLabel;
  final String caloriesLabel;
  final bool isAdded;
  final bool isSaving;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: isSaving ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          children: [
            FoodPhoto(name: photoName),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isAdded
                          ? colors.textSecondary
                          : colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    macrosLabel,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              caloriesLabel,
              style: context.textTheme.labelLarge?.copyWith(
                color: colors.accentOrange,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            SizedBox.square(
              dimension: AppSizes.s24,
              child: isSaving
                  ? AppSpinner(color: colors.primary)
                  : Icon(
                      isAdded ? Icons.check_circle_rounded : Icons.add_rounded,
                      color: colors.primary,
                      size: AppSizes.s24,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
