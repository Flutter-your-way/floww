import 'package:flutter/foundation.dart';

import 'package:floww/config/utils/formatters/measurement_converter.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/profile/models/profile_account.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';
import 'package:floww/core/profile/services/profile_service.dart';

class EditDailyTargetsViewModel extends ChangeNotifier {
  EditDailyTargetsViewModel(this._service) {
    load();
  }

  static const double _defaultSteps = 10000;
  static const double _defaultSleep = 8;
  static const double _defaultWater = 3;

  final ProfileService _service;

  List<DailyTargetSpec> _specs = _specsFor(ProfileAccount.empty);
  List<DailyTargetSpec> _savedSpecs = _specsFor(ProfileAccount.empty);
  bool _isLoading = true;
  bool _isSaving = false;
  bool _disposed = false;
  String? _errorMessage;

  String get title => 'Edit Daily Targets';

  String get note =>
      'WAVE adjusts these targets based on your activity. You can always override.';

  String get saveLabel => 'Save Targets';

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  List<DailyTargetSpec> get specs => _specs;

  bool get hasUnsavedChanges {
    if (_isLoading) return false;
    for (var index = 0; index < _specs.length; index++) {
      if (_specs[index].value != _savedSpecs[index].value) return true;
    }
    return false;
  }

  String get unsavedTitle => 'Unsaved changes';

  String get unsavedMessage =>
      'Your daily targets have changed. Save them before leaving?';

  String get discardLabel => 'Discard';

  String valueLabel(DailyTargetSpec spec) {
    if (spec.target == DailyTarget.steps) {
      return NumberFormatter.grouped(spec.value.round());
    }
    return MeasurementConverter.trimmed((spec.value * 2).round() / 2);
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _specs = _specsFor(await _service.loadAccount());
      _savedSpecs = _specs;
    } on ProfileException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<bool> save() async {
    if (_isSaving) return false;
    _isSaving = true;
    _errorMessage = null;
    _notify();

    try {
      await _service.saveDailyTargets(buildDraft());
      _savedSpecs = _specs;
      return true;
    } on ProfileException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  void updateTarget(DailyTarget target, double value) {
    final index = _specs.indexWhere((spec) => spec.target == target);
    if (index == -1) return;
    final spec = _specs[index];
    final snapped =
        (((value - spec.min) / spec.step).round() * spec.step) + spec.min;
    if (snapped == spec.value) return;
    _specs = List<DailyTargetSpec>.of(_specs)
      ..[index] = spec.copyWith(value: snapped);
    _notify();
  }

  DailyTargetsDraft buildDraft() => DailyTargetsDraft(specs: _specs);

  static List<DailyTargetSpec> _specsFor(ProfileAccount account) => [
    DailyTargetSpec(
      target: DailyTarget.steps,
      title: 'Daily Steps',
      unit: 'steps',
      value: _clamp(
        account.stepsTarget ?? _defaultSteps,
        ProfileService.stepsMin,
        ProfileService.stepsMax,
      ),
      min: ProfileService.stepsMin,
      max: ProfileService.stepsMax,
      step: ProfileService.stepsStep,
    ),
    DailyTargetSpec(
      target: DailyTarget.sleep,
      title: 'Sleep Goal',
      unit: 'hrs/night',
      value: _clamp(
        account.sleepTargetHours ?? _defaultSleep,
        ProfileService.sleepMin,
        ProfileService.sleepMax,
      ),
      min: ProfileService.sleepMin,
      max: ProfileService.sleepMax,
      step: ProfileService.sleepStep,
    ),
    DailyTargetSpec(
      target: DailyTarget.water,
      title: 'Water Intake',
      unit: 'liters',
      value: _clamp(
        account.waterTargetLiters ?? _defaultWater,
        ProfileService.waterMin,
        ProfileService.waterMax,
      ),
      min: ProfileService.waterMin,
      max: ProfileService.waterMax,
      step: ProfileService.waterStep,
    ),
  ];

  static double _clamp(double value, double min, double max) =>
      value < min ? min : (value > max ? max : value);

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
