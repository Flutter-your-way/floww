import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';

class ProgressCardEmptyState extends StatelessWidget {
  const ProgressCardEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: AppSizes.s32, color: colors.textMuted),
        SizedBox(height: AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.heading4SemiBold.copyWith(
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmallRegularTight.copyWith(
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        PillButton(
          variant: PillButtonVariant.bright,
          height: AppSizes.s44,
          icon: Icons.add_rounded,
          label: buttonLabel,
          labelStyle: AppTypography.labelSmallSemiBold,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
