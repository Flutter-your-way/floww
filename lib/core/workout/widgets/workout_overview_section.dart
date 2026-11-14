import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/premium/widgets/premium_gate.dart';
import 'package:floww/core/premium/widgets/premium_locked_card.dart';
import 'package:floww/core/recovery/models/muscle_body_side.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/heart_rate_card.dart';
import 'package:floww/core/workout/widgets/indexed_content_switcher.dart';
import 'package:floww/core/workout/widgets/muscle_focus_card.dart';
import 'package:floww/core/workout/widgets/performance_card.dart';
import 'package:floww/core/workout/widgets/training_effect_card.dart';
import 'package:floww/core/workout/widgets/workout_summary_card.dart';
import 'package:floww/core/workout/widgets/workout_summary_carousel.dart';

class WorkoutOverviewSection extends StatelessWidget {
  const WorkoutOverviewSection({
    super.key,
    required this.overview,
    required this.muscleMapOf,
    this.showSummary = true,
    this.showInsights = true,
    this.revealTrigger,
    this.onViewAnatomy,
    this.onViewDetails,
    this.onSummaryTap,
    this.onSummaryInfo,
    this.onTrainingEffectInfo,
    this.onSelectSummary,
    this.onOpenSummary,
  });

  final WorkoutOverviewItem? overview;
  final MuscleMapTemplate? Function(MuscleBodySide side) muscleMapOf;
  final bool showSummary;
  final bool showInsights;
  final Object? revealTrigger;
  final VoidCallback? onViewAnatomy;
  final VoidCallback? onViewDetails;
  final VoidCallback? onSummaryTap;
  final VoidCallback? onSummaryInfo;
  final VoidCallback? onTrainingEffectInfo;
  final ValueChanged<String>? onSelectSummary;
  final ValueChanged<String>? onOpenSummary;

  @override
  Widget build(BuildContext context) {
    final overview = this.overview;
    final insights = showInsights ? overview : null;
    final heartRate = insights?.heartRate;
    final trainingEffect = insights?.trainingEffect;
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
                  child: _SummarySlot(
                    overview: overview,
                    onInfo: onSummaryInfo,
                    onTap: onSummaryTap ?? onViewDetails,
                    onSelect: onSelectSummary,
                    onOpen: onOpenSummary,
                  ),
                )
              : null,
        ),
        IndexedContentSwitcher(
          index: overview?.summaryIndex ?? 0,
          child: KeyedSubtree(
            key: ValueKey(overview?.summary.sessionId),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPopReveal(
                  trigger: revealTrigger,
                  appearOnMount: true,
                  child: trainingEffect != null
                      ? Padding(
                          padding: spacing,
                          child: PremiumGate(
                            capability: PremiumCapability.advancedAnalytics,
                            placeholder: const SizedBox.shrink(),
                            locked: const PremiumLockedCard(
                              capability: PremiumCapability.advancedAnalytics,
                            ),
                            child: TrainingEffectCard(
                              effect: trainingEffect,
                              onInfo: onTrainingEffectInfo,
                            ),
                          ),
                        )
                      : null,
                ),
                AppPopReveal(
                  trigger: revealTrigger,
                  appearOnMount: true,
                  child: insights != null && insights.muscles.isNotEmpty
                      ? Padding(
                          padding: spacing,
                          child: MuscleFocusCard(
                            muscles: insights.muscles,
                            targets: insights.targets,
                            templateOf: muscleMapOf,
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
                  child: insights != null
                      ? PremiumGate(
                          capability: PremiumCapability.advancedAnalytics,
                          placeholder: const SizedBox.shrink(),
                          locked: const SizedBox.shrink(),
                          child: PerformanceCard(
                            performance: insights.performance,
                            onViewDetails: onViewDetails,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummarySlot extends StatelessWidget {
  const _SummarySlot({
    required this.overview,
    this.onInfo,
    this.onTap,
    this.onSelect,
    this.onOpen,
  });

  final WorkoutOverviewItem overview;
  final VoidCallback? onInfo;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSelect;
  final ValueChanged<String>? onOpen;

  @override
  Widget build(BuildContext context) {
    final onSelect = this.onSelect;
    final onOpen = this.onOpen;
    final summaries = overview.summaries;
    if (summaries.length < 2 || onSelect == null || onOpen == null) {
      return WorkoutSummaryCard(
        summary: overview.summary,
        onInfo: onInfo,
        onTap: onTap,
      );
    }
    return WorkoutSummaryCarousel(
      key: ValueKey(summaries.length),
      summaries: summaries,
      index: overview.summaryIndex,
      onSelect: onSelect,
      onOpen: onOpen,
      onInfo: onInfo,
    );
  }
}
