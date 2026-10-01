import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class WorkoutEmptyStateCard extends StatelessWidget {
  const WorkoutEmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconAsset,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.glow,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconAsset case final asset?)
            SvgPicture.asset(
              asset,
              width: AppSizes.s32,
              height: AppSizes.s32,
              colorFilter: ColorFilter.mode(
                context.colors.textMuted,
                BlendMode.srcIn,
              ),
            )
          else
            Icon(icon, color: context.colors.textMuted, size: AppSizes.s24),
          SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.heading4SemiBold.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
