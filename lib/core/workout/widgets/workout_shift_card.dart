import 'package:flutter/material.dart';

import 'package:floww/config/widgets/images/wave_avatar_badge.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class WorkoutShiftCard extends StatelessWidget {
  const WorkoutShiftCard({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.isLoading = false,
    this.icon = Icons.event_repeat_rounded,
    this.byWave = false,
    this.errorMessage,
    this.onDismiss,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final bool isLoading;
  final IconData icon;
  final bool byWave;
  final String? errorMessage;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final errorMessage = this.errorMessage;
    final onDismiss = this.onDismiss;

    return AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              byWave
                  ? const WaveAvatarBadge(size: AppSizes.s28, contained: true)
                  : Icon(icon, size: AppSizes.s20, color: colors.primary),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelLargeSemiBold.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (onDismiss != null) ...[
                SizedBox(width: AppSpacing.md),
                CircularHeaderButton(
                  icon: Icons.close_rounded,
                  size: AppSizes.s28,
                  iconSize: AppSizes.s16,
                  onPressed: onDismiss,
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: colors.textSecondary,
            ),
          ),
          if (errorMessage != null) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              errorMessage,
              style: AppTypography.bodySmallRegularTight.copyWith(
                color: colors.destructiveBorder,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.lg),
          PillButton(
            variant: PillButtonVariant.outline,
            height: AppSizes.s44,
            label: actionLabel,
            isLoading: isLoading,
            onPressed: isLoading ? null : onAction,
          ),
        ],
      ),
    );
  }
}
