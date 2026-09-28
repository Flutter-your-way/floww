import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/models/add_exercise_view_data.dart';
import 'package:floww/core/workout/models/exercise_info.dart';
import 'package:floww/core/workout/models/set_type.dart';
import 'package:floww/core/workout/services/workout_alert_service.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';
import 'package:floww/core/workout/services/workout_progression.dart';
import 'package:floww/core/workout/services/workout_readiness_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/core/workout/view_models/workout_completion_view_model.dart';

class _SetDraft {
  const _SetDraft({
    required this.reps,
    required this.seconds,
    required this.reserve,
    required this.type,
    this.weightKg,
  });

  final int reps;
  final int seconds;
  final double? weightKg;
  final int reserve;
  final SetType type;

  _SetDraft copyWith({
    int? reps,
    int? seconds,
    double? weightKg,
    int? reserve,
    SetType? type,
  }) => _SetDraft(
    reps: reps ?? this.reps,
    seconds: seconds ?? this.seconds,
    weightKg: weightKg ?? this.weightKg,
    reserve: reserve ?? this.reserve,
    type: type ?? this.type,
  );
}

class ActiveWorkoutViewModel extends ChangeNotifier {
  ActiveWorkoutViewModel(
    this._sessionService,
    this._planService,
    this._programService,
    this._catalogService,
    this._readinessService,
    this._alertService,
    DateTime date,
  ) : _date = AppDateUtils.dateOnly(date);

  static const Duration _tick = Duration(seconds: 1);
  static const int _secondsPerMinute = 60;
  static const int _minReps = 0;
  static const int _maxReps = 100;
  static const int _minSeconds = 5;
  static const int _maxSeconds = 900;
  static const int _secondsStep = 5;
  static const double _minWeightKg = 0;
  static const double _maxWeightKg = 500;
  static const double _weightStepKg = 2.5;
  static const int _minReserve = 0;
  static const int _maxReserve = 5;
  static const int _restStepSeconds = 15;
  static const int _maxRestSeconds = 600;
  static const int _minTargetSets = 1;
  static const int _maxTargetSets = 10;
  static const String _loadFailure = 'Could not start this workout.';
  static const String _catalogFailure = 'Could not load alternatives.';

  final WorkoutSessionService _sessionService;
  final WorkoutPlanService _planService;
  final WorkoutProgramService _programService;
  final WorkoutCatalogService _catalogService;
  final WorkoutReadinessService _readinessService;
  final WorkoutAlertService _alertService;
  final DateTime _date;
  final StreamController<void> _restEnded = StreamController<void>.broadcast();

  Timer? _timer;
  StreamSubscription<WorkoutSessionEntity?>? _sessionSubscription;
  WorkoutSessionEntity? _session;
  WorkoutCompletionResult? _completion;
  List<WorkoutSessionEntity> _history = const [];
  Map<String, ExerciseBest> _bests = const {};
  List<ExerciseCatalogEntry> _catalog = const [];
  List<ExerciseCatalogEntry> _alternatives = const [];

  bool _isLoading = true;
  bool _disposed = false;
  bool _isFinishing = false;
  bool _isFinished = false;
  bool _completionStarted = false;
  bool _isCancelled = false;
  bool _isLoadingAlternatives = false;
  String? _errorMessage;

  int _restRemaining = 0;
  String? _expandedSectionId;
  String? _draftKey;
  _SetDraft? _draft;
  int? _editIndex;
  _SetDraft? _editDraft;

