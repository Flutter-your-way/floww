import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class HealthSyncCard extends StatelessWidget {
  const HealthSyncCard({
    super.key,
    required this.iconAsset,
    required this.connected,
    required this.title,
    required this.subtitle,
    required this.connectLabel,
    this.viewMoreLabel,
    this.onConnect,
    this.onViewMore,
  });

  final String iconAsset;
  final bool connected;
  final String title;
  final String subtitle;
  final String connectLabel;
  final String? viewMoreLabel;
  final VoidCallback? onConnect;
  final VoidCallback? onViewMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final viewMoreLabel = this.viewMoreLabel;

    return AppCard(
      variant: AppCardVariant.tinted,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SvgPicture.asset(
              iconAsset,
              height: AppSizes.s32,
              width: AppSizes.s32,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLargeSemiBold.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                if (connected && viewMoreLabel != null)
                  _ViewMoreLink(label: viewMoreLabel, onTap: onViewMore)
                else
                  _StatusLine(label: subtitle, connected: connected),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          if (connected)
            _ConnectedDot(color: colors.success)
          else
            IntrinsicWidth(
              child: PillButton(
                variant: PillButtonVariant.glass,
                height: AppSizes.s32,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                label: connectLabel,
                labelStyle: AppTypography.bodySmallSemiBold,
                labelColor: colors.primary,
                onPressed: onConnect,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.label, required this.connected});

  final String label;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.bodySmall?.copyWith(
        color: connected
            ? context.colors.success
            : context.colors.textSecondary,
      ),
    );
  }
}

class _ViewMoreLink extends StatelessWidget {
  const _ViewMoreLink({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmallSemiBold.copyWith(color: color),
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Icon(Icons.north_east_rounded, size: AppSizes.s14, color: color),
        ],
      ),
    );
  }
}

class _ConnectedDot extends StatelessWidget {
  const _ConnectedDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.s8,
      height: AppSizes.s8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
