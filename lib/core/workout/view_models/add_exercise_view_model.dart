import 'package:flutter/material.dart';

import 'package:floww/core/workout/models/add_exercise_view_data.dart';
import 'package:floww/core/workout/models/exercise.dart';
import 'package:floww/core/workout/models/workout_detail.dart';
import 'package:floww/core/workout/services/exercise_service.dart';

class AddExerciseViewModel extends ChangeNotifier {
  AddExerciseViewModel({
    required ExerciseService service,
    required List<AddExerciseSectionOption> sections,
    String? initialSectionId,
  }) : _sections = sections {
    _catalog = service.loadCatalog();
    _sectionId = initialSectionId ?? (sections.isEmpty ? '' : sections.first.id);
  }

  static const int _secondsPerMinute = 60;
  static const int _minSets = 1;
  static const int _maxSets = 10;
  static const int _minReps = 1;
  static const int _maxReps = 60;
  static const int _minRestSeconds = 15;
  static const int _maxRestSeconds = 300;
  static const int _restStepSeconds = 15;
  static const double _minWeightKg = 2.5;
  static const double _maxWeightKg = 300;
  static const double _weightStepKg = 2.5;

  final List<AddExerciseSectionOption> _sections;

  late final List<Exercise> _catalog;

  late String _sectionId;
  String _query = '';
  String? _exerciseId;
  int _sets = 3;
  int _reps = 10;
  int _restSeconds = 60;
  bool _isBodyweight = false;
  double _weightKg = 20;

  String get title => 'Add Exercise';

  String get subtitle => 'Pick a movement and set your targets';

  String get searchHint => 'Search exercises...';

  String get sectionLabel => 'Section';

  String get exerciseLabel => 'Exercise';

  String get targetsLabel => 'Targets';

  String get weightLabel => 'Weight';

  String get bodyweightLabel => 'Bodyweight';

  String get submitLabel => 'Add to Workout';

  String get emptyResultsMessage => 'No exercises match that search.';

  List<AddExerciseSectionOption> get sections => _sections;

  String get selectedSectionId => _sectionId;

  String get query => _query;

  bool get isBodyweight => _isBodyweight;

  bool get canSubmit => _exerciseId != null && _sectionId.isNotEmpty;

  List<AddExercisePickerItem> get results {
    final query = _query.trim().toLowerCase();
    return [
      for (final exercise in _catalog)
        if (query.isEmpty || exercise.name.toLowerCase().contains(query))
          AddExercisePickerItem(
            id: exercise.id,
            name: exercise.name,
            detailLabel: '${exercise.group.label} · ${exercise.equipment.label}',
            isCustom: exercise.isCustom,
            isSelected: exercise.id == _exerciseId,
          ),
    ];
  }

  bool get hasResults => results.isNotEmpty;

  AddExerciseTargetItem get setsTarget => AddExerciseTargetItem(
    label: 'Sets',
    value: '$_sets',
    unit: _sets == 1 ? 'set' : 'sets',
    canDecrease: _sets > _minSets,
    canIncrease: _sets < _maxSets,
  );

  AddExerciseTargetItem get repsTarget => AddExerciseTargetItem(
    label: 'Reps',
    value: '$_reps',
    unit: _reps == 1 ? 'rep' : 'reps',
    canDecrease: _reps > _minReps,
    canIncrease: _reps < _maxReps,
  );

  AddExerciseTargetItem get restTarget => AddExerciseTargetItem(
    label: 'Rest',
    value: _durationLabel(_restSeconds),
    unit: 'min',
    canDecrease: _restSeconds > _minRestSeconds,
    canIncrease: _restSeconds < _maxRestSeconds,
  );

  AddExerciseTargetItem get weightTarget => AddExerciseTargetItem(
    label: weightLabel,
    value: _isBodyweight ? 'BW' : _weightValueLabel(_weightKg),
    unit: _isBodyweight ? '' : 'kg',
    canDecrease: !_isBodyweight && _weightKg > _minWeightKg,
    canIncrease: !_isBodyweight && _weightKg < _maxWeightKg,
  );

  String get summaryLabel {
    final volume = _isBodyweight
        ? 'bodyweight'
        : '${_weightValueLabel(_weightKg)} kg';
    return '$_sets x $_reps · $volume · ${_durationLabel(_restSeconds)} rest';
  }

  void search(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  void selectSection(String id) {
    if (id == _sectionId) return;
    _sectionId = id;
    notifyListeners();
  }

  void selectExercise(String id) {
    if (id == _exerciseId) return;
    _exerciseId = id;
    final exercise = _exerciseById(id);
    if (exercise != null) {
      _isBodyweight = exercise.equipment == Equipment.bodyweight;
    }
    notifyListeners();
  }

  void adjustSets(int delta) {
    final value = (_sets + delta).clamp(_minSets, _maxSets);
    if (value == _sets) return;
    _sets = value;
    notifyListeners();
  }

  void adjustReps(int delta) {
    final value = (_reps + delta).clamp(_minReps, _maxReps);
    if (value == _reps) return;
    _reps = value;
    notifyListeners();
  }

  void adjustRest(int steps) {
    final value = (_restSeconds + steps * _restStepSeconds).clamp(
      _minRestSeconds,
      _maxRestSeconds,
    );
    if (value == _restSeconds) return;
    _restSeconds = value;
    notifyListeners();
  }

  void adjustWeight(int steps) {
    if (_isBodyweight) return;
    final value = (_weightKg + steps * _weightStepKg).clamp(
      _minWeightKg,
      _maxWeightKg,
    );
    if (value == _weightKg) return;
    _weightKg = value;
    notifyListeners();
  }

  void toggleBodyweight() {
    _isBodyweight = !_isBodyweight;
    notifyListeners();
  }

  WorkoutExercise? buildExercise() {
    final id = _exerciseId;
    if (id == null) return null;
    final exercise = _exerciseById(id);
    if (exercise == null) return null;
    return WorkoutExercise(
      id: '$id-${DateTime.now().microsecondsSinceEpoch}',
      name: exercise.name,
      sets: _sets,
      reps: _reps,
      restSeconds: _restSeconds,
      weightKg: _isBodyweight ? null : _weightKg,
    );
  }

  Exercise? _exerciseById(String id) {
    for (final exercise in _catalog) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }

  String _durationLabel(int seconds) {
    final minutes = seconds ~/ _secondsPerMinute;
    final remainder = seconds % _secondsPerMinute;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }

  String _weightValueLabel(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }
}
