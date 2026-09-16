import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/core/premium/view_models/premium_upgrade_view_model.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class PremiumSuccessSheet extends StatelessWidget {
  const PremiumSuccessSheet({super.key, required this.viewModel});

  static const String celebrationEmoji = '\u{1F389}';

  static Future<void> show({
    required BuildContext context,
    required PremiumUpgradeViewModel viewModel,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => PremiumSuccessSheet(viewModel: viewModel),
    );
  }

  final PremiumUpgradeViewModel viewModel;

  void _openActivePlan(BuildContext context) {
    HapticManager.light();
    Navigator.of(context).pop();
    NavigationService.instance.pushReplacement(AppRouter.premium);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppFloatingSheet(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSpacing.xl),
            Align(
              alignment: Alignment.centerRight,
              child: CircularHeaderButton(
                icon: Icons.close_rounded,
                size: AppSizes.s40,
                iconSize: AppSizes.s20,
                backgroundColor: colors.backgroundPrimary,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            const Center(child: _CelebrationBadge()),
            SizedBox(height: AppSpacing.xl3),
            Text(
              viewModel.successTitle,
              textAlign: TextAlign.center,
              style: AppTypography.heading2ExtraBold,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              viewModel.successMessage,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLargeMedium.copyWith(
                color: colors.textSubtle,
              ),
            ),
            SizedBox(height: AppSpacing.xl3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularHeaderButton(
                  icon: Icons.edit_outlined,
                  size: AppSizes.s56,
                  iconSize: AppSizes.s24,
                  backgroundColor: colors.backgroundSurface,
                  borderColor: colors.borderSubtle,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                SizedBox(width: AppSpacing.xl),
                PillButton(
                  variant: PillButtonVariant.accent,
                  height: AppSizes.s56,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl4),
                  label: viewModel.successActionLabel,
                  labelStyle: AppTypography.heading4SemiBold,
                  onPressed: () => _openActivePlan(context),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xl2),
          ],
        ),
      ),
    );
  }
}

class _CelebrationBadge extends StatelessWidget {
  const _CelebrationBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: AppSizes.s120,
      width: AppSizes.s120,
      alignment: Alignment.center,
      decoration: AppShapes.decoration(
        color: colors.bgTinted,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
      ),
      child: Text(
        PremiumSuccessSheet.celebrationEmoji,
        style: AppTypography.bodyXXLargeBold,
      ),
    );
  }
}