  Stream<void> get restEnded => _restEnded.stream;

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
      _history = await _sessionService.loadRecentSessions();
      final plan = await _planService.preparePlanFor(
        _date,
        activeProgram: state.activeProgram,
        history: _history,
        readiness: () => _readinessService.assess(_history),
      );
      if (plan == null) {
        _errorMessage =
            'There is no workout scheduled for this day. Start a program to '
            'plan your sessions.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      var session = await _sessionService.startSession(plan);
      if (plan.sessionId != session.id) {
        await _planService.linkSession(plan.date, session.id);
      }
      if (session.isTimerRunning && session.timerResumedAt == null) {
        session = session.resumedAt(DateTime.now());
        await _sessionService.saveTimer(session);
      }
      _session = session;
      _bests = WorkoutMetrics.bestsOf([
        for (final entry in _history)
          if (entry.id != session.id && entry.isCompleted) entry,
      ]);
      _restRemaining = session.restSecondsAt(DateTime.now());
      _isLoading = false;
      notifyListeners();
      _watchSession(session.id);
      _startTicker();
      unawaited(_alertService.keepAwake(true));
      _scheduleRestAlert();
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
    final currentId = _session?.currentEntryId;
    if (currentId != null) {
      final index = exercises.indexWhere((entry) => entry.id == currentId);
      if (index >= 0 && !exercises[index].isDone) return index;
    }
    for (var index = 0; index < exercises.length; index++) {
      if (!exercises[index].isDone) return index;
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
    final logged = exercise.workingSetCount;
    return logged >= exercise.targetSets ? exercise.targetSets - 1 : logged;
  }

  int get _elapsedSeconds => _session?.elapsedSecondsAt(DateTime.now()) ?? 0;

  bool get _isPaused => _session?.isTimerPaused ?? false;

  bool get _isLocked => _isFinished || _isFinishing || _isCancelled;

  void _watchSession(String id) {
    _sessionSubscription?.cancel();
    _sessionSubscription = _sessionService.watchSession(id).listen((remote) {
      final session = _session;
      if (remote == null || session == null || !remote.isInProgress) return;
      if (remote.isTimerPaused == session.isTimerPaused &&
          remote.timerResumedAt == session.timerResumedAt &&
          remote.durationSeconds == session.durationSeconds &&
          remote.restEndsAt == session.restEndsAt &&
          remote.restRemainingSeconds == session.restRemainingSeconds) {
        return;
      }
      _session = session.copyWith(
        durationSeconds: remote.durationSeconds,
        isTimerPaused: remote.isTimerPaused,
        timerResumedAt: remote.timerResumedAt,
        restEndsAt: remote.restEndsAt,
        restRemainingSeconds: remote.restRemainingSeconds,
        clearRestEnd: remote.restEndsAt == null,
      );
      _restRemaining = _session!.restSecondsAt(DateTime.now());
      _scheduleRestAlert();
      notifyListeners();
    }, onError: (_) {});
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _onTick());
  }

  void _onTick() {
    final session = _session;
    if (session == null || _isFinished) return;
    final previous = _restRemaining;
    _restRemaining = session.restSecondsAt(DateTime.now());
    if (previous > 0 && _restRemaining == 0 && !_isPaused) {
      _restEnded.add(null);
    }
    if (_isPaused && previous == _restRemaining) return;
    notifyListeners();
  }

  void _scheduleRestAlert() {
    final session = _session;
    final endsAt = session?.restEndsAt;
    if (session == null || endsAt == null || session.isTimerPaused) {
      unawaited(_alertService.cancelRestEnd());
      return;
    }
    final exercise = _exercise;
    final label = exercise == null
        ? 'Time for your next set.'
        : 'Up next: ${exercise.name} · Set ${_setIndex + 1}';
    unawaited(_alertService.scheduleRestEnd(endsAt, label));
  }

  Future<void> togglePause() async {
    final session = _session;
    if (session == null || _isLocked) return;
    final now = DateTime.now();
    final updated = session.isTimerPaused
        ? session.resumedAt(now)
        : session.pausedAt(now);
    _session = updated;
    _restRemaining = updated.restSecondsAt(now);
    _scheduleRestAlert();
    notifyListeners();
    try {
      await _sessionService.saveTimer(updated);
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
    }
  }

  String _keyOf(WorkoutEntryEntity exercise) =>
      '${exercise.id}:${exercise.sets.length}';

  _SetDraft _currentDraft(WorkoutEntryEntity exercise) {
    final key = _keyOf(exercise);
    final draft = _draft;
    if (draft != null && _draftKey == key) return draft;
    final created = _defaultDraft(exercise);
    _draftKey = key;
    _draft = created;
    return created;
  }

  _SetDraft _defaultDraft(WorkoutEntryEntity exercise) {
    final previous = exercise.workingSets.isEmpty
        ? null
        : exercise.workingSets.last;
    return _SetDraft(
      reps: previous?.reps ?? exercise.targetReps,
      seconds: previous?.durationSeconds ?? exercise.targetReps,
      weightKg: previous?.weightKg ?? exercise.targetWeightKg,
      reserve: exercise.repsInReserve,
      type: SetType.working,
    );
  }

  void _updateDraft(_SetDraft Function(_SetDraft draft) change) {
    final exercise = _exercise;
    if (exercise == null || _isLocked) return;
    _draft = change(_currentDraft(exercise));
    notifyListeners();
  }

  void adjustPrimary(int delta) {
    if (_exercise?.isTimed ?? false) {
      adjustSeconds(delta);
    } else {
      adjustReps(delta);
    }
  }

  void adjustReps(int delta) => _updateDraft(
    (draft) =>
        draft.copyWith(reps: (draft.reps + delta).clamp(_minReps, _maxReps)),
  );

