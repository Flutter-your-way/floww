import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';

class PremiumLockedRow extends StatelessWidget {
  const PremiumLockedRow({super.key, required this.capability, this.label});

  static const String ctaLabel = 'Unlock';

  final PremiumCapability capability;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: context.read<PremiumAccessProvider>().openUpgrade,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: AppShapes.decoration(
          color: colors.backgroundPrimary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_rounded, size: AppSizes.s18, color: colors.primary),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label ?? capability.lockTitle,
                style: AppTypography.labelLargeSemiBold.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              ctaLabel,
              style: AppTypography.labelLargeSemiBold.copyWith(
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
