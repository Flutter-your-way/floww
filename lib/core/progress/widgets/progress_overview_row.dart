import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';
import 'package:floww/core/progress/widgets/progress_tone_color.dart';

class ProgressOverviewRow extends StatelessWidget {
  const ProgressOverviewRow({super.key, required this.stats});

  final List<ProgressOverviewStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final stat in stats) ...[
          Expanded(child: ProgressOverviewCard(stat: stat)),
          if (stat != stats.last) SizedBox(width: AppSpacing.md),
        ],
      ],
    );
  }
}

class ProgressOverviewCard extends StatelessWidget {
  const ProgressOverviewCard({super.key, required this.stat});

  static const double _height = AppSizes.s80;
  static const double _iconSize = AppSizes.s14;

  final ProgressOverviewStat stat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: _height,
      clipBehavior: Clip.antiAlias,
      decoration: AppShapes.decoration(
        gradient: context.gradients.darkGlow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: AppShapes.decoration(
              gradient: context.gradients.cardSheen,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      stat.icon,
                      size: _iconSize,
                      color: stat.tone.resolve(context),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        stat.label,
                        style: AppTypography.captionSemiBoldMicro.copyWith(
                          color: colors.textSubtle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  stat.value,
                  style: AppTypography.bodyXLargeBold.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
