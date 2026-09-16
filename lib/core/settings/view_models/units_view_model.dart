import 'package:flutter/foundation.dart';

import 'package:floww/core/profile/services/profile_service.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';
import 'package:floww/core/settings/services/settings_service.dart';

class UnitsViewModel extends ChangeNotifier {
  UnitsViewModel(this._service, this._profileService) {
    load();
  }

  final SettingsService _service;
  final ProfileService _profileService;

  MeasurementSystem _selected = MeasurementSystem.metric;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _disposed = false;
  String? _errorMessage;

  String get title => 'Units & Measurements';

  String get note =>
      'Changing units updates all weight, height, and distance displays '
      'throughout the app.';

  String get saveLabel => 'Save Preference';

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  List<MeasurementOption> get options => _service.measurementOptions();

  MeasurementSystem get selected => _selected;

  bool isSelected(MeasurementSystem system) => _selected == system;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _selected = (await _profileService.loadAccount()).unitSystem;
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
      await _profileService.saveMeasurementSystem(_selected);
      return true;
    } on ProfileException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  void select(MeasurementSystem system) {
    if (_selected == system) return;
    _selected = system;
    _notify();
  }

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
