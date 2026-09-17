import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';

class TodaysWorkoutViewModel extends ChangeNotifier {
  TodaysWorkoutViewModel(this._planService, this._programService, DateTime date)
    : _date = AppDateUtils.dateOnly(date);

  static const int _secondsPerMinute = 60;
  static const String _loadFailure = 'Could not load your planned workout.';

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
  final DateTime _date;

  WorkoutPlanEntity? _plan;
  WorkoutPlanEntity? _nextPlan;
  ActiveProgramEntry? _activeProgram;
  bool _isLoading = true;
  bool _disposed = false;
  String? _errorMessage;

  DateTime get date => _date;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasWorkout => _plan != null;

  String get title => AppDateUtils.isSameDay(_date, DateTime.now())
      ? "Today's Workout"
      : "${AppDateUtils.weekdayName(_date)}'s Workout";

  bool get _isRestDay => _plan == null && _activeProgram != null;

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

  String get startLabel => 'Start Workout';

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final state = await _programService.loadState();
      _activeProgram = state.activeProgram;
      _plan = await _planService.ensurePlanFor(
        _date,
        activeProgram: state.activeProgram,
      );
      _nextPlan = _plan == null && _activeProgram != null
          ? await _planService.nextPlanAfter(_date)
          : null;
      _errorMessage = null;
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = _loadFailure;
    }
    _isLoading = false;
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
      name: plan.name,
      icon: _workoutIcon,
      programLabel: plan.programLabel,
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
      goalTitle: "Today's Goal",
      goal: plan.goal,
      insight: plan.insight,
      exerciseCountLabel: '${plan.exercises.length} exercises',
      exercises: [for (final entry in plan.exercises) _exerciseOf(entry)],
    );
  }

  WorkoutExerciseItem _exerciseOf(WorkoutEntryEntity exercise) {
    return WorkoutExerciseItem(
      id: exercise.id,
      name: exercise.name,
      imageUrl: exercise.imageUrl,
      setsLabel: '${exercise.targetSets} sets x ${exercise.targetReps} reps',
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
    super.dispose();
  }
}
