import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/core/settings/widgets/notification_tone_card.dart';
import 'package:floww/config/widgets/sheets/app_option_sheet.dart';
import 'package:floww/config/utils/notifications/notification_tones.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/settings/view_models/notification_settings_view_model.dart';
import 'package:floww/core/settings/widgets/notification_master_card.dart';
import 'package:floww/core/settings/widgets/notification_section_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  Future<void> _openTones(
    BuildContext context,
    NotificationSettingsViewModel viewModel,
  ) async {
    HapticManager.light();
    final picked = await AppOptionSheet.show<NotificationTone>(
      context,
      title: viewModel.toneSheetTitle,
      icon: Icons.music_note_rounded,
      options: [
        for (final tone in viewModel.tones)
          AppSheetOption(
            icon: tone == viewModel.tone
                ? Icons.check_circle_rounded
                : Icons.music_note_rounded,
            label: tone.label,
            value: tone,
          ),
      ],
    );
    if (picked == null) return;
    HapticManager.selection();
    await viewModel.selectTone(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationSettingsViewModel>(
      builder: (context, viewModel, child) {
        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
          children: [
            NotificationMasterCard(
              item: viewModel.master,
              onChanged: (value) {
                HapticManager.light();
                viewModel.setMasterEnabled(value);
              },
            ),
            SizedBox(height: AppSpacing.xl2),
            NotificationToneCard(
              title: viewModel.toneTitle,
              subtitle: viewModel.toneSubtitle,
              valueLabel: viewModel.toneValueLabel,
              onTap: () => _openTones(context, viewModel),
            ),
            for (final section in viewModel.sections) ...[
              SizedBox(height: AppSpacing.xl2),
              NotificationSectionCard(
                section: section,
                isEnabled: viewModel.areTogglesEnabled,
                onChanged: (id, value) {
                  HapticManager.light();
                  viewModel.setToggleEnabled(id, value);
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
