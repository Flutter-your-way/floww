import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/premium/widgets/premium_lock_icon.dart';

class PremiumLockedCard extends StatelessWidget {
  const PremiumLockedCard({
    super.key,
    required this.capability,
    this.title,
    this.message,
  });

  static const String ctaLabel = 'Unlock';

  final PremiumCapability capability;
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final openUpgrade = context.read<PremiumAccessProvider>().openUpgrade;

    return PressScale(
      onTap: openUpgrade,
      child: AppCard(
        variant: AppCardVariant.glow,
        borderColor: colors.borderGlow,
        child: Row(
          children: [
            const PremiumLockIcon(),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? capability.lockTitle,
                    style: AppTypography.heading4SemiBold.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    message ?? capability.lockMessage,
                    style: AppTypography.labelSmallMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            PillButton(
              variant: PillButtonVariant.accent,
              label: ctaLabel,
              height: AppSizes.s36,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              onPressed: openUpgrade,
            ),
          ],
        ),
      ),
    );
  }
}
