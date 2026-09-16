import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/premium/view_models/premium_view_model.dart';

class CancelSubscriptionSheet extends StatelessWidget {
  const CancelSubscriptionSheet({super.key, required this.viewModel});

  static Future<void> show({
    required BuildContext context,
    required PremiumViewModel viewModel,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => CancelSubscriptionSheet(viewModel: viewModel),
    );
  }

  final PremiumViewModel viewModel;

  Future<void> _confirm(BuildContext context) async {
    HapticManager.warning();
    final navigator = Navigator.of(context);
    await viewModel.cancelSubscription();
    await navigator.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppFloatingSheet(
      child: AppSheetPanel(
        title: viewModel.cancelTitle,
        titleStyle: AppTypography.heading3SemiBold,
        onClose: () => Navigator.of(context).maybePop(),
        body: Text(
          viewModel.cancelMessage,
          style: AppTypography.bodyMediumMedium.copyWith(
            color: colors.textSubtle,
          ),
        ),
        footer: Row(
          children: [
            Expanded(
              child: PillButton(
                variant: PillButtonVariant.outline,
                height: AppSizes.s52,
                onPressed: () => _confirm(context),
                child: Text(
                  viewModel.cancelConfirmLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLargeSemiBold.copyWith(
                    color: colors.destructiveBorder,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: PillButton(
                variant: PillButtonVariant.primary,
                height: AppSizes.s52,
                label: viewModel.cancelDismissLabel,
                labelStyle: AppTypography.labelLargeSemiBold,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
