import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/profile/models/profile_view_data.dart';

class ProfileMetricCard extends StatelessWidget {
  const ProfileMetricCard({super.key, required this.section, this.onEdit});

  final ProfileMetricSection section;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: section.title,
            titleStyle: AppTypography.heading4SemiBold,
            trailing: _ProfileEditAction(label: section.actionLabel),
            onTap: onEdit,
          ),
          for (final item in section.items) ...[
            Divider(
              height: AppSpacing.xl2,
              thickness: AppSizes.s1,
              color: colors.borderSubtle,
            ),
            _ProfileMetricRow(item: item),
          ],
        ],
      ),
    );
  }
}

class _ProfileEditAction extends StatelessWidget {
  const _ProfileEditAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.bodySmallMediumTight.copyWith(
            color: colors.primary,
          ),
        ),
        SizedBox(width: AppSpacing.xxs),
        Icon(
          Icons.chevron_right_rounded,
          size: AppSizes.s18,
          color: colors.primary,
        ),
      ],
    );
  }
}

class _ProfileMetricRow extends StatelessWidget {
  const _ProfileMetricRow({required this.item});

  final ProfileMetricItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unit = item.unit;

    return Row(
      children: [
        Icon(item.icon, size: AppSizes.s20, color: colors.textMuted),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            item.label,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyLargeMedium.copyWith(
              color: colors.textSubtle,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Text(
          item.value,
          style: AppTypography.bodyLargeBold.copyWith(
            color: colors.textPrimary,
          ),
        ),
        if (unit != null) ...[
          SizedBox(width: AppSpacing.xs),
          Text(
            unit,
            style: AppTypography.bodySmallMediumTight.copyWith(
              color: colors.textSubtle,
            ),
          ),
        ],
      ],
    );
  }
}
