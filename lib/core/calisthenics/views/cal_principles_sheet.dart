import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_bullet_card.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';

class CalPrinciplesSheet extends StatelessWidget {
  const CalPrinciplesSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.principles,
    required this.safety,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<String> principles,
    required List<String> safety,
  }) => showAppFloatingSheet<void>(
    context: context,
    flip: true,
    builder: (_) => CalPrinciplesSheet(
      title: title,
      subtitle: subtitle,
      principles: principles,
      safety: safety,
    ),
  );

  final String title;
  final String subtitle;
  final List<String> principles;
  final List<String> safety;

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: AppSheetPanel(
        title: title,
        subtitle: subtitle,
        icon: Icons.health_and_safety_outlined,
        onClose: () => Navigator.of(context).maybePop(),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBulletCard(
              title: 'How to train',
              icon: Icons.bolt_rounded,
              items: principles,
            ),
            SizedBox(height: AppSpacing.lg),
            AppBulletCard(
              title: 'Stay safe',
              icon: Icons.health_and_safety_outlined,
              items: safety,
            ),
          ],
        ),
        footer: PillButton(
          variant: PillButtonVariant.primary,
          label: 'Got it',
          icon: Icons.check_rounded,
          onPressed: () {
            HapticManager.success();
            Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }
}
