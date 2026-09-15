import 'package:flutter/material.dart';

import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/models/today_workout.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/services/workout_service.dart';

class TodaysWorkoutViewModel extends ChangeNotifier {
  TodaysWorkoutViewModel(this._service) {
    _workout = _service.todayWorkout();
  }

  static const int _secondsPerMinute = 60;

  static const Map<String, IconData> _iconByKeyword = {
    'leg': Icons.sports_gymnastics,
    'lower': Icons.sports_gymnastics,
    'squat': Icons.sports_gymnastics,
    'glute': Icons.sports_gymnastics,
    'calf': Icons.sports_gymnastics,
    'quad': Icons.sports_gymnastics,
    'hamstring': Icons.sports_gymnastics,
    'push': Icons.fitness_center,
    'chest': Icons.fitness_center,
    'upper': Icons.fitness_center,
    'pull': Icons.rowing,
    'back': Icons.rowing,
    'core': Icons.accessibility_new,
    'abs': Icons.accessibility_new,
    'cardio': Icons.monitor_heart,
    'run': Icons.monitor_heart,
    'mobility': Icons.self_improvement,
    'yoga': Icons.self_improvement,
    'recovery': Icons.self_improvement,
  };

  final WorkoutService _service;

  late final TodayWorkout _workout;

  String get title => "Today's Workout";

  IconData get _workoutIcon {
    final source = '${_workout.name} ${_workout.focusLabel}'.toLowerCase();
    for (final entry in _iconByKeyword.entries) {
      if (source.contains(entry.key)) return entry.value;
    }
    return Icons.fitness_center;
  }

  TodayWorkoutItem get workout => TodayWorkoutItem(
    name: _workout.name,
    icon: _workoutIcon,
    programLabel: _workout.programLabel,
    stats: [
      WorkoutStatItem(
        icon: Icons.schedule,
        title: 'Duration',
        value: '${_workout.durationMinutes}',
        unit: 'min',
      ),
      WorkoutStatItem(
        icon: Icons.track_changes,
        title: 'Focus',
        value: _workout.focusLabel,
        unit: '',
      ),
      WorkoutStatItem(
        icon: Icons.bar_chart,
        title: 'Recovery',
        value: _workout.recoveryLabel,
        unit: '',
      ),
    ],
    goalTitle: "Today's Goal",
    goal: _workout.goal,
    insight: _workout.insight,
    exerciseCountLabel: '${_workout.exercises.length} exercises',
    exercises: [
      for (final exercise in _workout.exercises) _exerciseOf(exercise),
    ],
  );

  WorkoutExerciseItem _exerciseOf(TodayWorkoutExercise exercise) {
    return WorkoutExerciseItem(
      id: exercise.id,
      name: exercise.name,
      imageUrl: exercise.imageUrl,
      setsLabel: '${exercise.sets} sets x ${exercise.reps} reps',
      weightLabel: exercise.isBodyweight
          ? 'BW'
          : '${NumberFormatter.grouped(exercise.weightKg!.round())} kg',
      restLabel: _restLabel(exercise.restSeconds),
      volumeLabel: exercise.isBodyweight
          ? '—'
          : NumberFormatter.grouped(exercise.volumeKg),
    );
  }

  String _restLabel(int seconds) {
    final minutes = seconds ~/ _secondsPerMinute;
    final remainder = seconds % _secondsPerMinute;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }
}
