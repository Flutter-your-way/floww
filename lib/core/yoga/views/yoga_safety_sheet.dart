import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/yoga/data/yoga_module_data.dart';
import 'package:floww/config/widgets/cards/app_bullet_card.dart';

class YogaSafetySheet extends StatelessWidget {
  const YogaSafetySheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final accepted = await showAppFloatingSheet<bool>(
      context: context,
      builder: (_) => const YogaSafetySheet(),
    );
    return accepted ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: AppSheetPanel(
        title: 'Before you begin',
        subtitle: YogaModuleData.motto,
        icon: Icons.health_and_safety_outlined,
        onClose: () => Navigator.of(context).pop(false),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppBulletCard(
              title: 'Safety essentials',
              icon: Icons.health_and_safety_outlined,
              items: YogaModuleData.safetyEssentials,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              YogaModuleData.disclaimer,
              style: AppTypography.bodySmallItalic.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ],
        ),
        footer: PillButton(
          variant: PillButtonVariant.primary,
          label: 'I understand',
          icon: Icons.check_rounded,
          onPressed: () {
            HapticManager.success();
            Navigator.of(context).pop(true);
          },
        ),
      ),
    );
  }
}
