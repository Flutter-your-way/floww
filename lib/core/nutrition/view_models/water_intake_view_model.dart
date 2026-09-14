import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';

class WaterIntakeViewModel extends ChangeNotifier {
  WaterIntakeViewModel(this._logService, this._date, this._goal)
    : _day = NutritionDay(date: _date, goal: _goal) {
    _subscription = _logService
        .watchLogs(_date, AppDateUtils.addDays(_date, 1))
        .listen(
          (logs) {
            _day = NutritionDay(
              date: _date,
              goal: _goal,
              foodLogs: logs.foods,
              waterLogs: logs.waters,
            );
            notifyListeners();
          },
          onError: (Object error) => debugPrint('water watch failed: $error'),
        );
  }

  static const quickAmounts = [
    WaterQuickAmount(label: 'Small', amountMl: 150),
    WaterQuickAmount(label: 'Glass', amountMl: 250),
    WaterQuickAmount(label: 'Bottle', amountMl: 500),
    WaterQuickAmount(label: 'Large', amountMl: 750),
  ];

  static const int _maxCustomMl = 3000;

  final NutritionLogService _logService;
  final DateTime _date;
  final NutritionGoal _goal;
  NutritionDay _day;
  bool _isCustomOpen = false;
  String _customText = '';
  bool _isSaving = false;
  String? _errorMessage;
  StreamSubscription<NutritionLogs>? _subscription;
  bool _disposed = false;

  bool get canEdit =>
      !_date.isBefore(AppDateUtils.dateOnly(DateTime.now()));

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  String get goalLabel => '${NutritionLabels.liters(_goal.waterMl.toDouble())}L';

  String get remainingLabel =>
      '${NutritionLabels.liters(math.max(0, _goal.waterMl - _day.waterMl))}L';

  String get consumedLabel => NutritionLabels.liters(_day.waterMl);

  double get progress => _day.waterMl / _goal.waterMl;

  String get percentLabel =>
      '${NutritionLabels.percent(progress)} of daily goal';

  String? get foodWaterLabel => _day.foodWaterMl > 0
      ? '${NutritionLabels.number(_day.foodWaterMl)} ml'
      : null;

  List<WaterLogItem> get logs => [
    for (final log in _day.waterLogs)
      WaterLogItem(
        id: log.id,
        amountLabel: '${NutritionLabels.number(log.amountMl)} ml',
        timeLabel: AppDateUtils.time(log.loggedAt),
      ),
  ];

  bool get hasEntries => _day.waterLogs.isNotEmpty || _day.foodWaterMl > 0;

  String get logTitle => switch (AppDateUtils.relativeDay(_date)) {
    'Today' => 'Today\'s Log',
    'Yesterday' => 'Yesterday\'s Log',
    _ => 'Water Log',
  };

  String get emptyLogMessage => canEdit
      ? 'No water logged yet. Tap a quick add size above.'
      : 'No water was logged on this day.';

  bool get isCustomOpen => _isCustomOpen;

  String get customText => _customText;

  int? get _customAmount {
    final amount = int.tryParse(_customText.trim());
    if (amount == null || amount <= 0 || amount > _maxCustomMl) return null;
    return amount;
  }

  bool get canAddCustom => !_isSaving && _customAmount != null;

  String get customHint => 'Amount in ml (max $_maxCustomMl)';

  String get tipMessage =>
      'Drinking water before meals can reduce calorie intake. Aim for a glass '
      '30 minutes before each meal.';

  void toggleCustom() {
    _isCustomOpen = !_isCustomOpen;
    _customText = '';
    notifyListeners();
  }

  void updateCustom(String value) {
    final couldAdd = canAddCustom;
    _customText = value;
    if (couldAdd != canAddCustom) notifyListeners();
  }

  Future<void> addQuick(WaterQuickAmount amount) => _add(amount.amountMl);

  Future<void> addCustom() async {
    final amount = _customAmount;
    if (amount == null || _isSaving) return;
    final added = await _add(amount);
    if (!added) return;
    _isCustomOpen = false;
    _customText = '';
    notifyListeners();
  }

  Future<void> delete(String id) async {
    if (!canEdit) return;
    try {
      await _logService.deleteWaterLog(id);
    } on NutritionLogException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<bool> _add(int amountMl) async {
    if (!canEdit || _isSaving) return false;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _logService.addWaterLog(
        amountMl.toDouble(),
        AppDateUtils.atTimeOf(_date, DateTime.now()),
      );
      return true;
    } on NutritionLogException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
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