  void adjustSeconds(int steps) => _updateDraft(
    (draft) => draft.copyWith(
      seconds: (draft.seconds + steps * _secondsStep).clamp(
        _minSeconds,
        _maxSeconds,
      ),
    ),
  );

  void adjustWeight(int steps) => _updateDraft(
    (draft) => draft.copyWith(
      weightKg: ((draft.weightKg ?? 0) + steps * _weightStepKg).clamp(
        _minWeightKg,
        _maxWeightKg,
      ),
    ),
  );

  void adjustReserve(int delta) => _updateDraft(
    (draft) => draft.copyWith(
      reserve: (draft.reserve + delta).clamp(_minReserve, _maxReserve),
    ),
  );

  void selectSetType(SetType type) =>
      _updateDraft((draft) => draft.copyWith(type: type));

  LoggedSetEntry _setOf(WorkoutEntryEntity exercise, _SetDraft draft) =>
      LoggedSetEntry(
        reps: exercise.isTimed ? 0 : draft.reps,
        loggedAt: DateTime.now(),
        weightKg: exercise.isBodyweight ? null : draft.weightKg,
        repsInReserve: draft.reserve,
        type: draft.type,
        durationSeconds: exercise.isTimed ? draft.seconds : null,
      );

  void completeSet() {
    if (_isLocked) return;
    if (isResting) {
      skipRest();
      return;
    }
    final exercise = _exercise;
    final session = _session;
    if (exercise == null || session == null) return;

    final draft = _currentDraft(exercise);
    final logged = exercise.copyWith(
      sets: [...exercise.sets, _setOf(exercise, draft)],
    );
    final exercises = _replaced(session.exercises, logged);
    final next = _nextAfter(logged, exercises, draft.type);
    final now = DateTime.now();
    var updated = session.copyWith(
      exercises: exercises,
      currentEntryId: next.$1,
      clearCurrentEntry: next.$1 == null,
    );
    updated = updated.restingFor(_isDoneIn(exercises) ? 0 : next.$2, now);
    _session = updated;
    _restRemaining = updated.restSecondsAt(now);
    _expandedSectionId = null;
    _scheduleRestAlert();
    notifyListeners();
    unawaited(_persist());
    _finishIfDone();
  }

  (String?, int) _nextAfter(
    WorkoutEntryEntity exercise,
    List<WorkoutEntryEntity> exercises,
    SetType type,
  ) {
    if (type == SetType.warmup) return (exercise.id, exercise.restSeconds ~/ 2);
    final groupId = exercise.groupId;
    if (groupId == null) {
      return (exercise.isDone ? null : exercise.id, exercise.restSeconds);
    }
    final members = [
      for (final entry in exercises)
        if (entry.groupId == groupId && !entry.isDone) entry,
    ];
    if (members.isEmpty) return (null, exercise.restSeconds);
    final round = exercise.workingSetCount;
    final start = exercises.indexWhere((entry) => entry.id == exercise.id);
    for (var offset = 1; offset <= exercises.length; offset++) {
      final candidate = exercises[(start + offset) % exercises.length];
      if (candidate.groupId != groupId || candidate.isDone) continue;
      if (candidate.workingSetCount < round) return (candidate.id, 0);
    }
    return (members.first.id, exercise.restSeconds);
  }

  void skipRest() {
    final session = _session;
    if (!isResting || session == null) return;
    _session = session.copyWith(clearRest: true);
    _restRemaining = 0;
    _expandedSectionId = null;
    _scheduleRestAlert();
    notifyListeners();
    unawaited(_persist());
  }

  void adjustRest(int steps) {
    final session = _session;
    if (!isResting || session == null || _isLocked) return;
    final seconds = (_restRemaining + steps * _restStepSeconds).clamp(
      0,
      _maxRestSeconds,
    );
    if (seconds == 0) {
      skipRest();
      return;
    }
    final now = DateTime.now();
    _session = session.restingFor(seconds, now);
    _restRemaining = _session!.restSecondsAt(now);
    _scheduleRestAlert();
    notifyListeners();
    unawaited(_persist());
  }

  void skipExercise() {
    if (_isLocked) return;
    final exercise = _exercise;
    final session = _session;
    if (exercise == null || session == null) return;
    _expandedSectionId = null;
    _session = session.copyWith(
      exercises: _replaced(
        session.exercises,
        exercise.copyWith(isSkipped: true),
      ),
      clearCurrentEntry: true,
      clearRest: true,
    );
    _restRemaining = 0;
    _scheduleRestAlert();
    notifyListeners();
    unawaited(_persist());
    _finishIfDone();
  }

  bool get canUndo => (_exercise?.sets.isNotEmpty ?? false) && !_isLocked;

