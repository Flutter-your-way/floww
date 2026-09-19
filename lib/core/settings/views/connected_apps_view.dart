import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/config/widgets/sheets/app_confirm_sheet.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';
import 'package:floww/core/settings/view_models/connected_apps_view_model.dart';
import 'package:floww/core/settings/widgets/connected_apps_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class ConnectedAppsView extends StatelessWidget {
  const ConnectedAppsView({super.key});

  Future<void> _toggle(
    BuildContext context,
    ConnectedAppsViewModel viewModel,
    ConnectedAppItem app,
  ) async {
    HapticManager.light();
    if (!app.isConnected) {
      await viewModel.setConnected(app.id, true);
      return;
    }

    final choice = await AppConfirmSheet.show(
      context,
      title: viewModel.disconnectTitle,
      message: viewModel.disconnectMessage(app.name),
      confirmLabel: viewModel.disconnectLabel,
      alternateLabel: viewModel.cancelLabel,
      icon: Icons.link_off_rounded,
      isDestructive: true,
    );
    if (choice != AppConfirmChoice.confirm) return;
    HapticManager.warning();
    await viewModel.setConnected(app.id, false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectedAppsViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;

        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
          children: [
            if (errorMessage != null) ...[
              AppErrorCard(
                message: errorMessage,
                retryLabel: viewModel.errorRetryLabel,
                onRetry: viewModel.dismissError,
              ),
              SizedBox(height: AppSpacing.lg),
            ],
            ConnectedAppsCard(
              apps: viewModel.apps,
              connectLabel: viewModel.connectLabel,
              connectedLabel: viewModel.connectedLabel,
              isPending: viewModel.isPending,
              onToggle: (app) => _toggle(context, viewModel, app),
            ),
          ],
        );
      },
    );
  }
}
