import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/settings/view_models/privacy_data_view_model.dart';
import 'package:floww/core/settings/views/delete_account_sheet.dart';
import 'package:floww/core/settings/widgets/danger_zone_card.dart';
import 'package:floww/core/settings/widgets/data_safety_card.dart';
import 'package:floww/core/settings/widgets/privacy_links_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class PrivacyDataView extends StatelessWidget {
  const PrivacyDataView({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    PrivacyDataViewModel viewModel,
  ) async {
    HapticManager.warning();
    final confirmed = await DeleteAccountSheet.show(
      context,
      title: viewModel.deletePromptTitle,
      message: viewModel.deletePromptMessage,
      confirmLabel: viewModel.deleteConfirmLabel,
    );
    if (confirmed != true) return;

    if (await viewModel.deleteAccount()) {
      await NavigationService.instance.pushAndRemoveUntil(
        AppRouter.accountSetup,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrivacyDataViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;

        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
          children: [
            DataSafetyCard(
              title: viewModel.assuranceTitle,
              message: viewModel.assuranceMessage,
            ),
            SizedBox(height: AppSpacing.xl2),
            PrivacyLinksCard(
              links: viewModel.links,
              onLinkTap: (link) => HapticManager.light(),
            ),
            SizedBox(height: AppSpacing.xl2),
            DangerZoneCard(
              title: viewModel.dangerZoneTitle,
              actionTitle: viewModel.deleteTitle,
              actionSubtitle: viewModel.deleteSubtitle,
              onDelete: viewModel.isDeleting
                  ? null
                  : () => _confirmDelete(context, viewModel),
            ),
            if (errorMessage != null) ...[
              SizedBox(height: AppSpacing.xl2),
              AppErrorCard(message: errorMessage),
            ],
          ],
        );
      },
    );
  }
}
