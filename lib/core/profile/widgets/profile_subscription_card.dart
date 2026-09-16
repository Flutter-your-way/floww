import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/core/profile/models/profile_view_data.dart';

class ProfileSubscriptionCard extends StatelessWidget {
  const ProfileSubscriptionCard({
    super.key,
    required this.subscription,
    this.onAction,
  });

  final ProfileSubscription subscription;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.glow,
      borderColor: subscription.isActive
          ? context.colors.borderGlow
          : context.colors.borderAccent,
      child: subscription.isActive
          ? _ActiveSubscription(subscription: subscription, onManage: onAction)
          : _TrialSubscription(subscription: subscription, onUpgrade: onAction),
    );
  }
}

class _TrialSubscription extends StatelessWidget {
  const _TrialSubscription({required this.subscription, this.onUpgrade});

  final ProfileSubscription subscription;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              AppImages.crownIcon,
              height: AppSizes.s24,
              width: AppSizes.s24,
              colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                subscription.title,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.heading4.copyWith(color: colors.primary),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          subscription.message,
          style: AppTypography.labelMediumRegular.copyWith(
            color: colors.textSubtle,
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        PillButton(
          variant: PillButtonVariant.primary,
          onPressed: onUpgrade,
          child: _UpgradeLabel(label: subscription.actionLabel),
        ),
      ],
    );
  }
}

class _UpgradeLabel extends StatelessWidget {
  const _UpgradeLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.backgroundSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.heading4SemiBold.copyWith(color: color),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Icon(Icons.arrow_forward_rounded, size: AppSizes.s20, color: color),
      ],
    );
  }
}

class _ActiveSubscription extends StatelessWidget {
  const _ActiveSubscription({required this.subscription, this.onManage});

  final ProfileSubscription subscription;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badgeLabel = subscription.badgeLabel;

    return Row(
      children: [
        const _CrownTile(),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        subscription.title,
                        maxLines: 1,
                        softWrap: false,
                        style: AppTypography.bodyLargeBold.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                  if (badgeLabel != null) ...[
                    SizedBox(width: AppSpacing.md),
                    AppStatusChip(
                      label: badgeLabel,
                      height: AppSizes.s24,
                      horizontalPadding: AppSpacing.sm,
                      labelStyle: AppTypography.captionSemiBold,
                    ),
                  ],
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                subscription.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmallRegular.copyWith(
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.md),
        PillButton(
          variant: PillButtonVariant.neutral,
          label: subscription.actionLabel,
          height: AppSizes.s36,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          labelStyle: AppTypography.labelSmallSemiBold,
          labelColor: colors.primary,
          onPressed: onManage,
        ),
      ],
    );
  }
}

class _CrownTile extends StatelessWidget {
  const _CrownTile();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppIconTile.asset(
      assetPath: AppImages.crownIcon,
      size: AppSizes.s48,
      iconSize: AppSizes.s24,
      backgroundColor: colors.bgTinted,
      borderColor: colors.borderGlow,
      iconColor: colors.primary,
    );
  }
}