  void undoLastSet() {
    final session = _session;
    if (session == null || _isLocked) return;
    WorkoutEntryEntity? target;
    DateTime? latest;
    for (final entry in session.exercises) {
      if (entry.sets.isEmpty) continue;
      final loggedAt = entry.sets.last.loggedAt;
      if (latest == null || loggedAt.isAfter(latest)) {
        latest = loggedAt;
        target = entry;
      }
    }
    if (target == null) return;
    final reverted = target.copyWith(
      sets: target.sets.sublist(0, target.sets.length - 1),
      isSkipped: false,
    );
    _session = session.copyWith(
      exercises: _replaced(session.exercises, reverted),
      currentEntryId: reverted.id,
      clearRest: true,
    );
    _restRemaining = 0;
    _draft = null;
    _scheduleRestAlert();
    notifyListeners();
    unawaited(_persist());
  }

  bool get canAddSet =>
      (_exercise?.targetSets ?? _maxTargetSets) < _maxTargetSets && !_isLocked;

  bool get canRemoveSet {
    final exercise = _exercise;
    if (exercise == null || _isLocked) return false;
    return exercise.targetSets > _minTargetSets &&
        exercise.targetSets > exercise.workingSetCount;
  }

  void addSet() => _changeTargetSets(1);

  void removeSet() => _changeTargetSets(-1);

  void _changeTargetSets(int delta) {
    final exercise = _exercise;
    final session = _session;
    if (exercise == null || session == null) return;
    if (delta > 0 && !canAddSet) return;
    if (delta < 0 && !canRemoveSet) return;
    _session = session.copyWith(
      exercises: _replaced(
        session.exercises,
        exercise.copyWith(targetSets: exercise.targetSets + delta),
      ),
      currentEntryId: exercise.id,
    );
    notifyListeners();
    unawaited(_persist());
    _finishIfDone();
  }

  bool get canFinishEarly {
    if (_isLocked) return false;
    return _exercises.any((entry) => entry.workingSetCount > 0);
  }

  Future<void> finishEarly() async {
    if (!canFinishEarly) return;
    await finish();
  }

  void jumpTo(String id) {
    final session = _session;
    if (session == null || _isLocked) return;
    final index = session.exercises.indexWhere((entry) => entry.id == id);
    if (index < 0) return;
    final entry = session.exercises[index];
    if (entry.isComplete) return;
    _session = session.copyWith(
      exercises: entry.isSkipped
          ? _replaced(session.exercises, entry.copyWith(isSkipped: false))
          : session.exercises,
      currentEntryId: id,
    );
    _expandedSectionId = null;
    _scheduleRestAlert();
    notifyListeners();
    unawaited(_persist());
  }

  void reorder(int oldIndex, int newIndex) {
    final session = _session;
    if (session == null || _isLocked) return;
    final exercises = [...session.exercises];
    if (oldIndex < 0 || oldIndex >= exercises.length) return;
    final moved = exercises.removeAt(oldIndex);
    exercises.insert(newIndex.clamp(0, exercises.length), moved);
    _session = session.copyWith(exercises: exercises);
    notifyListeners();
    unawaited(_persist());
  }

  WorkoutEntryEntity? get _nextPending {
    final exercises = _exercises;
    final index = _exerciseIndex;
    for (var i = index + 1; i < exercises.length; i++) {
      if (!exercises[i].isDone) return exercises[i];
    }
    return null;
  }

  bool get isSuperset => _exercise?.isSuperset ?? false;

  bool get canToggleSuperset {
    if (_isLocked) return false;
    return isSuperset || _nextPending != null;
  }

  void toggleSuperset() {
    final exercise = _exercise;
    final session = _session;
    if (exercise == null || session == null || !canToggleSuperset) return;
    if (exercise.isSuperset) {
      final groupId = exercise.groupId;
      final members = session.exercises
          .where((entry) => entry.groupId == groupId)
          .length;
      _session = session.copyWith(
        exercises: [
          for (final entry in session.exercises)
            if (entry.id == exercise.id ||
                (members <= 2 && entry.groupId == groupId))
              entry.copyWith(clearGroup: true)
            else
              entry,
        ],
      );
    } else {
      final partner = _nextPending!;
      final groupId = partner.groupId ?? 'superset-${exercise.id}';
      final exercises = [...session.exercises]
        ..removeWhere((entry) => entry.id == partner.id);
      final at = exercises.indexWhere((entry) => entry.id == exercise.id);
      exercises.insert(at + 1, partner);
      _session = session.copyWith(
        exercises: [
          for (final entry in exercises)
            if (entry.id == exercise.id || entry.id == partner.id)
              entry.copyWith(groupId: groupId)
            else
              entry,
        ],
        currentEntryId: exercise.id,
      );
    }
    notifyListeners();
    unawaited(_persist());
  }

