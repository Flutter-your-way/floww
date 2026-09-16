import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';
import 'package:floww/core/progress/widgets/progress_card_empty_state.dart';

class WorkoutVolumeCard extends StatelessWidget {
  const WorkoutVolumeCard({
    super.key,
    required this.title,
    required this.rangeLabel,
    required this.volume,
    required this.summaryLabel,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.emptyButtonLabel,
    this.onLogWorkout,
  });

  final String title;
  final String rangeLabel;
  final WorkoutVolume volume;
  final String summaryLabel;
  final String emptyTitle;
  final String emptyMessage;
  final String emptyButtonLabel;
  final VoidCallback? onLogWorkout;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            titleStyle: AppTypography.labelLargeSemiBold,
            trailing: Text(
              rangeLabel,
              style: AppTypography.bodySmallRegularTight.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          if (!volume.hasVolume)
            ProgressCardEmptyState(
              icon: Icons.fitness_center_rounded,
              title: emptyTitle,
              message: emptyMessage,
              buttonLabel: emptyButtonLabel,
              onPressed: onLogWorkout,
            )
          else ...[
            VolumeBarChart(days: volume.days),
            SizedBox(height: AppSpacing.lg),
            Text(
              summaryLabel,
              style: AppTypography.bodySmallMediumTight.copyWith(
                color: context.colors.accentOrange,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class VolumeBarChart extends StatelessWidget {
  const VolumeBarChart({super.key, required this.days});

  static const double _plotHeight = AppSizes.s160;

  final List<VolumeDay> days;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxSets = days.fold<int>(0, (top, day) => math.max(top, day.sets));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _plotHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final day in days) ...[
                Expanded(
                  child: SizedBox(
                    height: maxSets == 0
                        ? 0
                        : _plotHeight * (day.sets / maxSets),
                    child: DecoratedBox(
                      decoration: AppShapes.decoration(
                        color: colors.accentOrange,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.xs),
                        ),
                      ),
                    ),
                  ),
                ),
                if (day != days.last) SizedBox(width: AppSpacing.md),
              ],
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (final day in days) ...[
              Expanded(
                child: Text(
                  day.label,
                  textAlign: TextAlign.center,
                  style: AppTypography.captionMediumSmall.copyWith(
                    color: colors.textFaint,
                  ),
                ),
              ),
              if (day != days.last) SizedBox(width: AppSpacing.md),
            ],
          ],
        ),
      ],
    );
  }
}
