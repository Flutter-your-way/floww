import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/workout/services/workout_catalog_data.dart';
import 'package:floww/core/workout/models/active_workout_args.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/models/workout_shift_offer.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/workout/services/workout_readiness_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/core/workout/services/workout_shift_service.dart';

enum TodaysWorkoutAction { start, resume, viewSummary }

class TodaysWorkoutViewModel extends ChangeNotifier {
  TodaysWorkoutViewModel(
    this._planService,
    this._programService,
    this._sessionService,
    this._readinessService,
    this._access,
    DateTime date, {
    DateTime? catchUpFrom,
  }) : _date = AppDateUtils.dateOnly(date),
       _catchUpFrom = catchUpFrom == null
           ? null
           : AppDateUtils.dateOnly(catchUpFrom),
       _shiftService = WorkoutShiftService(_planService);

  static const int _secondsPerMinute = 60;
  static const String _loadFailure = 'Could not load your planned workout.';
  static const String _shiftFailure = 'Could not move your schedule.';

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

  final WorkoutPlanService _planService;
  final WorkoutProgramService _programService;
  final WorkoutSessionService _sessionService;
  final WorkoutReadinessService _readinessService;
  final PremiumAccessProvider _access;
  final WorkoutShiftService _shiftService;
  final DateTime _date;
  final DateTime? _catchUpFrom;

  WorkoutPlanEntity? _plan;
  WorkoutShiftOffer? _shiftOffer;
  WorkoutSessionEntity? _session;
  List<WorkoutSessionEntity> _history = const [];
  StreamSubscription<List<WorkoutSessionEntity>>? _sessionSubscription;
  bool _isShifting = false;
  WorkoutPlanEntity? _nextPlan;
  ActiveProgramEntry? _activeProgram;
  bool _isLoading = true;
  bool _disposed = false;
  String? _errorMessage;

  DateTime get date => _date;

  bool get isCatchUp => _catchUpFrom != null;

  DateTime get _planDate => _catchUpFrom ?? _date;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasWorkout => _plan != null;

  String get title => isCatchUp
      ? 'Catch-up Workout'
      : AppDateUtils.isSameDay(_date, DateTime.now())
      ? "Today's Workout"
      : "${AppDateUtils.weekdayName(_date)}'s Workout";

  bool get _isRestDay => _plan == null && _activeProgram != null && !isCatchUp;

  IconData get emptyIcon =>
      _isRestDay ? Icons.self_improvement : Icons.calendar_today;

  String get emptyTitle => _isRestDay ? 'Rest day' : 'No workout scheduled';

  String get emptyMessage {
    if (!_isRestDay) {
      return 'Pick a program from the Programs tab and WAVE will schedule your '
          'sessions, or add exercises to build one yourself.';
    }
    final next = _nextPlan;
    final program = _activeProgram!.name;
    if (next == null) {
      return '$program has no session planned for today. Recover well and '
          'check back on your next training day.';
    }
    return '$program has no session planned for today. Your next one is '
        '${next.name} on ${AppDateUtils.weekdayName(next.date)}, '
        '${AppDateUtils.dayMonth(next.date)}.';
  }

  TodaysWorkoutAction get action {
    final session = _session;
    if (session == null) return TodaysWorkoutAction.start;
    if (session.isCompleted) return TodaysWorkoutAction.viewSummary;
    return TodaysWorkoutAction.resume;
  }

  String get startLabel => switch (action) {
    TodaysWorkoutAction.start => 'Start Workout',
    TodaysWorkoutAction.resume => 'Resume Workout',
    TodaysWorkoutAction.viewSummary => 'View Summary',
  };

  String? get sessionId => _session?.id;

  bool get isCompleted => _session?.isCompleted ?? false;

  ActiveWorkoutArgs get activeWorkoutArgs {
    final session = _session;
    return ActiveWorkoutArgs(
      date: _date,
      plan: _plan,
      history: _history,
      session: session != null && session.isInProgress ? session : null,
    );
  }

  List<String?> get imageUrls => [
    for (final exercise in _plan?.exercises ?? const <WorkoutEntryEntity>[])
      exercise.imageUrl ?? WorkoutCatalogData.imageFor(exercise.exerciseId),
  ];

  void _watchSessions() {
    _sessionSubscription?.cancel();
    _sessionSubscription = _sessionService.watchSessionsFor(_date).listen((
      sessions,
    ) {
      _session = _primarySessionOf(sessions);
      notifyListeners();
    }, onError: (_) {});
  }

