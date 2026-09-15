import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';

class NutritionActionButtons extends StatelessWidget {
  const NutritionActionButtons({super.key, this.onScanFood, this.onLogFood});

  final VoidCallback? onScanFood;
  final VoidCallback? onLogFood;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.primaryAlt;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PillButton(
          onPressed: onScanFood,
          width: AppSizes.s46,
          height: AppSizes.s46,
          child: SvgPicture.asset(
            AppImages.foodScanIcon,
            width: AppSizes.s20,
            height: AppSizes.s20,
            colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        PillButton(
          onPressed: onLogFood,
          height: AppSizes.s46,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl2,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: accent, size: AppSizes.s20),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Log Food',
                style: AppTypography.labelMediumSemiBold.copyWith(
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
