import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';

class PremiumStatusCard extends StatelessWidget {
  const PremiumStatusCard({
    super.key,
    required this.planLabel,
    required this.title,
    required this.message,
    this.badgeLabel,
    this.actionLabel,
    this.onAction,
  });

  final String? badgeLabel;
  final String planLabel;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badgeLabel = this.badgeLabel;
    final actionLabel = this.actionLabel;

    return AppCard(
      variant: AppCardVariant.glow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppIconTile.asset(
            assetPath: AppImages.crownIcon,
            size: AppSizes.s72,
            iconSize: AppSizes.s36,
            radius: AppRadius.lg,
            backgroundColor: colors.bgTinted,
            borderColor: colors.borderGlow,
            iconColor: colors.primary,
          ),
          SizedBox(height: AppSpacing.xl2),
          if (badgeLabel != null) ...[
            AppStatusChip(
              label: badgeLabel,
              icon: Icons.check_rounded,
              horizontalPadding: AppSpacing.sm,
              labelStyle: AppTypography.bodySmallSemiBold,
            ),
            SizedBox(height: AppSpacing.lg),
          ],
          Text(
            planLabel,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLargeMedium.copyWith(
              color: colors.textSubtle,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.heading2ExtraBold,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLargeMedium.copyWith(
              color: colors.textSubtle,
            ),
          ),
          if (actionLabel != null) ...[
            SizedBox(height: AppSpacing.xl2),
            PillButton(
              variant: PillButtonVariant.primary,
              label: actionLabel,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
