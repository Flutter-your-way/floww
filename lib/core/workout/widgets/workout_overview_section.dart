import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/premium/widgets/premium_gate.dart';
import 'package:floww/core/premium/widgets/premium_locked_card.dart';
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
    this.revealTrigger,
    this.onViewAnatomy,
    this.onViewDetails,
    this.onSummaryInfo,
    this.onTrainingEffectInfo,
  });

  final WorkoutOverviewItem? overview;
  final bool showSummary;
  final Object? revealTrigger;
  final VoidCallback? onViewAnatomy;
  final VoidCallback? onViewDetails;
  final VoidCallback? onSummaryInfo;
  final VoidCallback? onTrainingEffectInfo;

  @override
  Widget build(BuildContext context) {
    final overview = this.overview;
    final heartRate = overview?.heartRate;
    final spacing = EdgeInsets.only(bottom: AppSpacing.lg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPopReveal(
          trigger: revealTrigger,
          appearOnMount: true,
          child: overview != null && showSummary
              ? Padding(
                  padding: spacing,
                  child: WorkoutSummaryCard(
                    summary: overview.summary,
                    onInfo: onSummaryInfo,
                    onTap: onViewDetails,
                  ),
                )
              : null,
        ),
        AppPopReveal(
          trigger: revealTrigger,
          appearOnMount: true,
          child: overview != null
              ? Padding(
                  padding: spacing,
                  child: PremiumGate(
                    capability: PremiumCapability.advancedAnalytics,
                    placeholder: const SizedBox.shrink(),
                    locked: const PremiumLockedCard(
                      capability: PremiumCapability.advancedAnalytics,
                    ),
                    child: TrainingEffectCard(
                      effect: overview.trainingEffect,
                      onInfo: onTrainingEffectInfo,
                    ),
                  ),
                )
              : null,
        ),
        AppPopReveal(
          trigger: revealTrigger,
          appearOnMount: true,
          child: overview != null && overview.muscles.isNotEmpty
              ? Padding(
                  padding: spacing,
                  child: MuscleFocusCard(
                    muscles: overview.muscles,
                    onViewAnatomy: onViewAnatomy,
                  ),
                )
              : null,
        ),
        AppPopReveal(
          trigger: revealTrigger,
          appearOnMount: true,
          child: heartRate != null
              ? Padding(
                  padding: spacing,
                  child: HeartRateCard(heartRate: heartRate),
                )
              : null,
        ),
        AppPopReveal(
          trigger: revealTrigger,
          appearOnMount: true,
          child: overview != null
              ? PremiumGate(
                  capability: PremiumCapability.advancedAnalytics,
                  placeholder: const SizedBox.shrink(),
                  locked: const SizedBox.shrink(),
                  child: PerformanceCard(
                    performance: overview.performance,
                    onViewDetails: onViewDetails,
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
