import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/destructive_pill_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/navigation/services/navigation_service.dart';

enum AppConfirmChoice { confirm, alternate }

class AppConfirmSheet extends StatelessWidget {
  const AppConfirmSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.alternateLabel,
    this.icon = Icons.priority_high_rounded,
    this.isDestructive = false,
  });

  static Future<AppConfirmChoice?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String alternateLabel,
    IconData icon = Icons.priority_high_rounded,
    bool isDestructive = false,
  }) {
    return showAppFloatingSheet<AppConfirmChoice>(
      context: context,
      builder: (_) => AppConfirmSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        alternateLabel: alternateLabel,
        icon: icon,
        isDestructive: isDestructive,
      ),
    );
  }

  final String title;
  final String message;
  final String confirmLabel;
  final String alternateLabel;
  final IconData icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: AppSheetPanel(
        title: title,
        icon: icon,
        onClose: () => NavigationService.instance.pop(),
        body: Text(
          message,
          style: AppTypography.bodyMediumMedium.copyWith(
            color: context.colors.textSubtle,
          ),
        ),
        footer: Row(
          children: [
            Expanded(
              child: PillButton(
                variant: PillButtonVariant.outline,
                label: alternateLabel,
                height: AppSizes.s56,
                labelStyle: AppTypography.labelLargeSemiBold,
                onPressed: () =>
                    NavigationService.instance.pop(AppConfirmChoice.alternate),
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: isDestructive
                  ? DestructivePillButton(
                      label: confirmLabel,
                      onPressed: () => NavigationService.instance.pop(
                        AppConfirmChoice.confirm,
                      ),
                    )
                  : PillButton(
                      variant: PillButtonVariant.primary,
                      label: confirmLabel,
                      height: AppSizes.s56,
                      labelStyle: AppTypography.labelLargeSemiBold,
                      onPressed: () => NavigationService.instance.pop(
                        AppConfirmChoice.confirm,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
