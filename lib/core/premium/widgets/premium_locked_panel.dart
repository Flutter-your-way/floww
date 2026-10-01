import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/constants/app_subscription.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/premium/widgets/premium_lock_icon.dart';

class PremiumLockedPanel extends StatelessWidget {
  const PremiumLockedPanel({super.key, required this.capability});

  static const String ctaLabel = 'Unlock with Premium';
  static const String footnote =
      '${AppSubscription.trialDays}-day free trial · Cancel anytime';

  final PremiumCapability capability;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: PremiumLockIcon(size: AppSizes.s72, iconSize: AppSizes.s32),
          ),
          SizedBox(height: AppSpacing.xl3),
          Text(
            capability.lockTitle,
            textAlign: TextAlign.center,
            style: AppTypography.heading3Bold.copyWith(
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            capability.lockMessage,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMediumRegular.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xl4),
          PillButton(
            variant: PillButtonVariant.primary,
            icon: Icons.workspace_premium_rounded,
            label: ctaLabel,
            onPressed: context.read<PremiumAccessProvider>().openUpgrade,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            footnote,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: colors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
