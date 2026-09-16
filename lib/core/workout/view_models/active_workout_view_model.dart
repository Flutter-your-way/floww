import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/models/today_workout.dart';
import 'package:floww/core/workout/services/workout_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/core/workout/view_models/workout_completion_view_model.dart';

class ActiveWorkoutViewModel extends ChangeNotifier {
  ActiveWorkoutViewModel(this._service, this._sessionService) {
    _workout = _service.todayWorkout();
    _startTicker();
  }

  static const Duration _tick = Duration(seconds: 1);
  static const int _secondsPerMinute = 60;

  final WorkoutService _service;
  final WorkoutSessionService _sessionService;

  late final TodayWorkout _workout;

  final Set<String> _completedExercises = {};

  Timer? _timer;
  int _completedSets = 0;
  double _completedVolumeKg = 0;
  int _elapsedSeconds = 0;
  int _exerciseIndex = 0;
  int _setIndex = 0;
  int _restRemaining = 0;
  bool _isPaused = false;
  bool _isFinished = false;
  bool _completionStarted = false;
  String? _expandedSectionId;

  bool get isFinished => _isFinished;

  bool get shouldStartCompletion => _isFinished && !_completionStarted;

  void markCompletionStarted() => _completionStarted = true;

  WorkoutCompletionViewModel completionViewModel() =>
      WorkoutCompletionViewModel(_service, _service.completionFor(_workout.id));

  bool get isResting => _restRemaining > 0;

  TodayWorkoutExercise get _exercise => _workout.exercises[_exerciseIndex];

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _onTick());
  }

  void _onTick() {
    if (_isPaused || _isFinished) return;
    _elapsedSeconds++;
    if (_restRemaining > 0) {
      _restRemaining--;
      if (_restRemaining == 0) _advance();
    }
    notifyListeners();
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void completeSet() {
    if (_isFinished) return;
    if (isResting) {
      skipRest();
      return;
    }
    _restRemaining = _exercise.restSeconds;
    notifyListeners();
  }

  void skipRest() {
    if (!isResting) return;
    _restRemaining = 0;
    _advance();
    notifyListeners();
  }

  void skipExercise() {
    if (_isFinished) return;
    _restRemaining = 0;
    _setIndex = 0;
    if (_exerciseIndex + 1 >= _workout.exercises.length) {
      _finish();
    } else {
      _exerciseIndex++;
      _expandedSectionId = null;
    }
    notifyListeners();
  }

  void toggleSection(String id) {
    _expandedSectionId = _expandedSectionId == id ? null : id;
    notifyListeners();
  }

  void _advance() {
    _completedSets++;
    _completedVolumeKg += (_exercise.weightKg ?? 0) * _exercise.reps;
    _completedExercises.add(_exercise.id);
    if (_setIndex + 1 < _exercise.sets) {
      _setIndex++;
      return;
    }
    _setIndex = 0;
    if (_exerciseIndex + 1 >= _workout.exercises.length) {
      _finish();
      return;
    }
    _exerciseIndex++;
    _expandedSectionId = null;
  }

  void _finish() {
    _isFinished = true;
    _timer?.cancel();
    unawaited(
      _sessionService.logSession(
        workoutId: _workout.id,
        name: _workout.name,
        completedAt: DateTime.now(),
        durationSeconds: _elapsedSeconds,
        exerciseCount: _completedExercises.length,
        totalSets: _completedSets,
        volumeKg: _completedVolumeKg,
      ),
    );
  }

  ActiveWorkoutItem get session => ActiveWorkoutItem(
    timerLabel: _clockLabel(_elapsedSeconds),
    progress: _progress,
    exerciseLabel:
        'Exercise ${_exerciseIndex + 1}/${_workout.exercises.length}',
    setLabel: 'Set ${_setIndex + 1}/${_exercise.sets}',
    exercise: _exerciseItem,
    isResting: isResting,
    isPaused: _isPaused,
    restSecondsLabel: '$_restRemaining',
    primaryActionLabel: isResting ? 'Next Set' : 'Complete Set',
  );

  ActiveExerciseItem get _exerciseItem {
    final exercise = _exercise;
    final weightLabel = exercise.isBodyweight
        ? 'bodyweight'
        : '${NumberFormatter.grouped(exercise.weightKg!.round())}kg';

    return ActiveExerciseItem(
      name: exercise.name,
      imageUrl: exercise.imageUrl,
      setsValue: '${_setIndex + 1}',
      setsLabel: '/ ${exercise.sets} sets',
      repsValue: '${exercise.reps}',
      repsLabel: 'reps · $weightLabel',
      setDots: [for (var i = 0; i < exercise.sets; i++) _statusOf(i)],
      repsInReserveValue: '${exercise.repsInReserve}',
      repsInReserveLabel: 'Reps in Reserve',
      infoSections: [
        for (final section in exercise.infoSections) _sectionOf(section),
      ],
    );
  }

  ActiveSetStatus _statusOf(int index) {
    if (index < _setIndex) return ActiveSetStatus.completed;
    if (index == _setIndex) return ActiveSetStatus.current;
    return ActiveSetStatus.pending;
  }

  ExerciseInfoSectionItem _sectionOf(ExerciseInfoSection section) {
    return ExerciseInfoSectionItem(
      id: section.id,
      icon: section.icon,
      title: section.title,
      tone: section.tone,
      items: section.items,
      emptyMessage: section.emptyMessage,
      isExpanded: section.id == _expandedSectionId,
    );
  }

  double get _progress {
    var completed = 0;
    for (var i = 0; i < _exerciseIndex; i++) {
      completed += _workout.exercises[i].sets;
    }
    completed += _setIndex;
    final total = _workout.totalSets;
    if (total == 0) return 0;
    return (completed / total).clamp(0.0, 1.0);
  }

  String _clockLabel(int seconds) {
    final minutes = seconds ~/ _secondsPerMinute;
    final remainder = seconds % _secondsPerMinute;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
