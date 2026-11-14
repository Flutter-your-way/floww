import 'package:flutter/widgets.dart';

import 'package:floww/core/recovery/services/muscle_targeting.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';

class WorkoutEmptyState {
  const WorkoutEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.iconAsset,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? iconAsset;
}

class WorkoutSuggestionItem {
  const WorkoutSuggestionItem({
    required this.eyebrow,
    required this.title,
    required this.metaLabels,
    this.contextLabel,
    this.imageUrl,
    this.actionLabel,
  });

  final String eyebrow;
  final String title;
  final List<String> metaLabels;
  final String? contextLabel;
  final String? actionLabel;
  final String? imageUrl;
}

enum WorkoutAgendaStatus { pending, inProgress, completed }

enum WorkoutAgendaAction { start, resume, focus }

class WorkoutAgendaEntryItem {
  const WorkoutAgendaEntryItem({
    required this.id,
    required this.name,
    required this.tagLabel,
    required this.metaLabel,
    required this.status,
    required this.statusLabel,
    this.action,
    this.actionLabel,
    this.isCatchUp = false,
    this.isFocused = false,
    this.canRemove = false,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String tagLabel;
  final String metaLabel;
  final WorkoutAgendaStatus status;
  final String statusLabel;
  final WorkoutAgendaAction? action;
  final String? actionLabel;
  final bool isCatchUp;
  final bool isFocused;
  final bool canRemove;
  final String? imageUrl;
}

class WorkoutAgendaItem {
  const WorkoutAgendaItem({
    required this.title,
    required this.progressLabel,
    required this.entries,
    this.planLabel,
    this.planProgress,
  });

  final String title;
  final String progressLabel;
  final List<WorkoutAgendaEntryItem> entries;
  final String? planLabel;
  final double? planProgress;
}

class WorkoutPlanBuilderItem {
  const WorkoutPlanBuilderItem({
    required this.title,
    required this.message,
    required this.actionLabel,
    this.errorMessage,
  });

  final String title;
  final String message;
  final String actionLabel;
  final String? errorMessage;
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
    this.imageUrl,
    this.sessionId,
  });

  final String name;
  final String exercisesLabel;
  final String flowPointsLabel;
  final String statusLabel;
  final bool isCompleted;
  final List<WorkoutStatItem> stats;
  final String? imageUrl;
  final String? sessionId;
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
    required this.targets,
    required this.recoveryTip,
  });

  final String subtitle;
  final List<MuscleFocusEntry> muscles;
  final MuscleTargets targets;
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
    this.effectCaption = 'effect',
  });

  final String id;
  final String name;
  final String dateLabel;
  final String effectLabel;
  final String effectCaption;
  final List<WorkoutMetricItem> metrics;
  final String? statusLabel;
  final bool isHighlighted;
}

enum WorkoutDayMark { completed, partial, missed, rest, planned }

class WorkoutDayMarkItem {
  const WorkoutDayMarkItem({
    required this.label,
    required this.mark,
    required this.isToday,
  });

  final String label;
  final WorkoutDayMark mark;
  final bool isToday;
}

class WorkoutConsistencyStat {
  const WorkoutConsistencyStat({
    required this.value,
    required this.label,
    required this.tone,
  });

  final String value;
  final String label;
  final WorkoutStatTone tone;
}

class WorkoutConsistencyItem {
  const WorkoutConsistencyItem({
    required this.periodLabel,
    required this.headline,
    required this.caption,
    required this.progress,
    required this.stats,
    required this.weekdayLabels,
    required this.days,
    required this.legend,
    this.insight,
  });

  final String periodLabel;
  final String headline;
  final String caption;
  final double? progress;
  final List<WorkoutConsistencyStat> stats;
  final List<String> weekdayLabels;
  final List<WorkoutDayMarkItem> days;
  final List<WorkoutDayMark> legend;
  final String? insight;
}

class MissedExerciseItem {
  const MissedExerciseItem({required this.name, required this.targetLabel});

  final String name;
  final String targetLabel;
}

class MissedWorkoutItem {
  const MissedWorkoutItem({
    required this.date,
    required this.name,
    required this.dateLabel,
    required this.detailLabel,
    required this.metrics,
    required this.adviceTitle,
    required this.advice,
    required this.adviceTone,
    required this.musclesLabel,
    required this.exercises,
    required this.goal,
    this.actionLabel,
  });

  final DateTime date;
  final String name;
  final String dateLabel;
  final String detailLabel;
  final List<WorkoutMetricItem> metrics;
  final String adviceTitle;
  final String advice;
  final WorkoutStatTone adviceTone;
  final String musclesLabel;
  final List<MissedExerciseItem> exercises;
  final String goal;
  final String? actionLabel;
}

class WorkoutHistoryEntryItem {
  const WorkoutHistoryEntryItem.session(WorkoutHistoryItem this.session)
    : missed = null;

  const WorkoutHistoryEntryItem.missed(MissedWorkoutItem this.missed)
    : session = null;

  final WorkoutHistoryItem? session;
  final MissedWorkoutItem? missed;
}

class WorkoutHistoryWeekItem {
  const WorkoutHistoryWeekItem({
    required this.title,
    required this.summaryLabel,
    required this.entries,
  });