  bool get canSwap => (_exercise?.sets.isEmpty ?? false) && !_isLocked;

  bool get isLoadingAlternatives => _isLoadingAlternatives;

  Future<void> loadAlternatives() async {
    final exercise = _exercise;
    if (exercise == null) return;
    _isLoadingAlternatives = true;
    _alternatives = const [];
    notifyListeners();
    try {
      if (_catalog.isEmpty) _catalog = await _catalogService.loadExercises();
      _alternatives = WorkoutPlanService.alternativesOf(exercise, _catalog);
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = _catalogFailure;
    }
    _isLoadingAlternatives = false;
    notifyListeners();
  }

  String get swapTitle => 'Swap Exercise';

  String get swapSubtitle =>
      'Alternatives that train the same muscles as ${_exercise?.name ?? ''}';

  String get swapEmptyMessage => 'No close alternatives in your library.';

  List<AddExercisePickerItem> get alternatives => [
    for (final exercise in _alternatives)
      AddExercisePickerItem(
        id: exercise.id,
        name: exercise.name,
        detailLabel: '${exercise.group.label} · ${exercise.equipment.label}',
        isCustom: exercise.isCustom,
        isSelected: false,
      ),
  ];

  void swapTo(String exerciseId) {
    final exercise = _exercise;
    final session = _session;
    if (exercise == null || session == null || !canSwap) return;
    ExerciseCatalogEntry? replacement;
    for (final entry in _alternatives) {
      if (entry.id == exerciseId) replacement = entry;
    }
    if (replacement == null) return;
    final swapped = _planService.swapEntry(
      exercise,
      replacement,
      history: _history,
    );
    _session = session.copyWith(
      exercises: [
        for (final entry in session.exercises)
          if (entry.id == exercise.id) swapped else entry,
      ],
      currentEntryId: swapped.id,
    );
    _draft = null;
    _expandedSectionId = null;
    notifyListeners();
    unawaited(_persist());
  }

  List<ActiveOptionItem> get options => [
    ActiveOptionItem(
      action: ActiveOptionAction.undoLastSet,
      icon: Icons.undo_rounded,
      label: 'Undo last set',
      isEnabled: _exercises.any((entry) => entry.sets.isNotEmpty) && !_isLocked,
    ),
    ActiveOptionItem(
      action: ActiveOptionAction.addSet,
      icon: Icons.add_circle_outline,
      label: 'Add a set',
      isEnabled: canAddSet,
    ),
    ActiveOptionItem(
      action: ActiveOptionAction.removeSet,
      icon: Icons.remove_circle_outline,
      label: 'Remove a set',
      isEnabled: canRemoveSet,
    ),
    ActiveOptionItem(
      action: ActiveOptionAction.swapExercise,
      icon: Icons.swap_horiz_rounded,
      label: 'Swap exercise',
      isEnabled: canSwap,
    ),
    ActiveOptionItem(
      action: ActiveOptionAction.superset,
      icon: Icons.link_rounded,
      label: isSuperset
          ? 'Remove from superset'
          : 'Superset with ${_nextPending?.name ?? 'next exercise'}',
      isEnabled: canToggleSuperset,
    ),
    ActiveOptionItem(
      action: ActiveOptionAction.reorder,
      icon: Icons.format_list_numbered_rounded,
      label: 'Reorder or jump',
      isEnabled: !_isLocked,
    ),
    ActiveOptionItem(
      action: ActiveOptionAction.finishEarly,
      icon: Icons.flag_outlined,
      label: 'Finish workout now',
      isEnabled: canFinishEarly,
      isDestructive: true,
    ),
  ];

  String get optionsTitle => _exercise?.name ?? 'Exercise';

  String get queueTitle => 'Workout Order';

  String get queueSubtitle => 'Drag to reorder, tap to jump to an exercise';

  List<ActiveQueueItem> get queue {
    final currentIndex = _exerciseIndex;
    final exercises = _exercises;
    return [
      for (var i = 0; i < exercises.length; i++)
        ActiveQueueItem(
          id: exercises[i].id,
          name: exercises[i].name,
          detailLabel: _queueDetailOf(exercises[i]),
          status: exercises[i].isComplete
              ? ActiveQueueStatus.done
              : exercises[i].isSkipped
              ? ActiveQueueStatus.skipped
              : i == currentIndex
              ? ActiveQueueStatus.current
              : ActiveQueueStatus.pending,
          groupLabel: exercises[i].isSuperset ? 'Superset' : null,
        ),
    ];
  }

