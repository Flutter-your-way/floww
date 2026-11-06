import 'package:flutter/foundation.dart';

import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/workout/models/add_exercise_view_data.dart';
import 'package:floww/core/workout/models/log_workout_view_data.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

class LogWorkoutViewModel extends ChangeNotifier {
  LogWorkoutViewModel({required this._service});

  static const int _secondsPerMinute = 60;
  static const int _defaultMinutes = 45;
  static const int _minMinutes = 5;
  static const int _maxMinutes = 240;
  static const int _minuteStep = 5;
  static const String _defaultName = 'Logged Workout';
  static const String _saveFailure =
      'Could not save your workout. Please try again.';

  final WorkoutSessionService _service;
  final List<WorkoutEntryEntity> _exercises = [];

  String _name = '';
  int _minutes = _defaultMinutes;
  bool _isSaving = false;
  String? _errorMessage;

  String get title => 'Log Workout';

  String get subtitle => 'Add a workout you did on your own today';

  String get nameLabel => 'Name';

  String get nameHint => _defaultName;

  String get exercisesLabel => 'Exercises';

  String get emptyExercisesMessage =>
      'Add each exercise with the sets, reps and weight you did.';

  String get addExerciseLabel => 'Add Exercise';

  String get addExerciseSubmitLabel => 'Add to Log';

  String get durationLabel => 'Duration';

  String get saveLabel => 'Save Workout';

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  bool get canSave => _exercises.isNotEmpty && !_isSaving;

  List<AddExerciseSectionOption> get sections => [
    AddExerciseSectionOption(
      id: WorkoutSectionKind.main.id,
      glyph: WorkoutSectionKind.main.glyph,
      title: WorkoutSectionKind.main.title,
    ),
  ];

  List<LoggedExerciseItem> get exercises => [
    for (final entry in _exercises)
      LoggedExerciseItem(
        id: entry.id,
        name: entry.name,
        summaryLabel: _summaryOf(entry),
      ),
  ];

  AddExerciseTargetItem get durationTarget => AddExerciseTargetItem(
    label: durationLabel,
    value: '$_minutes',
    unit: 'min',
    canDecrease: _minutes > _minMinutes,
    canIncrease: _minutes < _maxMinutes,
  );

  void rename(String value) {
    _name = value;
  }

  void adjustDuration(int steps) {
    final value = (_minutes + steps * _minuteStep).clamp(
      _minMinutes,
      _maxMinutes,
    );
    if (value == _minutes) return;
    _minutes = value;
    notifyListeners();
  }

  void addExercise(WorkoutEntryEntity entry) {
    _exercises.add(entry);
    _errorMessage = null;
    notifyListeners();
  }

  void removeExercise(String id) {
    _exercises.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  Future<String?> save() async {
    if (!canSave) return null;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final name = _name.trim();
      final result = await _service.logManualSession(
        name: name.isEmpty ? _defaultName : name,
        exercises: List.of(_exercises),
        durationSeconds: _minutes * _secondsPerMinute,
      );
      return result.session.id;
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = _saveFailure;
    }
    _isSaving = false;
    notifyListeners();
    return null;
  }

  String _summaryOf(WorkoutEntryEntity entry) {
    final reps = entry.isTimed ? '${entry.targetReps}s' : '${entry.targetReps}';
    final weight = entry.targetWeightKg;
    final load = weight == null
        ? 'bodyweight'
        : '${NumberFormatter.trimmed(weight)} kg';
    return '${entry.targetSets} x $reps · $load';
  }
}
