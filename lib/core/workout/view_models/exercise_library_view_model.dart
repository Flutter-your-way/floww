import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/core/workout/models/exercise.dart';
import 'package:floww/core/workout/models/exercise_view_data.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';

class ExerciseLibraryViewModel extends ChangeNotifier {
  ExerciseLibraryViewModel(this._service) {
    _start();
  }

  static const String _loadFailure = 'Could not load your exercise library.';

  final WorkoutCatalogService _service;

  StreamSubscription<List<ExerciseCatalogEntry>>? _subscription;
  List<ExerciseCatalogEntry> _exercises = const [];
  String _query = '';
  MuscleGroup? _expandedGroup = MuscleGroup.chest;
  bool _isLoading = true;
  bool _disposed = false;
  String? _errorMessage;

  String _draftName = '';
  MuscleGroup _draftGroup = MuscleGroup.chest;
  Equipment _draftEquipment = Equipment.barbell;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String get query => _query;

  String get searchHint => 'Search exercises...';

  MuscleGroup? get expandedGroup => _expandedGroup;

  String get draftName => _draftName;

  MuscleGroup get draftGroup => _draftGroup;

  Equipment get draftEquipment => _draftEquipment;

  bool get canSaveDraft => _draftName.trim().isNotEmpty;

  List<MuscleGroup> get muscleGroups => MuscleGroup.values;

  List<Equipment> get equipmentOptions => Equipment.values;

  int get customCount =>
      _exercises.where((exercise) => exercise.isCustom).length;

  bool get hasCustomExercises => customCount > 0;

  String get customCountLabel =>
      '$customCount custom ${customCount == 1 ? 'exercise' : 'exercises'} '
      'added';

  void _start() {
    _subscription?.cancel();
    _subscription = _service.watchExercises().listen((exercises) {
      _exercises = exercises;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: _onError);
  }

  void _onError(Object error) {
    _isLoading = false;
    _errorMessage = error is WorkoutException ? error.message : _loadFailure;
    notifyListeners();
  }

  Future<void> retry() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await _service.ensureSeeded();
    _start();
  }

  List<ExerciseGroupItem> get groups {
    final query = _query.trim().toLowerCase();
    final result = <ExerciseGroupItem>[];
    for (final group in MuscleGroup.values) {
      final matches = [
        for (final exercise in _exercises)
          if (exercise.group == group &&
              (query.isEmpty || exercise.name.toLowerCase().contains(query)))
            exercise,
      ];
      if (matches.isEmpty) continue;
      result.add(
        ExerciseGroupItem(
          group: group,
          title: group.label,
          countLabel:
              '${matches.length} '
              '${matches.length == 1 ? 'Exercise' : 'Exercises'}',
          isExpanded: query.isNotEmpty || _expandedGroup == group,
          exercises: [
            for (final exercise in matches)
              ExerciseRowItem(
                id: exercise.id,
                name: exercise.name,
                isCustom: exercise.isCustom,
                isAdded: exercise.isAdded,
              ),
          ],
        ),
      );
    }
    return result;
  }

  void search(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  void toggleGroup(MuscleGroup group) {
    _expandedGroup = _expandedGroup == group ? null : group;
    notifyListeners();
  }

  Future<void> toggleExercise(String id) async {
    for (final exercise in _exercises) {
      if (exercise.id != id) continue;
      try {
        await _service.setAdded(id, !exercise.isAdded);
      } on WorkoutException catch (error) {
        _onError(error);
      }
      return;
    }
  }

  void updateDraftName(String value) {
    if (value == _draftName) return;
    final wasSavable = canSaveDraft;
    _draftName = value;
    if (wasSavable != canSaveDraft) notifyListeners();
  }

  void selectDraftGroup(MuscleGroup group) {
    if (group == _draftGroup) return;
    _draftGroup = group;
    notifyListeners();
  }

  void selectDraftEquipment(Equipment equipment) {
    if (equipment == _draftEquipment) return;
    _draftEquipment = equipment;
    notifyListeners();
  }

  void resetDraft() {
    _draftName = '';
    _draftGroup = MuscleGroup.chest;
    _draftEquipment = Equipment.barbell;
  }

  Future<void> saveDraft() async {
    if (!canSaveDraft) return;
    final name = _draftName.trim();
    final group = _draftGroup;
    final equipment = _draftEquipment;
    _expandedGroup = group;
    resetDraft();
    notifyListeners();
    try {
      await _service.createCustomExercise(
        name: name,
        group: group,
        equipment: equipment,
      );
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
