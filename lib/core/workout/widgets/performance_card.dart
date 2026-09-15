import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_tone_color.dart';

class PerformanceCard extends StatelessWidget {
  const PerformanceCard({
    super.key,
    required this.performance,
    this.onViewDetails,
  });

  final PerformanceItem performance;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: 'Performance',
            titleStyle: AppTypography.labelLargeSemiBold.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < performance.stats.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _PerformanceStatTile(stat: performance.stats[i]),
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          _PersonalRecordsPanel(records: performance.records),
          SizedBox(height: AppSpacing.xl),
          PillButton(
            variant: PillButtonVariant.bright,
            height: AppSizes.s32,
            onPressed: onViewDetails,
            child: const _ViewDetailsLabel(),
          ),
        ],
      ),
    );
  }
}

class _ViewDetailsLabel extends StatelessWidget {
  const _ViewDetailsLabel();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'VIEW WORKOUT DETAILS',
          style: AppTypography.captionSemiBold.copyWith(color: colors.bgWarm),
        ),
        SizedBox(width: AppSpacing.xs),
        Icon(
          Icons.arrow_circle_right,
          size: AppSizes.s16,
          color: colors.onSurfaceBright,
        ),
      ],
    );
  }
}

class _PerformanceStatTile extends StatelessWidget {
  const _PerformanceStatTile({required this.stat});

  final PerformanceStatItem stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: AppSizes.s32,
          child: Text(
            stat.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmallMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          stat.value,
          style: AppTypography.bodyXLargeBold.copyWith(
            color: stat.tone.resolve(context),
          ),
        ),
      ],
    );
  }
}

class _PersonalRecordsPanel extends StatelessWidget {
  const _PersonalRecordsPanel({required this.records});

  final List<PersonalRecordItem> records;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = AppShapes.border(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    );

    return Container(
      decoration: AppShapes.decoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.amberBorder, width: AppSizes.s1),
      ),
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: colors.amberSurface,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Text(
                'PERSONAL RECORDS',
                style: AppTypography.captionSemiBold.copyWith(
                  color: colors.accentOrangeLight,
                ),
              ),
            ),
            for (var i = 0; i < records.length; i++)
              _PersonalRecordRow(record: records[i], showDivider: i > 0),
          ],
        ),
      ),
    );
  }
}

class _PersonalRecordRow extends StatelessWidget {
  const _PersonalRecordRow({required this.record, required this.showDivider});

  final PersonalRecordItem record;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSizes.s10,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundSurface,
        border: showDivider
            ? Border(
                top: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              record.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmallMediumTight.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xxs,
            ),
            decoration: AppShapes.decoration(
              color: colors.amberBorder,
              borderRadius: BorderRadius.circular(AppRadius.full),
              side: BorderSide(color: colors.amberBorder, width: AppSizes.s1),
            ),
            child: Text(
              record.improvement,
              style: AppTypography.bodySmallMediumTight.copyWith(
                color: colors.accentOrangeLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
