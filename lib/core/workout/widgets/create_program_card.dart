import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/effects/dashed_border.dart';

class CreateProgramCard extends StatelessWidget {
  const CreateProgramCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: DashedBorder(
        color: colors.borderAccent,
        radius: AppRadius.xl,
        child: AppCard(
          variant: AppCardVariant.tinted,
          borderColor: Colors.transparent,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              Container(
                width: AppSizes.s48,
                height: AppSizes.s48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: AppSizes.s28,
                  color: colors.backgroundPrimary,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Build your own program',
                      style: AppTypography.heading4SemiBold.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Pick your days, exercises, sets and reps',
                      style: AppTypography.bodySmallRegularTight.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Icon(
                Icons.chevron_right_rounded,
                size: AppSizes.s24,
                color: colors.primaryAlt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
