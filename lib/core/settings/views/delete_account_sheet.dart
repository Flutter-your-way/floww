import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/destructive_pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class DeleteAccountSheet extends StatelessWidget {
  const DeleteAccountSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showAppFloatingSheet<bool>(
      context: context,
      builder: (_) => DeleteAccountSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: () => NavigationService.instance.pop(true),
      ),
    );
  }

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback? onConfirm;

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
            SizedBox(height: AppSpacing.xl2),
            Align(
              alignment: Alignment.centerRight,
              child: CircularHeaderButton(
                icon: Icons.close_rounded,
                backgroundColor: colors.backgroundSurface,
                onPressed: () => NavigationService.instance.pop(),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            const _DeleteAccountWarningBadge(),
            SizedBox(height: AppSpacing.xl4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.heading1.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLargeMedium.copyWith(
                color: colors.textSubtle,
              ),
            ),
            SizedBox(height: AppSpacing.xl4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
              child: DestructivePillButton(
                label: confirmLabel,
                onPressed: onConfirm,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountWarningBadge extends StatelessWidget {
  const _DeleteAccountWarningBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Container(
        height: AppSizes.s128,
        width: AppSizes.s128,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.destructiveTint,
          shape: BoxShape.circle,
          border: Border.all(
            color: colors.destructiveOutline,
            width: AppSizes.s1,
          ),
        ),
        child: Icon(
          Icons.warning_rounded,
          size: AppSizes.s64,
          color: colors.warning,
        ),
      ),
    );
  }
}
