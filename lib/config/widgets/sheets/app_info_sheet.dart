import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class AppInfoSheet extends StatelessWidget {
  const AppInfoSheet({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Got it',
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => AppInfoSheet(title: title, message: message),
    );
  }

  final String title;
  final String message;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: AppSheetPanel(
        title: title,
        icon: Icons.question_mark_rounded,
        onClose: () => NavigationService.instance.pop(),
        body: Text(
          message,
          style: AppTypography.bodyMediumMedium.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        footer: Center(
          child: PillButton(
            label: confirmLabel,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl4),
            onPressed: () => NavigationService.instance.pop(),
          ),
        ),
      ),
    );
  }
}
