import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/theme/app_shapes.dart';

class AppleHealthSyncCard extends StatelessWidget {
  const AppleHealthSyncCard({
    super.key,
    required this.connected,
    this.syncDetail,
    this.onConnect,
    this.onDisconnect,
  });

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
              AppImages.appleHealth,
              height: AppSizes.s40,
              width: AppSizes.s40,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apple Health Sync', style: context.textTheme.titleLarge),
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
          if (connected)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppSizes.s6,
                      height: AppSizes.s6,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Connected',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                _SyncActionButton(
                  text: 'Disconnect',
                  color: context.colors.destructiveBorder,
                  onPressed: onDisconnect,
                ),
              ],
            )
          else
            _SyncActionButton(
              text: 'Connect',
              color: context.colors.primary,
              onPressed: onConnect,
            ),
        ],
      ),
    );
  }
}

class _SyncActionButton extends StatelessWidget {
  const _SyncActionButton({
    required this.text,
    required this.color,
    this.onPressed,
  });

  final String text;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: AppSizes.s32,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: AppShapes.decoration(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: color, width: 1),
        ),
        child: Center(
          child: Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}
