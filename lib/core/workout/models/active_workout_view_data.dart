import 'package:flutter/material.dart';

import 'package:floww/core/workout/models/add_exercise_view_data.dart';
import 'package:floww/core/workout/models/exercise_info.dart';
import 'package:floww/core/workout/models/set_type.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';

enum ActiveSetStatus { completed, current, pending }

class TodayWorkoutItem {
  const TodayWorkoutItem({
    required this.name,
    required this.icon,
    required this.programLabel,
    required this.stats,
    required this.goalTitle,
    required this.goal,
    required this.insight,
    required this.exerciseCountLabel,
    required this.exercises,
    this.statusLabel,
    this.statusIcon,
  });

  final String? statusLabel;
  final IconData? statusIcon;
  final String name;
  final IconData icon;
  final String programLabel;
  final List<WorkoutStatItem> stats;
  final String goalTitle;
  final String goal;
  final String insight;
  final String exerciseCountLabel;
  final List<WorkoutExerciseItem> exercises;
}

class ExerciseInfoSectionItem {
  const ExerciseInfoSectionItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.tone,
    required this.items,
    required this.isExpanded,
    this.emptyMessage,
  });

  final String id;
  final IconData icon;
  final String title;
  final ExerciseInfoTone tone;
  final List<ExerciseInfoItem> items;
  final bool isExpanded;
  final String? emptyMessage;
}

class ActiveSetDotItem {
  const ActiveSetDotItem({
    required this.status,
    this.badge = '',
    this.loggedIndex,
  });

  final ActiveSetStatus status;
  final String badge;
  final int? loggedIndex;
}

class SetTypeOption {
  const SetTypeOption({
    required this.type,
    required this.label,
    required this.isSelected,
  });

  final SetType type;
  final String label;
  final bool isSelected;
}

class ActiveSetInputItem {
  const ActiveSetInputItem({
    required this.primary,
    required this.reserve,
    required this.typeOptions,
    this.weight,
  });

  final AddExerciseTargetItem primary;
  final AddExerciseTargetItem? weight;
  final AddExerciseTargetItem reserve;
  final List<SetTypeOption> typeOptions;
}

class ActiveExerciseItem {
  const ActiveExerciseItem({
    required this.name,
    required this.setsValue,
    required this.setsLabel,
    required this.repsValue,
    required this.repsLabel,
    required this.setDots,
    required this.input,
    required this.infoSections,
    this.imageUrl,
    this.lastTimeLabel,
    this.supersetLabel,
  });

  final String name;
  final String setsValue;
  final String setsLabel;
  final String repsValue;
  final String repsLabel;
  final List<ActiveSetDotItem> setDots;
  final ActiveSetInputItem input;
  final List<ExerciseInfoSectionItem> infoSections;
  final String? imageUrl;
  final String? lastTimeLabel;
  final String? supersetLabel;
}

enum ActiveQueueStatus { done, skipped, current, pending }

class ActiveQueueItem {
  const ActiveQueueItem({
    required this.id,
    required this.name,
    required this.detailLabel,
    required this.status,
    this.groupLabel,
  });

  final String id;
  final String name;
  final String detailLabel;
  final ActiveQueueStatus status;
  final String? groupLabel;
}

class ActiveOptionItem {
  const ActiveOptionItem({
    required this.action,
    required this.icon,
    required this.label,
    this.isEnabled = true,
    this.isDestructive = false,
  });

  final ActiveOptionAction action;
  final IconData icon;
  final String label;
  final bool isEnabled;
  final bool isDestructive;
}

enum ActiveOptionAction {
  undoLastSet,
  addSet,
  removeSet,
  swapExercise,
  superset,
  reorder,
  finishEarly,
}

class EditSetItem {
  const EditSetItem({
    required this.title,
    required this.primary,
    required this.reserve,
    required this.typeOptions,
    this.weight,
  });

  final String title;
  final AddExerciseTargetItem primary;
  final AddExerciseTargetItem? weight;
  final AddExerciseTargetItem reserve;
  final List<SetTypeOption> typeOptions;
}

class ActiveWorkoutItem {
  const ActiveWorkoutItem({
    required this.timerLabel,
    required this.progress,
    required this.exerciseLabel,
    required this.setLabel,
    required this.exercise,
    required this.isResting,
    required this.isPaused,
    required this.restSecondsLabel,
    required this.primaryActionLabel,
    required this.canShortenRest,
    this.nextUpLabel,
  });

  final String timerLabel;
  final double progress;
  final String exerciseLabel;
  final String setLabel;
  final ActiveExerciseItem exercise;
  final bool isResting;
  final bool isPaused;
  final String restSecondsLabel;
  final String primaryActionLabel;
  final bool canShortenRest;
  final String? nextUpLabel;
}
