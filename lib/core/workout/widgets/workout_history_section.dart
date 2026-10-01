import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/missed_workout_card.dart';
import 'package:floww/core/workout/widgets/workout_consistency_card.dart';
import 'package:floww/core/workout/widgets/workout_history_card.dart';

class WorkoutHistorySection extends StatelessWidget {
  const WorkoutHistorySection({
    super.key,
    required this.history,
    this.onOpen,
    this.onOpenMissed,
    this.onCatchUp,
    this.isCatchingUp = false,
  });

  final WorkoutHistoryOverviewItem history;
  final ValueChanged<WorkoutHistoryItem>? onOpen;
  final ValueChanged<MissedWorkoutItem>? onOpenMissed;
  final ValueChanged<MissedWorkoutItem>? onCatchUp;
  final bool isCatchingUp;

  @override
  Widget build(BuildContext context) {
    final consistency = history.consistency;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (consistency != null) ...[
          AppPopReveal(
            appearOnMount: true,
            child: WorkoutConsistencyCard(consistency: consistency),
          ),
          SizedBox(height: AppSpacing.xl3),
        ],
        for (var i = 0; i < history.weeks.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.xl3),
          _HistoryWeek(
            week: history.weeks[i],
            onOpen: onOpen,
            onOpenMissed: onOpenMissed,
            onCatchUp: onCatchUp,
            isCatchingUp: isCatchingUp,
          ),
        ],
      ],
    );
  }
}

class _HistoryWeek extends StatelessWidget {
  const _HistoryWeek({
    required this.week,
    required this.onOpen,
    required this.onOpenMissed,
    required this.onCatchUp,
    required this.isCatchingUp,
  });

  final WorkoutHistoryWeekItem week;
  final ValueChanged<WorkoutHistoryItem>? onOpen;
  final ValueChanged<MissedWorkoutItem>? onOpenMissed;
  final ValueChanged<MissedWorkoutItem>? onCatchUp;
  final bool isCatchingUp;

  @override
  Widget build(BuildContext context) {
    final summaryLabel = week.summaryLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPopReveal(
          appearOnMount: true,
          child: Row(
            children: [
              Expanded(
                child: SectionLabel(
                  label: week.title,
                  color: context.colors.textPrimary,
                ),
              ),
              if (summaryLabel != null)
                Text(
                  summaryLabel,
                  style: AppTypography.labelSmallMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < week.entries.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.lg),
          AppPopReveal(
            appearOnMount: true,
            child: _HistoryEntry(
              entry: week.entries[i],
              onOpen: onOpen,
              onOpenMissed: onOpenMissed,
              onCatchUp: onCatchUp,
              isCatchingUp: isCatchingUp,
            ),
          ),
        ],
      ],
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({
    required this.entry,
    required this.onOpen,
    required this.onOpenMissed,
    required this.onCatchUp,
    required this.isCatchingUp,
  });

  final WorkoutHistoryEntryItem entry;
  final ValueChanged<WorkoutHistoryItem>? onOpen;
  final ValueChanged<MissedWorkoutItem>? onOpenMissed;
  final ValueChanged<MissedWorkoutItem>? onCatchUp;
  final bool isCatchingUp;

  @override
  Widget build(BuildContext context) {
    final session = entry.session;
    final missed = entry.missed;
    final onOpen = this.onOpen;
    final onOpenMissed = this.onOpenMissed;
    final onCatchUp = this.onCatchUp;

    if (session != null) {
      return WorkoutHistoryCard(
        session: session,
        onTap: onOpen == null ? null : () => onOpen(session),
      );
    }
    if (missed == null) return const SizedBox.shrink();
    return MissedWorkoutCard(
      missed: missed,
      isActionLoading: isCatchingUp,
      onTap: onOpenMissed == null ? null : () => onOpenMissed(missed),
      onAction: onCatchUp == null ? null : () => onCatchUp(missed),
    );
  }
}
