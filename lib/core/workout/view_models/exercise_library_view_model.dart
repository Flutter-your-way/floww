import 'package:flutter/material.dart';

import 'package:floww/core/workout/models/exercise.dart';
import 'package:floww/core/workout/models/exercise_view_data.dart';
import 'package:floww/core/workout/services/exercise_service.dart';

class ExerciseLibraryViewModel extends ChangeNotifier {
  ExerciseLibraryViewModel(this._service) {
    _exercises = [..._service.loadCatalog()];
  }

  final ExerciseService _service;

  late List<Exercise> _exercises;
  String _query = '';
  MuscleGroup? _expandedGroup = MuscleGroup.chest;

  String _draftName = '';
  MuscleGroup _draftGroup = MuscleGroup.chest;
  Equipment _draftEquipment = Equipment.barbell;

  String get query => _query;

  String get searchHint => 'Search exercises...';

  MuscleGroup? get expandedGroup => _expandedGroup;

  String get draftName => _draftName;

  MuscleGroup get draftGroup => _draftGroup;

  Equipment get draftEquipment => _draftEquipment;

  bool get canSaveDraft => _draftName.trim().isNotEmpty;

  List<MuscleGroup> get muscleGroups => MuscleGroup.values;

  List<Equipment> get equipmentOptions => Equipment.values;

  int get customCount => _exercises.where((item) => item.isCustom).length;

  bool get hasCustomExercises => customCount > 0;

  String get customCountLabel =>
      '$customCount custom ${customCount == 1 ? 'exercise' : 'exercises'} '
      'added';

  List<ExerciseGroupItem> get groups {
    final query = _query.trim().toLowerCase();
    final result = <ExerciseGroupItem>[];
    for (final group in MuscleGroup.values) {
      final matches = _exercises
          .where(
            (item) =>
                item.group == group &&
                (query.isEmpty || item.name.toLowerCase().contains(query)),
          )
          .toList();
      if (matches.isEmpty) continue;
      result.add(
        ExerciseGroupItem(
          group: group,
          title: group.label,
          countLabel:
              '${matches.length} ${matches.length == 1 ? 'Exercise' : 'Exercises'}',
          isExpanded: query.isNotEmpty || _expandedGroup == group,
          exercises: [
            for (final item in matches)
              ExerciseRowItem(
                id: item.id,
                name: item.name,
                isCustom: item.isCustom,
                isAdded: item.isAdded,
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

  void toggleExercise(String id) {
    final index = _exercises.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final current = _exercises[index];
    _exercises[index] = current.copyWith(isAdded: !current.isAdded);
    notifyListeners();
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

  void saveDraft() {
    if (!canSaveDraft) return;
    final name = _draftName.trim();
    _exercises.add(
      Exercise(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        group: _draftGroup,
        equipment: _draftEquipment,
        isCustom: true,
        isAdded: true,
      ),
    );
    _expandedGroup = _draftGroup;
    resetDraft();
    notifyListeners();
  }
}
