import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/models/exercise_info.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/core/workout/view_models/workout_completion_view_model.dart';

class ActiveWorkoutViewModel extends ChangeNotifier {
  ActiveWorkoutViewModel(
    this._sessionService,
    this._planService,
    this._programService,
    DateTime date,
  ) : _date = AppDateUtils.dateOnly(date);

  static const Duration _tick = Duration(seconds: 1);
  static const int _secondsPerMinute = 60;
  static const int _persistIntervalSeconds = 20;
  static const String _loadFailure = 'Could not start this workout.';

  final WorkoutSessionService _sessionService;
  final WorkoutPlanService _planService;
  final WorkoutProgramService _programService;
  final DateTime _date;

  Timer? _timer;
  WorkoutSessionEntity? _session;
  WorkoutCompletionResult? _completion;

  bool _isLoading = true;
  bool _disposed = false;
  bool _isPaused = false;
  bool _isFinishing = false;
  bool _isFinished = false;
  bool _completionStarted = false;
  String? _errorMessage;

  int _elapsedSeconds = 0;
  int _restRemaining = 0;
  int _lastPersistedSeconds = 0;
  String? _expandedSectionId;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasSession => _session != null && _session!.exercises.isNotEmpty;

  bool get isFinished => _isFinished;

  bool get shouldStartCompletion =>
      _isFinished && !_completionStarted && _completion != null;

  void markCompletionStarted() => _completionStarted = true;

