import 'package:flutter/widgets.dart';

import 'package:floww/core/workout/models/workout_detail.dart';

class WorkoutEmptyState {
  const WorkoutEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}

class WorkoutSuggestionItem {
  const WorkoutSuggestionItem({
    required this.title,
    required this.durationLabel,
    required this.intensityLabel,
    required this.reasons,
  });

  final String title;
  final String durationLabel;
  final String intensityLabel;
  final List<String> reasons;
}

enum WorkoutStatTone { neutral, accent, alert, ember, warning }

class WorkoutStatItem {
  const WorkoutStatItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String title;
  final String value;
  final String unit;
}

class WorkoutSummaryItem {
  const WorkoutSummaryItem({
    required this.name,
    required this.exercisesLabel,
    required this.flowPointsLabel,
    required this.statusLabel,
    required this.isCompleted,
    required this.stats,
  });

  final String name;
  final String exercisesLabel;
  final String flowPointsLabel;
  final String statusLabel;
  final bool isCompleted;
  final List<WorkoutStatItem> stats;
}

class TrainingEffectItem {
  const TrainingEffectItem({
    required this.score,
    required this.rating,
    required this.summary,
    required this.filledSegments,
    required this.totalSegments,
    required this.recoveryLabel,
    required this.recoveryValue,
  });

  final String score;
  final String rating;
  final String summary;
  final int filledSegments;
  final int totalSegments;
  final String recoveryLabel;
  final String recoveryValue;
}

class MuscleFocusEntry {
  const MuscleFocusEntry({
    required this.name,
    required this.shareLabel,
    required this.share,
    this.highlight,
  });

  final String name;
  final String shareLabel;
  final double share;
  final String? highlight;
}

class MuscleAnatomyItem {
  const MuscleAnatomyItem({
    required this.subtitle,
    required this.muscles,
    required this.recoveryTip,
  });

  final String subtitle;
  final List<MuscleFocusEntry> muscles;
  final String recoveryTip;
}

class HeartRateStatItem {
  const HeartRateStatItem({
    required this.value,
    required this.unit,
    required this.label,
    required this.tone,
  });

  final String value;
  final String unit;
  final String label;
  final WorkoutStatTone tone;
}

class HeartRateItem {
  const HeartRateItem({
    required this.stats,
    required this.samples,
    required this.axisLabels,
  });

  final List<HeartRateStatItem> stats;
  final List<double> samples;
  final List<String> axisLabels;
}

class PerformanceStatItem {
  const PerformanceStatItem({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final WorkoutStatTone tone;
}

class PersonalRecordItem {
  const PersonalRecordItem({required this.label, required this.improvement});

  final String label;
  final String improvement;
}

class PerformanceItem {
  const PerformanceItem({required this.stats, required this.records});

  final List<PerformanceStatItem> stats;
  final List<PersonalRecordItem> records;
}

class WorkoutMetricItem {
  const WorkoutMetricItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class WorkoutHistoryItem {
  const WorkoutHistoryItem({
    required this.id,
    required this.name,
    required this.dateLabel,
    required this.effectLabel,
    required this.metrics,
    required this.statusLabel,
    required this.isHighlighted,
  });

  final String id;
  final String name;
  final String dateLabel;
  final String effectLabel;
  final List<WorkoutMetricItem> metrics;
  final String? statusLabel;
  final bool isHighlighted;
}

class WorkoutOverviewItem {
  const WorkoutOverviewItem({
    required this.summary,
    required this.trainingEffect,
    required this.muscles,
    required this.heartRate,
    required this.performance,
  });

  final WorkoutSummaryItem summary;
  final TrainingEffectItem trainingEffect;
  final List<MuscleFocusEntry> muscles;
  final HeartRateItem heartRate;
  final PerformanceItem performance;
}

class WorkoutExerciseItem {
  const WorkoutExerciseItem({
    required this.id,
    required this.name,
    required this.setsLabel,
    required this.weightLabel,
    required this.restLabel,
    required this.volumeLabel,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String setsLabel;
  final String weightLabel;
  final String restLabel;
  final String volumeLabel;
  final String? imageUrl;
}

class WorkoutSectionItem {
  const WorkoutSectionItem({
    required this.id,
    required this.glyph,
    required this.title,
    required this.countLabel,
    required this.status,
    required this.isExpanded,
    required this.exercises,
  });

  final String id;
  final String glyph;
  final String title;
  final String countLabel;
  final WorkoutSectionStatus status;
  final bool isExpanded;
  final List<WorkoutExerciseItem> exercises;
}

class WorkoutDetailItem {
  const WorkoutDetailItem({
    required this.name,
    required this.dateLabel,
    required this.statusLabel,
    required this.isCompleted,
    required this.stats,
    required this.exerciseCountLabel,
    required this.sections,
    required this.insightTitle,
    required this.insightMessage,
    required this.notes,
  });

  final String name;
  final String dateLabel;
  final String statusLabel;
  final bool isCompleted;
  final List<WorkoutStatItem> stats;
  final String exerciseCountLabel;
  final List<WorkoutSectionItem> sections;
  final String insightTitle;
  final String insightMessage;
  final String notes;
}

class ActiveProgramItem {
  const ActiveProgramItem({
    required this.name,
    required this.scheduleLabel,
    required this.statusLabel,
    required this.levelLabel,
    required this.progressLabel,
    required this.progress,
  });

  final String name;
  final String scheduleLabel;
  final String statusLabel;
  final String levelLabel;
  final String progressLabel;
  final double progress;
}

class ProgramDetailItem {
  const ProgramDetailItem({
    required this.id,
    required this.name,
    required this.description,
    required this.stats,
    required this.warning,
    required this.startLabel,
  });

  final String id;
  final String name;
  final String description;
  final List<WorkoutStatItem> stats;
  final String? warning;
  final String startLabel;
}

class ProgramItem {
  const ProgramItem({
    required this.id,
    required this.name,
    required this.detail,
  });

  final String id;
  final String name;
  final String detail;
}
