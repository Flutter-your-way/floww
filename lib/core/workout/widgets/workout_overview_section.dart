import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/heart_rate_card.dart';
import 'package:floww/core/workout/widgets/muscle_focus_card.dart';
import 'package:floww/core/workout/widgets/performance_card.dart';
import 'package:floww/core/workout/widgets/training_effect_card.dart';
import 'package:floww/core/workout/widgets/workout_summary_card.dart';

class WorkoutOverviewSection extends StatelessWidget {
  const WorkoutOverviewSection({
    super.key,
    required this.overview,
    this.showSummary = true,
    this.onViewAnatomy,
    this.onViewDetails,
    this.onSummaryInfo,
    this.onTrainingEffectInfo,
  });

  final WorkoutOverviewItem overview;
  final bool showSummary;
  final VoidCallback? onViewAnatomy;
  final VoidCallback? onViewDetails;
  final VoidCallback? onSummaryInfo;
  final VoidCallback? onTrainingEffectInfo;

  @override
  Widget build(BuildContext context) {
    final heartRate = overview.heartRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSummary) ...[
          WorkoutSummaryCard(summary: overview.summary, onInfo: onSummaryInfo),
          SizedBox(height: AppSpacing.lg),
        ],
        TrainingEffectCard(
          effect: overview.trainingEffect,
          onInfo: onTrainingEffectInfo,
        ),
        SizedBox(height: AppSpacing.lg),
        if (overview.muscles.isNotEmpty) ...[
          MuscleFocusCard(
            muscles: overview.muscles,
            onViewAnatomy: onViewAnatomy,
          ),
          SizedBox(height: AppSpacing.lg),
        ],
        if (heartRate != null) ...[
          HeartRateCard(heartRate: heartRate),
          SizedBox(height: AppSpacing.lg),
        ],
        PerformanceCard(
          performance: overview.performance,
          onViewDetails: onViewDetails,
        ),
      ],
    );
  }
}
