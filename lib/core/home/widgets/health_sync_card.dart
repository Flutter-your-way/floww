import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/theme/app_shapes.dart';

class HealthSyncCard extends StatelessWidget {
  const HealthSyncCard({
    super.key,
    required this.sourceName,
    required this.iconAsset,
    required this.connected,
    this.syncDetail,
    this.onConnect,
    this.onDisconnect,
  });

  final String sourceName;
  final String iconAsset;
  final bool connected;
  final String? syncDetail;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.tinted,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SvgPicture.asset(
              iconAsset,
              height: AppSizes.s40,
              width: AppSizes.s40,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$sourceName Sync',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleLarge,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  connected
                      ? (syncDetail ?? 'Syncing steps, sleep & heart rate')
                      : 'Better recovery predictions',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          _SyncStatusPill(
            connected: connected,
            onTap: connected ? onDisconnect : onConnect,
          ),
        ],
      ),
    );
  }
}

class _SyncStatusPill extends StatelessWidget {
  const _SyncStatusPill({required this.connected, this.onTap});

  final bool connected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = connected ? context.colors.success : context.colors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.tabSwitch,
        curve: AppMotion.tabSwitchSizeCurve,
        height: AppSizes.s32,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: AppShapes.decoration(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: color, width: 1),
        ),
        child: AnimatedSize(
          duration: AppMotion.tabSwitch,
          curve: AppMotion.tabSwitchSizeCurve,
          child: AnimatedSwitcher(
            duration: AppMotion.tabSwitch,
            switchInCurve: AppMotion.tabSwitchCurve,
            switchOutCurve: AppMotion.tabSwitchExitCurve,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: AppMotion.tabSwitchScale,
                  end: 1,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _SyncStatusLabel(
              key: ValueKey(connected),
              connected: connected,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _SyncStatusLabel extends StatelessWidget {
  const _SyncStatusLabel({
    super.key,
    required this.connected,
    required this.color,
  });

  final bool connected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (connected) ...[
          Container(
            width: AppSizes.s6,
            height: AppSizes.s6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: AppSpacing.sm),
        ],
        Text(
          connected ? 'Connected' : 'Connect',
          style: context.textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
