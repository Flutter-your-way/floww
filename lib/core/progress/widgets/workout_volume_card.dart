import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';
import 'package:floww/core/progress/widgets/progress_bar_chart.dart';
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
    required this.onTap,
    this.onLogWorkout,
  });

  final String title;
  final String rangeLabel;
  final WorkoutVolume volume;
  final String summaryLabel;
  final String emptyTitle;
  final String emptyMessage;
  final String emptyButtonLabel;
  final VoidCallback onTap;
  final VoidCallback? onLogWorkout;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardHeader(
              title: title,
              titleStyle: AppTypography.heading4SemiBold,
              trailing: Text(
                rangeLabel,
                style: AppTypography.bodySmallRegularTight.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              showChevron: true,
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
              ProgressBarChart(bars: volume.bars),
              SizedBox(height: AppSpacing.lg),
              Text(
                summaryLabel,
                style: AppTypography.bodySmallMediumTight.copyWith(
                  color: context.colors.primaryAlt,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
