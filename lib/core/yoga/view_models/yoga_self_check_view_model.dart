import 'package:flutter/foundation.dart';

import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/core/yoga/data/yoga_module_data.dart';

class YogaSelfCheckViewModel extends ChangeNotifier {
  YogaSelfCheckViewModel(this._service, this._sessionId);

  final WorkoutSessionService _service;
  final String _sessionId;

  final List<int?> _ratings = List<int?>.filled(
    YogaModuleData.selfCheckStatements.length,
    null,
  );
  bool _isSaving = false;
  String? _errorMessage;

  String get title => 'How did class feel?';

  String get subtitle =>
      'Rate each statement from ${YogaModuleData.selfCheckMin} '
      '(${YogaModuleData.selfCheckMinLabel.toLowerCase()}) to '
      '${YogaModuleData.selfCheckMax} '
      '(${YogaModuleData.selfCheckMaxLabel.toLowerCase()}).';

  List<String> get statements => YogaModuleData.selfCheckStatements;

  List<String> get reflections => YogaModuleData.reflectionQuestions;

  List<int> get scale => [
    for (
      var value = YogaModuleData.selfCheckMin;
      value <= YogaModuleData.selfCheckMax;
      value++
    )
      value,
  ];

  String get minLabel =>
      '${YogaModuleData.selfCheckMin} · ${YogaModuleData.selfCheckMinLabel}';

  String get maxLabel =>
      '${YogaModuleData.selfCheckMax} · ${YogaModuleData.selfCheckMaxLabel}';

  int? ratingAt(int index) => _ratings[index];

  bool get canSave => !_isSaving && _ratings.every((rating) => rating != null);

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  void rate(int index, int value) {
    _ratings[index] = value;
    notifyListeners();
  }

  Future<bool> save() async {
    if (!canSave) return false;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.saveYogaSelfCheck(_sessionId, [
        for (final rating in _ratings) rating!,
      ]);
      return true;
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