  String _queueDetailOf(WorkoutEntryEntity exercise) {
    final status = exercise.isSkipped
        ? 'Skipped'
        : '${exercise.workingSetCount}/${exercise.targetSets} sets';
    return '${exercise.section.title} · $status';
  }

  void beginEditSet(int loggedIndex) {
    final exercise = _exercise;
    if (exercise == null || _isLocked) return;
    if (loggedIndex < 0 || loggedIndex >= exercise.sets.length) return;
    final set = exercise.sets[loggedIndex];
    _editIndex = loggedIndex;
    _editDraft = _SetDraft(
      reps: set.reps,
      seconds: set.durationSeconds ?? exercise.targetReps,
      weightKg: set.weightKg,
      reserve: set.repsInReserve ?? exercise.repsInReserve,
      type: set.type,
    );
    notifyListeners();
  }

  void _updateEdit(_SetDraft Function(_SetDraft draft) change) {
    final draft = _editDraft;
    if (draft == null) return;
    _editDraft = change(draft);
    notifyListeners();
  }

  void adjustEditPrimary(int delta) {
    if (_exercise?.isTimed ?? false) {
      adjustEditSeconds(delta);
    } else {
      adjustEditReps(delta);
    }
  }

  void adjustEditReps(int delta) => _updateEdit(
    (draft) =>
        draft.copyWith(reps: (draft.reps + delta).clamp(_minReps, _maxReps)),
  );

  void adjustEditSeconds(int steps) => _updateEdit(
    (draft) => draft.copyWith(
      seconds: (draft.seconds + steps * _secondsStep).clamp(
        _minSeconds,
        _maxSeconds,
      ),
    ),
  );

  void adjustEditWeight(int steps) => _updateEdit(
    (draft) => draft.copyWith(
      weightKg: ((draft.weightKg ?? 0) + steps * _weightStepKg).clamp(
        _minWeightKg,
        _maxWeightKg,
      ),
    ),
  );

  void adjustEditReserve(int delta) => _updateEdit(
    (draft) => draft.copyWith(
      reserve: (draft.reserve + delta).clamp(_minReserve, _maxReserve),
    ),
  );

  void selectEditType(SetType type) =>
      _updateEdit((draft) => draft.copyWith(type: type));

  EditSetItem? get editSet {
    final exercise = _exercise;
    final draft = _editDraft;
    final index = _editIndex;
    if (exercise == null || draft == null || index == null) return null;
    return EditSetItem(
      title: 'Edit Set ${index + 1}',
      primary: _primaryTarget(exercise, draft),
      weight: exercise.isBodyweight ? null : _weightTarget(draft),
      reserve: _reserveTarget(draft),
      typeOptions: _typeOptions(draft.type),
    );
  }

  String get editSaveLabel => 'Save Set';

  String get editDeleteLabel => 'Delete Set';

  void saveEditedSet() {
    final exercise = _exercise;
    final session = _session;
    final draft = _editDraft;
    final index = _editIndex;
    if (exercise == null || session == null || draft == null || index == null) {
      return;
    }
    final original = exercise.sets[index];
    final edited = LoggedSetEntry(
      reps: exercise.isTimed ? 0 : draft.reps,
      loggedAt: original.loggedAt,
      weightKg: exercise.isBodyweight ? null : draft.weightKg,
      repsInReserve: draft.reserve,
      type: draft.type,
      durationSeconds: exercise.isTimed ? draft.seconds : null,
    );
    final sets = [...exercise.sets]..[index] = edited;
    _applyEdit(session, exercise.copyWith(sets: sets));
  }

  void deleteEditedSet() {
    final exercise = _exercise;
    final session = _session;
    final index = _editIndex;
    if (exercise == null || session == null || index == null) return;
    final sets = [...exercise.sets]..removeAt(index);
    _applyEdit(session, exercise.copyWith(sets: sets));
  }

  void cancelEdit() {
    _editIndex = null;
    _editDraft = null;
  }

  void _applyEdit(WorkoutSessionEntity session, WorkoutEntryEntity exercise) {
    _session = session.copyWith(
      exercises: _replaced(session.exercises, exercise),
      currentEntryId: exercise.id,
    );
    _editIndex = null;
    _editDraft = null;
    _draft = null;
    notifyListeners();
    unawaited(_persist());
    _finishIfDone();
  }

  void toggleSection(String id) {
    _expandedSectionId = _expandedSectionId == id ? null : id;
    notifyListeners();
  }

  List<WorkoutEntryEntity> _replaced(
    List<WorkoutEntryEntity> exercises,
    WorkoutEntryEntity exercise,
  ) => [
    for (final entry in exercises)
      if (entry.id == exercise.id) exercise else entry,
  ];

