import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_integrations.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/widgets/placeholders/app_spinner.dart';

class HealthIntegrationWidget extends StatelessWidget {
  const HealthIntegrationWidget({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    required this.onConnect,
    required this.usesAppleHealth,
    this.statusLabel,
  });

  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onConnect;
  final bool usesAppleHealth;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizes.s120,
          height: AppSizes.s120,
          decoration: AppShapes.decoration(
            borderRadius: BorderRadius.circular(AppRadius.xl4),
            color: colors.primary,
          ),
          child: ClipRSuperellipse(
            borderRadius: BorderRadius.circular(AppRadius.xl4),
            child: Image.asset(AppImages.appIcon, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        Icon(Icons.link, color: colors.textPrimary, size: AppSizes.s28),
        SizedBox(height: AppSpacing.xl),
        _HealthSourceRow(
          name: usesAppleHealth
              ? AppIntegrations.appleHealthName
              : AppIntegrations.healthConnectName,
          iconAsset: usesAppleHealth
              ? AppImages.appleHealthIcon
              : AppImages.healthConnectIcon,
          isConnected: isConnected,
          isConnecting: isConnecting,
          statusLabel: statusLabel,
          onConnect: onConnect,
        ),
      ],
    );
  }
}

class _HealthSourceRow extends StatelessWidget {
  const _HealthSourceRow({
    required this.name,
    required this.iconAsset,
    required this.isConnected,
    required this.isConnecting,
    required this.onConnect,
    this.statusLabel,
  });

  final String name;
  final String iconAsset;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onConnect;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = statusLabel;
    final canTap = !isConnected && !isConnecting;

    return GestureDetector(
      onTap: canTap ? onConnect : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl2,
          vertical: AppSpacing.xl,
        ),
        decoration: AppShapes.decoration(
          color: colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: isConnected ? colors.primary : colors.backgroundSecondary,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.s48,
              height: AppSizes.s48,
              decoration: AppShapes.decoration(
                color: colors.textPrimary,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconAsset,
                  width: AppSizes.s24,
                  height: AppSizes.s24,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  if (status != null) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      status,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            _ConnectPill(isConnected: isConnected, isConnecting: isConnecting),
          ],
        ),
      ),
    );
  }
}

class _ConnectPill extends StatelessWidget {
  const _ConnectPill({required this.isConnected, required this.isConnecting});

  final bool isConnected;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: isConnected ? colors.tintStrong : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: isConnected ? colors.primary : colors.borderMedium,
        ),
      ),
      child: isConnecting
          ? AppSpinner(size: AppSizes.s16, color: colors.primary)
          : Text(
              isConnected ? 'Connected' : 'Connect',
              style: context.textTheme.bodyMedium?.copyWith(
                color: isConnected ? colors.primary : colors.textPrimary,
              ),
            ),
    );
  }
}
