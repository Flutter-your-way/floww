import 'package:flutter/material.dart';

import 'package:floww/core/workout/models/exercise_info.dart';
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
  });

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

class ActiveExerciseItem {
  const ActiveExerciseItem({
    required this.name,
    required this.setsValue,
    required this.setsLabel,
    required this.repsValue,
    required this.repsLabel,
    required this.setDots,
    required this.repsInReserveValue,
    required this.repsInReserveLabel,
    required this.infoSections,
    this.imageUrl,
  });

  final String name;
  final String setsValue;
  final String setsLabel;
  final String repsValue;
  final String repsLabel;
  final List<ActiveSetStatus> setDots;
  final String repsInReserveValue;
  final String repsInReserveLabel;
  final List<ExerciseInfoSectionItem> infoSections;
  final String? imageUrl;
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
}