  bool get isResting => _restRemaining > 0;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final state = await _programService.loadState();
      final plan = await _planService.ensurePlanFor(
        _date,
        activeProgram: state.activeProgram,
      );
      if (plan == null) {
        _errorMessage =
            'There is no workout scheduled for this day. Start a program to '
            'plan your sessions.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      final session = await _sessionService.startSession(plan);
      _session = session;
      _elapsedSeconds = session.durationSeconds;
      _lastPersistedSeconds = _elapsedSeconds;
      _isLoading = false;
      notifyListeners();
      _startTicker();
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _errorMessage = _loadFailure;
      _isLoading = false;
      notifyListeners();
    }
  }

  WorkoutCompletionViewModel? completionViewModel() {
    final completion = _completion;
    if (completion == null) return null;
    return WorkoutCompletionViewModel(_sessionService, completion);
  }

  List<WorkoutEntryEntity> get _exercises => _session?.exercises ?? const [];

  int get _exerciseIndex {
    final exercises = _exercises;
    for (var index = 0; index < exercises.length; index++) {
      final exercise = exercises[index];
      if (!exercise.isSkipped && !exercise.isComplete) return index;
    }
    return exercises.isEmpty ? 0 : exercises.length - 1;
  }

  WorkoutEntryEntity? get _exercise {
    final exercises = _exercises;
    if (exercises.isEmpty) return null;
    return exercises[_exerciseIndex];
  }

  int get _setIndex {
    final exercise = _exercise;
    if (exercise == null) return 0;
    final logged = exercise.sets.length;
    return logged >= exercise.targetSets ? exercise.targetSets - 1 : logged;
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _onTick());
  }

  void _onTick() {
    if (_isPaused || _isFinished) return;
    _elapsedSeconds++;
    if (_restRemaining > 0) _restRemaining--;
    if (_elapsedSeconds - _lastPersistedSeconds >= _persistIntervalSeconds) {
      _lastPersistedSeconds = _elapsedSeconds;
      unawaited(_persist());
    }
    notifyListeners();
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void completeSet() {
    if (_isFinished || _isFinishing) return;
    if (isResting) {
      skipRest();
      return;
    }
    final exercise = _exercise;
    final session = _session;
    if (exercise == null || session == null) return;

    final sets = [
      ...exercise.sets,
      LoggedSetEntry(
        reps: exercise.targetReps,
        loggedAt: DateTime.now(),
        weightKg: exercise.targetWeightKg,
      ),
    ];
    _replaceExercise(exercise.copyWith(sets: sets));
    _restRemaining = exercise.restSeconds;
    notifyListeners();
    unawaited(_persist());
    _finishIfDone();
  }

  void skipRest() {
    if (!isResting) return;
    _restRemaining = 0;
    _expandedSectionId = null;
    notifyListeners();
  }

  void skipExercise() {
    if (_isFinished || _isFinishing) return;
    final exercise = _exercise;
    if (exercise == null) return;
    _restRemaining = 0;
    _expandedSectionId = null;
    _replaceExercise(exercise.copyWith(isSkipped: true));
    notifyListeners();
    unawaited(_persist());
    _finishIfDone();
  }

  void toggleSection(String id) {
    _expandedSectionId = _expandedSectionId == id ? null : id;
    notifyListeners();
  }

  void _replaceExercise(WorkoutEntryEntity exercise) {
    final session = _session;
    if (session == null) return;
    final exercises = [
      for (final entry in session.exercises)
        if (entry.id == exercise.id) exercise else entry,
    ];
    _session = session.copyWith(
      exercises: exercises,
      durationSeconds: _elapsedSeconds,
    );
  }

  Future<void> _persist() async {
    final session = _session;
    if (session == null || _isFinished) return;
    try {
      await _sessionService.saveProgress(
        session.copyWith(durationSeconds: _elapsedSeconds),
      );
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
    }
  }

  bool get _isDone {
    final exercises = _exercises;
    if (exercises.isEmpty) return false;
    for (final exercise in exercises) {
      if (!exercise.isSkipped && !exercise.isComplete) return false;
    }
    return true;
  }

  void _finishIfDone() {
    if (!_isDone || _isFinishing || _isFinished) return;
    unawaited(finish());
  }

  Future<void> finish() async {
    final session = _session;
    if (session == null || _isFinishing || _isFinished) return;
    _isFinishing = true;
    _timer?.cancel();
    try {
      _completion = await _sessionService.completeSession(
        session.copyWith(durationSeconds: _elapsedSeconds),
      );
      _isFinished = true;
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
      _startTicker();
    } finally {
      _isFinishing = false;
      notifyListeners();
    }
  }

  ActiveWorkoutItem? get session {
    final exercise = _exercise;
    if (exercise == null) return null;
    return ActiveWorkoutItem(
      timerLabel: _clockLabel(_elapsedSeconds),
      progress: _progress,
      exerciseLabel: 'Exercise ${_exerciseIndex + 1}/${_exercises.length}',
      setLabel: 'Set ${_setIndex + 1}/${exercise.targetSets}',
      exercise: _itemOf(exercise),
      isResting: isResting,
      isPaused: _isPaused,
      restSecondsLabel: '$_restRemaining',
      primaryActionLabel: isResting ? 'Next Set' : 'Complete Set',
    );
  }

  ActiveExerciseItem _itemOf(WorkoutEntryEntity exercise) {
    final weightLabel = exercise.isBodyweight
        ? 'bodyweight'
        : '${NumberFormatter.grouped(exercise.targetWeightKg!.round())}kg';

    return ActiveExerciseItem(
      name: exercise.name,
      imageUrl: exercise.imageUrl,
      setsValue: '${_setIndex + 1}',
      setsLabel: '/ ${exercise.targetSets} sets',
      repsValue: '${exercise.targetReps}',
      repsLabel: 'reps · $weightLabel',
      setDots: [
        for (var i = 0; i < exercise.targetSets; i++) _statusOf(i, exercise),
      ],
      repsInReserveValue: '${exercise.repsInReserve}',
      repsInReserveLabel: 'Reps in Reserve',
      infoSections: [
        for (final section in _sectionsOf(exercise)) _sectionOf(section),
      ],
    );
  }

  List<ExerciseInfoSection> _sectionsOf(WorkoutEntryEntity exercise) => [
    ExerciseInfoSection(
      id: 'personal-best',
      icon: Icons.emoji_events_outlined,
      title: 'Personal Best',
      tone: ExerciseInfoTone.neutral,
      items: [
        if (exercise.sets.isNotEmpty)
          ExerciseInfoItem(
            label: 'This session',
            text:
                '${exercise.sets.length} sets · '
                '${exercise.completedReps} reps logged',
          ),
      ],
      emptyMessage: 'No sets logged yet. This could be your first!',
    ),
    ExerciseInfoSection(
      id: 'common-mistakes',
      icon: Icons.warning_amber_rounded,
      title: 'Common Mistakes',
      tone: ExerciseInfoTone.negative,
      items: [for (final cue in exercise.mistakes) _itemOfCue(cue)],
      emptyMessage: 'No mistakes recorded for this movement.',
    ),
    ExerciseInfoSection(
      id: 'guidelines',
      icon: Icons.checklist_rounded,
      title: 'Guidelines',
      tone: ExerciseInfoTone.positive,
      items: [for (final cue in exercise.guidelines) _itemOfCue(cue)],
      emptyMessage: 'No guidelines recorded for this movement.',
    ),
    ExerciseInfoSection(
      id: 'equipment',
      icon: Icons.fitness_center,
      title: 'Equipment Required',
      tone: ExerciseInfoTone.positive,
      items: [for (final cue in exercise.equipmentItems) _itemOfCue(cue)],
      emptyMessage: 'No equipment needed.',
    ),
  ];

  ExerciseInfoItem _itemOfCue(ExerciseCueEntry cue) =>
      ExerciseInfoItem(text: cue.text, label: cue.label);

  ActiveSetStatus _statusOf(int index, WorkoutEntryEntity exercise) {
    if (index < exercise.sets.length) return ActiveSetStatus.completed;
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
    var planned = 0;
    var logged = 0;
    for (final exercise in _exercises) {
      planned += exercise.targetSets;
      logged += exercise.isSkipped
          ? exercise.targetSets
          : exercise.sets.length;
    }
    if (planned == 0) return 0;
    return (logged / planned).clamp(0.0, 1.0);
  }

  String _clockLabel(int seconds) {
    final minutes = seconds ~/ _secondsPerMinute;
    final remainder = seconds % _secondsPerMinute;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