  WorkoutSessionEntity? _primarySessionOf(List<WorkoutSessionEntity> sessions) {
    WorkoutSessionEntity? inProgress;
    for (final session in sessions) {
      if (!AppDateUtils.isSameDay(session.scheduledDate, _planDate)) continue;
      if (session.isCompleted) return session;
      if (session.isInProgress) inProgress ??= session;
    }
    return inProgress;
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final state = await _programService.loadState();
      _activeProgram = state.activeProgram;
      final history = await _sessionService.loadRecentSessions();
      _history = history;
      final catchUpFrom = _catchUpFrom;
      _plan = catchUpFrom != null
          ? await _planService.loadPlan(catchUpFrom)
          : await _planService.preparePlanFor(
              _date,
              activeProgram: state.activeProgram,
              history: history,
              readiness: () => _readinessService.assess(history),
              adaptive: _access.canUse(PremiumCapability.adaptiveEngine),
            );
      _session = _primarySessionOf([
        for (final session in history)
          if (AppDateUtils.isSameDay(session.date, _date)) session,
      ]);
      _shiftOffer = catchUpFrom != null
          ? null
          : await _shiftService.offerFor(
              date: _date,
              activeProgram: state.activeProgram,
              sessions: history,
              todayPlan: _plan,
            );
      _nextPlan = _isRestDay ? await _planService.nextPlanAfter(_date) : null;
      _errorMessage = null;
      _watchSessions();
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = _loadFailure;
    }
    _isLoading = false;
    notifyListeners();
  }

  bool get isShifting => _isShifting;

  bool get canShift => _shiftOffer != null;

  String get shiftTitle => _shiftOffer?.title ?? '';

  String get shiftMessage => _shiftOffer?.message ?? '';

  String get shiftLabel => _shiftOffer?.actionLabel ?? '';

  Future<void> shiftSchedule() async {
    final active = _activeProgram;
    final offer = _shiftOffer;
    if (active == null || offer == null || _isShifting) return;
    _isShifting = true;
    notifyListeners();
    try {
      await _shiftService.apply(offer, active);
      _isShifting = false;
      await load();
      return;
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = _shiftFailure;
    }
    _isShifting = false;
    notifyListeners();
  }

  IconData get _workoutIcon {
    final plan = _plan;
    if (plan == null) return Icons.fitness_center;
    final source = '${plan.name} ${plan.focus}'.toLowerCase();
    for (final entry in _iconByKeyword.entries) {
      if (source.contains(entry.key)) return entry.value;
    }
    return Icons.fitness_center;
  }

  TodayWorkoutItem? get workout {
    final plan = _plan;
    if (plan == null) return null;
    return TodayWorkoutItem(
      statusLabel: switch (action) {
        TodaysWorkoutAction.start => null,
        TodaysWorkoutAction.resume => 'In Progress',
        TodaysWorkoutAction.viewSummary => 'Completed',
      },
      statusIcon: switch (action) {
        TodaysWorkoutAction.start => null,
        TodaysWorkoutAction.resume => Icons.timelapse_rounded,
        TodaysWorkoutAction.viewSummary => Icons.check_rounded,
      },
      name: plan.name,
      icon: _workoutIcon,
      programLabel: isCatchUp
          ? 'Missed ${AppDateUtils.weekdayName(plan.date)}, '
                '${AppDateUtils.dayMonth(plan.date)} · Catch-up'
          : plan.programLabel,
      stats: [
        WorkoutStatItem(
          icon: Icons.schedule,
          title: 'Duration',
          value: '${plan.durationMinutes}',
          unit: 'min',
        ),
        WorkoutStatItem(
          icon: Icons.track_changes,
          title: 'Focus',
          value: plan.focus,
          unit: '',
        ),
        WorkoutStatItem(
          icon: Icons.bar_chart,
          title: 'Sets',
          value: '${plan.totalSets}',
          unit: 'total',
        ),
      ],
      goalTitle: isCatchUp ? 'Catch-up Goal' : "Today's Goal",
      goal: plan.goal,
      insight: plan.insight,
      exerciseCountLabel: '${plan.exercises.length} exercises',
      exercises: [for (final entry in plan.exercises) _exerciseOf(entry)],
    );
  }

  WorkoutExerciseItem _exerciseOf(WorkoutEntryEntity exercise) {
    final unit = exercise.isTimed ? 'sec' : 'reps';
    return WorkoutExerciseItem(
      id: exercise.id,
      name: exercise.name,
      imageUrl:
          exercise.imageUrl ?? WorkoutCatalogData.imageFor(exercise.exerciseId),
      setsLabel: '${exercise.targetSets} sets x ${exercise.targetReps} $unit',
      weightLabel: exercise.isBodyweight
          ? 'BW'
          : '${NumberFormatter.grouped(exercise.targetWeightKg!.round())} kg',
      restLabel: _restLabel(exercise.restSeconds),
      volumeLabel: exercise.isBodyweight
          ? '—'
          : NumberFormatter.grouped(exercise.targetVolumeKg.round()),
    );
  }

  String _restLabel(int seconds) {
    final minutes = seconds ~/ _secondsPerMinute;
    final remainder = seconds % _secondsPerMinute;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sessionSubscription?.cancel();
    super.dispose();
  }
}
