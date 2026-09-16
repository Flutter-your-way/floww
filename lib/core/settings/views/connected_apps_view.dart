import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/settings/view_models/connected_apps_view_model.dart';
import 'package:floww/core/settings/widgets/connected_apps_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class ConnectedAppsView extends StatelessWidget {
  const ConnectedAppsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectedAppsViewModel>(
      builder: (context, viewModel, child) {
        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
          children: [
            ConnectedAppsCard(
              apps: viewModel.apps,
              connectLabel: viewModel.connectLabel,
              connectedLabel: viewModel.connectedLabel,
              onConnect: (app) {
                HapticManager.light();
                viewModel.connect(app.id);
              },
            ),
          ],
        );
      },
    );
  }
}