  final String title;
  final String? summaryLabel;
  final List<WorkoutHistoryEntryItem> entries;
}

class WorkoutHistoryOverviewItem {
  const WorkoutHistoryOverviewItem({
    required this.consistency,
    required this.weeks,
  });

  final WorkoutConsistencyItem? consistency;
  final List<WorkoutHistoryWeekItem> weeks;
}

class WorkoutOverviewItem {
  const WorkoutOverviewItem({
    required this.summary,
    required this.trainingEffect,
    required this.muscles,
    required this.targets,
    required this.heartRate,
    required this.performance,
    this.summaries = const [],
    this.summaryIndex = 0,
  });

  final WorkoutSummaryItem summary;
  final List<WorkoutSummaryItem> summaries;
  final int summaryIndex;
  final TrainingEffectItem? trainingEffect;
  final List<MuscleFocusEntry> muscles;
  final MuscleTargets targets;
  final HeartRateItem? heartRate;
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
    this.imageUrl,
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
  final String? imageUrl;
}

class ActiveProgramItem {
  const ActiveProgramItem({
    required this.name,
    required this.scheduleLabel,
    required this.statusLabel,
    required this.levelLabel,
    required this.progressLabel,
    required this.progress,
    this.isWave = false,
  });

  final String name;
  final String scheduleLabel;
  final String statusLabel;
  final String levelLabel;
  final String progressLabel;
  final double progress;
  final bool isWave;
}

class ProgramScheduleItem {
  const ProgramScheduleItem({
    required this.dayIndex,
    required this.weekdayLabel,
    required this.name,
    required this.detail,
  });

  final int dayIndex;
  final String weekdayLabel;
  final String name;
  final String detail;
}

class ProgramDetailItem {
  const ProgramDetailItem({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    required this.stats,
    required this.schedule,
    required this.warning,
    required this.isActive,
    required this.isCustom,
    this.isPremium = false,
    this.isWave = false,
    this.isCourse = false,
    this.canStart = true,
    this.canCustomize = true,
    this.canAddToday = false,
    this.scheduleLabel = 'Weekly schedule',
    this.addTodayNote,
  });

  final String id;
  final String name;
  final String description;
  final String logo;
  final List<WorkoutStatItem> stats;
  final List<ProgramScheduleItem> schedule;
  final bool isCourse;
  final bool canStart;
  final bool canCustomize;
  final bool canAddToday;
  final String scheduleLabel;
  final String? addTodayNote;
  final String? warning;
  final bool isActive;
  final bool isCustom;
  final bool isPremium;
  final bool isWave;
}

class ProgramWeekdayItem {
  const ProgramWeekdayItem({required this.label, required this.isTraining});

  final String label;
  final bool isTraining;
}

class ProgramItem {
  const ProgramItem({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    required this.metaLabel,
    required this.scheduleLabel,
    required this.weekdays,
    required this.badgeLabel,
    required this.isActive,
    this.isPremium = false,
    this.isWave = false,
  });

  final String id;
  final String name;
  final String description;
  final String logo;
  final String metaLabel;
  final String scheduleLabel;
  final List<ProgramWeekdayItem> weekdays;
  final String? badgeLabel;
  final bool isActive;
  final bool isPremium;
  final bool isWave;
}

class ProgramGoalCardItem {
  const ProgramGoalCardItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.isLocked = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isLocked;
}

class ProgramLevelCardItem {
  const ProgramLevelCardItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.programId,
    this.isCurrent = false,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String? programId;
  final bool isCurrent;
}

class ChallengeItem {
  const ChallengeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.metaLabel,
    required this.imageUrl,
    required this.isDone,
  });

  final String id;
  final String title;
  final String subtitle;
  final String metaLabel;
  final String imageUrl;
  final bool isDone;
}

class ChallengeBoardItem {
  const ChallengeBoardItem({
    required this.weekly,
    required this.others,
    required this.progressLabel,
    required this.rewardLabel,
  });

  final ChallengeItem weekly;
  final List<ProgramItem> others;
  final String progressLabel;
  final String rewardLabel;
}

class WorkoutLevelPeriodItem {
  const WorkoutLevelPeriodItem({
    required this.label,
    required this.sessionsLabel,
    required this.volumeLabel,
    required this.effortLabel,
    required this.progress,
  });

  final String label;
  final String sessionsLabel;
  final String volumeLabel;
  final String effortLabel;
  final double? progress;
}

class WorkoutLevelReportItem {
  const WorkoutLevelReportItem({
    required this.levelLabel,
    required this.verdictTitle,
    required this.verdictMessage,
    required this.isReady,
    required this.periods,
    this.actionLabel,
  });

  final String levelLabel;
  final String verdictTitle;
  final String verdictMessage;
  final bool isReady;
  final List<WorkoutLevelPeriodItem> periods;
  final String? actionLabel;
}

class ProgramCollectionItem {
  const ProgramCollectionItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class ProgramFilterItem<T> {
  const ProgramFilterItem({
    required this.value,
    required this.label,
    required this.isSelected,
  });

  final T value;
  final String label;
  final bool isSelected;
}
