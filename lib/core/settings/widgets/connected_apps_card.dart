import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';
import 'package:floww/core/settings/widgets/connected_app_logo.dart';

class ConnectedAppsCard extends StatelessWidget {
  const ConnectedAppsCard({
    super.key,
    required this.apps,
    required this.connectLabel,
    required this.connectedLabel,
    required this.isPending,
    this.onToggle,
  });

  final List<ConnectedAppItem> apps;
  final String connectLabel;
  final String connectedLabel;
  final bool Function(String id) isPending;
  final ValueChanged<ConnectedAppItem>? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onToggle = this.onToggle;

    return AppCard(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final app in apps) ...[
            if (app != apps.first)
              Divider(
                height: AppSizes.s1,
                thickness: AppSizes.s1,
                color: colors.borderSubtle,
              ),
            _ConnectedAppRow(
              app: app,
              connectLabel: connectLabel,
              connectedLabel: connectedLabel,
              isPending: isPending(app.id),
              onToggle: onToggle == null ? null : () => onToggle(app),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConnectedAppRow extends StatelessWidget {
  const _ConnectedAppRow({
    required this.app,
    required this.connectLabel,
    required this.connectedLabel,
    required this.isPending,
    this.onToggle,
  });

  final ConnectedAppItem app;
  final String connectLabel;
  final String connectedLabel;
  final bool isPending;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          ConnectedAppLogo(iconAsset: app.iconAsset, wordmark: app.wordmark),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              app.name,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyLargeSemiBold.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          PillButton(
            variant: app.isConnected
                ? PillButtonVariant.neutral
                : PillButtonVariant.glass,
            height: AppSizes.s40,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
            label: app.isConnected ? connectedLabel : connectLabel,
            labelStyle: AppTypography.bodyMediumSemiBold,
            isLoading: isPending,
            onPressed: isPending ? null : onToggle,
          ),
        ],
      ),
    );
  }
}
