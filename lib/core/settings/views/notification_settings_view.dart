import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/settings/view_models/notification_settings_view_model.dart';
import 'package:floww/core/settings/widgets/notification_master_card.dart';
import 'package:floww/core/settings/widgets/notification_section_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

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
