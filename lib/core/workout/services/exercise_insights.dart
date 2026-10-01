import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/core/workout/models/exercise_info.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';

class ExerciseInsights {
  ExerciseInsights._();

  static const String personalBestId = 'personal-best';

  static String setsSummaryOf(WorkoutEntryEntity entry) {
    final sets = entry.workingSets;
    if (entry.isTimed) {
      return sets.map((set) => '${set.durationSeconds ?? 0}s').join(', ');
    }
    final reps = sets.map((set) => '${set.reps}').join(', ');
    final weight = entry.bestSetWeightKg;
    if (weight == null) return '$reps reps';
    return '$reps @ ${WorkoutMetrics.weightLabel(weight)}kg';
  }

  static String trendLabelOf(List<OneRepMaxPoint> trend) {
    final label = WorkoutMetrics.weightLabel;
    final latest = trend.last.oneRepMaxKg;
    if (trend.length < 2) return '${label(latest)}kg';
    final change = latest - trend.first.oneRepMaxKg;
    final sign = change >= 0 ? '+' : '−';
    return '${label(latest)}kg ($sign${label(change.abs())}kg over '
        '${trend.length} sessions)';
  }

  static List<ExerciseInfoItem> recordItemsOf({
    required List<WorkoutEntryEntity> history,
    required ExerciseBest? best,
    required List<OneRepMaxPoint> trend,
    required bool isTimed,
  }) {
    final label = WorkoutMetrics.weightLabel;
    return [
      if (history.isNotEmpty)
        ExerciseInfoItem(
          label: 'Last time',
          text: setsSummaryOf(history.first),
        ),
      if (best != null && isTimed && best.seconds > 0)
        ExerciseInfoItem(label: 'Longest hold', text: '${best.seconds}s'),
      if (best != null && !isTimed && best.weightKg > 0)
        ExerciseInfoItem(
          label: 'Heaviest set',
          text: '${label(best.weightKg)}kg',
        ),
      if (best != null && !isTimed && best.weightKg == 0 && best.reps > 0)
        ExerciseInfoItem(label: 'Most reps', text: '${best.reps} reps'),
      if (trend.isNotEmpty)
        ExerciseInfoItem(label: 'Estimated 1RM', text: trendLabelOf(trend)),
    ];
  }

  static ExerciseInfoSection personalBestSectionOf(
    List<ExerciseInfoItem> items,
  ) => ExerciseInfoSection(
    id: personalBestId,
    icon: Icons.emoji_events_outlined,
    title: 'Personal Best',
    tone: ExerciseInfoTone.neutral,
    items: items,
    emptyMessage: 'No sets logged yet. This could be your first!',
  );

  static List<ExerciseInfoSection> techniqueSectionsOf({
    required List<ExerciseCueEntry> mistakes,
    required List<ExerciseCueEntry> guidelines,
    required List<ExerciseCueEntry> equipmentItems,
  }) => [
    ExerciseInfoSection(
      id: 'common-mistakes',
      icon: Icons.warning_amber_rounded,
      title: 'Common Mistakes',
      tone: ExerciseInfoTone.negative,
      items: [for (final cue in mistakes) _itemOfCue(cue)],
      emptyMessage: 'No mistakes recorded for this movement.',
    ),
    ExerciseInfoSection(
      id: 'guidelines',
      icon: Icons.checklist_rounded,
      title: 'Guidelines',
      tone: ExerciseInfoTone.positive,
      items: [for (final cue in guidelines) _itemOfCue(cue)],
      emptyMessage: 'No guidelines recorded for this movement.',
    ),
    ExerciseInfoSection(
      id: 'equipment',
      icon: Icons.fitness_center,
      title: 'Equipment Required',
      tone: ExerciseInfoTone.positive,
      items: [for (final cue in equipmentItems) _itemOfCue(cue)],
      emptyMessage: 'No equipment needed.',
    ),
  ];

  static ExerciseInfoItem _itemOfCue(ExerciseCueEntry cue) =>
      ExerciseInfoItem(text: cue.text, label: cue.label);
}
