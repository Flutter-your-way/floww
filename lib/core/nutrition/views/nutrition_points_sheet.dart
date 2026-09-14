import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class NutritionPointsSheet extends StatelessWidget {
  const NutritionPointsSheet({super.key, required this.message});

  static Future<void> show(BuildContext context, {required String message}) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => NutritionPointsSheet(message: message),
    );
  }

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: AppSheetPanel(
        title: 'Nutrition',
        onClose: () => NavigationService.instance.pop(),
        body: Text(message, style: context.textTheme.bodyMedium),
        footer: Center(
          child: PillButton(
            label: 'Got it',
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl4),
            onPressed: () => NavigationService.instance.pop(),
          ),
        ),
      ),
    );
  }
}