  Future<void> _persist() async {
    final session = _session;
    if (session == null || _isFinished || _isCancelled) return;
    try {
      await _sessionService.saveProgress(session);
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
    }
  }

  bool _isDoneIn(List<WorkoutEntryEntity> exercises) {
    if (exercises.isEmpty) return false;
    for (final exercise in exercises) {
      if (!exercise.isDone) return false;
    }
    return true;
  }

  void _finishIfDone() {
    if (!_isDoneIn(_exercises) || _isFinishing || _isFinished) return;
    unawaited(finish());
  }

  Future<bool> cancel() async {
    final session = _session;
    if (session == null || _isLocked) return false;
    _isCancelled = true;
    _timer?.cancel();
    await _sessionSubscription?.cancel();
    try {
      await _sessionService.cancelSession(session.id);
      await _planService.unlinkSession(session.date);
      unawaited(_alertService.cancelRestEnd());
      unawaited(_alertService.keepAwake(false));
      return true;
    } on WorkoutException catch (error) {
      _isCancelled = false;
      _errorMessage = error.message;
      _watchSession(session.id);
      _startTicker();
      notifyListeners();
      return false;
    }
  }

  Future<void> finish() async {
    final session = _session;
    if (session == null || _isFinishing || _isFinished) return;
    _isFinishing = true;
    _timer?.cancel();
    try {
      _completion = await _sessionService.completeSession(
        session.copyWith(durationSeconds: _elapsedSeconds, clearRest: true),
      );
      _isFinished = true;
      _restRemaining = 0;
      unawaited(_alertService.cancelRestEnd());
      unawaited(_alertService.keepAwake(false));
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
      canShortenRest: _restRemaining > _restStepSeconds,
      nextUpLabel:
          'Up next: ${exercise.name} · Set ${_setIndex + 1}/'
          '${exercise.targetSets}',
    );
  }

  ActiveExerciseItem _itemOf(WorkoutEntryEntity exercise) {
    final draft = _currentDraft(exercise);
    final unit = exercise.isTimed ? 'sec' : 'reps';
    final weightLabel = exercise.isBodyweight
        ? 'bodyweight'
        : '${WorkoutMetrics.weightLabel(exercise.targetWeightKg!)}kg';

    return ActiveExerciseItem(
      name: exercise.name,
      imageUrl: exercise.imageUrl,
      setsValue: '${_setIndex + 1}',
      setsLabel: '/ ${exercise.targetSets} sets',
      repsValue: '${exercise.targetReps}',
      repsLabel: '$unit · $weightLabel',
      setDots: _dotsOf(exercise),
      input: ActiveSetInputItem(
        primary: _primaryTarget(exercise, draft),
        weight: exercise.isBodyweight ? null : _weightTarget(draft),
        reserve: _reserveTarget(draft),
        typeOptions: _typeOptions(draft.type),
      ),
      lastTimeLabel: _lastTimeLabelOf(exercise),
      supersetLabel: _supersetLabelOf(exercise),
      infoSections: [
        for (final section in _sectionsOf(exercise)) _sectionOf(section),
      ],
    );
  }

  AddExerciseTargetItem _primaryTarget(
    WorkoutEntryEntity exercise,
    _SetDraft draft,
  ) => exercise.isTimed
      ? AddExerciseTargetItem(
          label: 'Time',
          value: '${draft.seconds}',
          unit: 'sec',
          canDecrease: draft.seconds > _minSeconds,
          canIncrease: draft.seconds < _maxSeconds,
        )
      : AddExerciseTargetItem(
          label: 'Reps',
          value: '${draft.reps}',
          unit: draft.reps == 1 ? 'rep' : 'reps',
          canDecrease: draft.reps > _minReps,
          canIncrease: draft.reps < _maxReps,
        );

  AddExerciseTargetItem _weightTarget(_SetDraft draft) {
    final weight = draft.weightKg ?? 0;
    return AddExerciseTargetItem(
      label: 'Weight',
      value: WorkoutMetrics.weightLabel(weight),
      unit: 'kg',
      canDecrease: weight > _minWeightKg,
      canIncrease: weight < _maxWeightKg,
    );
  }

  AddExerciseTargetItem _reserveTarget(_SetDraft draft) =>
      AddExerciseTargetItem(
        label: 'RIR',
        value: '${draft.reserve}',
        unit: 'in reserve',
        canDecrease: draft.reserve > _minReserve,
        canIncrease: draft.reserve < _maxReserve,
      );

  List<SetTypeOption> _typeOptions(SetType selected) => [
    for (final type in SetType.values)
      SetTypeOption(
        type: type,
        label: type.label,
        isSelected: type == selected,
      ),
  ];

