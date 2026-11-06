import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/progress/app_progress_ring.dart';

class DietPlanCard extends StatelessWidget {
  const DietPlanCard({
    super.key,
    required this.nextLabel,
    required this.daysLabel,
    required this.percentLabel,
    required this.progress,
    this.onTap,
  });

  final String nextLabel;
  final String daysLabel;
  final String percentLabel;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: AppCard(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            AppProgressRing(
              progress: progress,
              size: AppSizes.s44,
              strokeWidth: AppSizes.s4,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: FittedBox(
                  child: Text(
                    percentLabel,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diet Plan · $nextLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelMedium,
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    daysLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textSecondary,
              size: AppSizes.s20,
            ),
          ],
        ),
      ),
    );
  }
}
