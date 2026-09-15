import 'package:flutter/material.dart';

enum ExerciseInfoTone { positive, negative, neutral }

class ExerciseInfoItem {
  const ExerciseInfoItem({required this.text, this.label});

  final String text;
  final String? label;
}

class ExerciseInfoSection {
  const ExerciseInfoSection({
    required this.id,
    required this.icon,
    required this.title,
    required this.tone,
    required this.items,
    this.emptyMessage,
  });

  final String id;
  final IconData icon;
  final String title;
  final ExerciseInfoTone tone;
  final List<ExerciseInfoItem> items;
  final String? emptyMessage;
}

class TodayWorkoutExercise {
  const TodayWorkoutExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.repsInReserve,
    required this.infoSections,
    this.weightKg,
    this.imageUrl,
  });

  final String id;
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final int repsInReserve;
  final List<ExerciseInfoSection> infoSections;
  final double? weightKg;
  final String? imageUrl;

  bool get isBodyweight => weightKg == null;

  int get volumeKg => isBodyweight ? 0 : (weightKg! * sets * reps).round();
}

class TodayWorkout {
  const TodayWorkout({
    required this.id,
    required this.name,
    required this.programLabel,
    required this.durationMinutes,
    required this.focusLabel,
    required this.recoveryLabel,
    required this.goal,
    required this.insight,
    required this.exercises,
  });

  final String id;
  final String name;
  final String programLabel;
  final int durationMinutes;
  final String focusLabel;
  final String recoveryLabel;
  final String goal;
  final String insight;
  final List<TodayWorkoutExercise> exercises;

  int get totalSets {
    var count = 0;
    for (final exercise in exercises) {
      count += exercise.sets;
    }
    return count;
  }
}
