import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';

class MicronutrientTile extends StatelessWidget {
  const MicronutrientTile({
    super.key,
    required this.item,
    this.onTap,
    this.onAdd,
  });

  final MicronutrientTileItem item;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onAdd = this.onAdd;
    final barColor = item.isOverLimit ? colors.destructiveBorder : null;
    final isLimit = item.kind.isLimit;

    return PressScale(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardHeader(
              title: item.label,
              trailing: SvgPicture.asset(
                item.kind.iconAsset,
                width: AppSizes.s20,
                height: AppSizes.s20,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppProgressBar(
                    progress: item.progress,
                    height: AppSizes.s8,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Text(
                  item.percentLabel,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: barColor ?? colors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        text: item.valueLabel,
                        style: AppTypography.bodyLargeBold.copyWith(
                          color: colors.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text: item.goalLabel,
                            style: AppTypography.bodyLargeMedium.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                if (onAdd != null) ...[
                  SizedBox(width: AppSpacing.md),
                  GestureDetector(
                    onTap: onAdd,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      '+ Intake',
                      style: AppTypography.bodyMediumMedium.copyWith(
                        color: colors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: colors.primary,
                      ),
                    ),
                  ),
                ],
                SizedBox(width: AppSpacing.md),
                Icon(
                  isLimit ? Icons.arrow_downward : Icons.arrow_upward,
                  size: AppSizes.s18,
                  color: isLimit ? colors.accentOrange : colors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
