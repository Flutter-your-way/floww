import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/heart_rate_chart.dart';
import 'package:floww/core/workout/widgets/workout_tone_color.dart';

class HeartRateCard extends StatelessWidget {
  const HeartRateCard({super.key, required this.heartRate});

  final HeartRateItem heartRate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: 'Heart Rate',
            titleStyle: AppTypography.labelLargeSemiBold.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              for (var i = 0; i < heartRate.stats.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.md),
                Expanded(child: _HeartRateStatTile(stat: heartRate.stats[i])),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          HeartRateChart(
            samples: heartRate.samples,
            axisLabels: heartRate.axisLabels,
          ),
        ],
      ),
    );
  }
}

class _HeartRateStatTile extends StatelessWidget {
  const _HeartRateStatTile({required this.stat});

  final HeartRateStatItem stat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: AppSizes.s56,
      padding: const EdgeInsets.all(AppSizes.s10),
      decoration: AppShapes.decoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                stat.value,
                style: AppTypography.bodyXLargeBold.copyWith(
                  color: stat.tone.resolve(context),
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                stat.unit,
                style: AppTypography.bodyXSmallRegular.copyWith(
                  color: colors.textQuiet,
                ),
              ),
            ],
          ),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.captionMedium.copyWith(
              color: colors.textQuiet,
            ),
          ),
        ],
      ),
    );
  }
}