  List<ActiveSetDotItem> _dotsOf(WorkoutEntryEntity exercise) {
    final remaining = exercise.targetSets - exercise.workingSetCount;
    return [
      for (var i = 0; i < exercise.sets.length; i++)
        ActiveSetDotItem(
          status: ActiveSetStatus.completed,
          badge: exercise.sets[i].type.badge,
          loggedIndex: i,
        ),
      for (var i = 0; i < remaining; i++)
        ActiveSetDotItem(
          status: i == 0 ? ActiveSetStatus.current : ActiveSetStatus.pending,
        ),
    ];
  }

  List<WorkoutEntryEntity> _historyOf(WorkoutEntryEntity exercise) =>
      WorkoutProgression.historyOf(
        _history,
        exercise.exerciseId,
        excludeSessionId: _session?.id,
      );

  String? _lastTimeLabelOf(WorkoutEntryEntity exercise) {
    final history = _historyOf(exercise);
    if (history.isEmpty) return null;
    return _setsSummaryOf(history.first);
  }

  String _setsSummaryOf(WorkoutEntryEntity entry) {
    final sets = entry.workingSets;
    if (entry.isTimed) {
      return sets.map((set) => '${set.durationSeconds ?? 0}s').join(', ');
    }
    final reps = sets.map((set) => '${set.reps}').join(', ');
    final weight = entry.bestSetWeightKg;
    if (weight == null) return '$reps reps';
    return '$reps @ ${WorkoutMetrics.weightLabel(weight)}kg';
  }

  String? _supersetLabelOf(WorkoutEntryEntity exercise) {
    final groupId = exercise.groupId;
    if (groupId == null) return null;
    final members = [
      for (final entry in _exercises)
        if (entry.groupId == groupId) entry,
    ];
    final position = members.indexWhere((entry) => entry.id == exercise.id);
    final partners = [
      for (final entry in members)
        if (entry.id != exercise.id) entry.name,
    ];
    return '${position + 1}/${members.length} · with ${partners.join(', ')}';
  }

  List<ExerciseInfoSection> _sectionsOf(WorkoutEntryEntity exercise) => [
    ExerciseInfoSection(
      id: 'personal-best',
      icon: Icons.emoji_events_outlined,
      title: 'Personal Best',
      tone: ExerciseInfoTone.neutral,
      items: _personalBestItemsOf(exercise),
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

  List<ExerciseInfoItem> _personalBestItemsOf(WorkoutEntryEntity exercise) {
    final best = _bests[exercise.exerciseId];
    final history = _historyOf(exercise);
    final trend = WorkoutMetrics.oneRepMaxTrendOf([
      for (final entry in _history)
        if (entry.id != _session?.id) entry,
    ], exercise.exerciseId);
    final label = WorkoutMetrics.weightLabel;
    return [
      if (history.isNotEmpty)
        ExerciseInfoItem(
          label: 'Last time',
          text: _setsSummaryOf(history.first),
        ),
      if (best != null && exercise.isTimed && best.seconds > 0)
        ExerciseInfoItem(label: 'Longest hold', text: '${best.seconds}s'),
      if (best != null && !exercise.isTimed && best.weightKg > 0)
        ExerciseInfoItem(
          label: 'Heaviest set',
          text: '${label(best.weightKg)}kg',
        ),
      if (best != null &&
          !exercise.isTimed &&
          best.weightKg == 0 &&
          best.reps > 0)
        ExerciseInfoItem(label: 'Most reps', text: '${best.reps} reps'),
      if (trend.isNotEmpty)
        ExerciseInfoItem(label: 'Estimated 1RM', text: _trendLabelOf(trend)),
      if (exercise.sets.isNotEmpty)
        ExerciseInfoItem(label: 'This session', text: _setsSummaryOf(exercise)),
    ];
  }

  String _trendLabelOf(List<OneRepMaxPoint> trend) {
    final label = WorkoutMetrics.weightLabel;
    final latest = trend.last.oneRepMaxKg;
    if (trend.length < 2) return '${label(latest)}kg';
    final change = latest - trend.first.oneRepMaxKg;
    final sign = change >= 0 ? '+' : '−';
    return '${label(latest)}kg ($sign${label(change.abs())}kg over '
        '${trend.length} sessions)';
  }

  ExerciseInfoItem _itemOfCue(ExerciseCueEntry cue) =>
      ExerciseInfoItem(text: cue.text, label: cue.label);

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
          : exercise.workingSetCount.clamp(0, exercise.targetSets);
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
    _sessionSubscription?.cancel();
    _restEnded.close();
    unawaited(_alertService.keepAwake(false));
    super.dispose();
  }
}
