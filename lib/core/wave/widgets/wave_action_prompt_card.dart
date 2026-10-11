import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/core/wave/widgets/wave_card.dart';

class WaveActionPromptCard extends StatelessWidget {
  const WaveActionPromptCard({
    super.key,
    required this.title,
    required this.detail,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isResolved,
    required this.onConfirm,
    required this.onCancel,
  });

  final String title;
  final String detail;
  final String confirmLabel;
  final String cancelLabel;
  final bool isResolved;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return WaveCard(
      headerColor: context.colors.destructiveTint,
      header: Text(
        title,
        style: AppTypography.bodyLargeBold.copyWith(
          color: context.colors.destructiveBorder,
        ),
      ),
      sections: [
        WaveCardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (detail.isNotEmpty) ...[
                Text(
                  detail,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSubtle,
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
              ],
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      variant: PillButtonVariant.accent,
                      label: confirmLabel,
                      height: AppSizes.s44,
                      labelStyle: AppTypography.bodyLargeBold,
                      onPressed: isResolved ? null : onConfirm,
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: PillButton(
                      variant: PillButtonVariant.glass,
                      label: cancelLabel,
                      height: AppSizes.s44,
                      labelStyle: AppTypography.bodyLargeBold,
                      labelColor: context.colors.textPrimary,
                      onPressed: isResolved ? null : onCancel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
