import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';

class FoodLogHistoryViewModel extends ChangeNotifier {
  FoodLogHistoryViewModel(this._logService) {
    _subscription = _logService
        .watchRecentFoodLogs(limit: _historyLimit)
        .listen(
          (logs) {
            _logs = logs;
            _isLoading = false;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('food log history failed: $error');
            _isLoading = false;
            _errorMessage = 'Could not load your food log history.';
            notifyListeners();
          },
        );
  }

  static const int _historyLimit = 100;

  final NutritionLogService _logService;
  StreamSubscription<List<FoodLog>>? _subscription;
  List<FoodLog> _logs = const [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _disposed = false;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isEmpty => !_isLoading && _logs.isEmpty;

  String get emptyTitle => 'No foods logged yet';

  String get emptyMessage =>
      'Scan a meal or tap Log Food on the Nutrition tab. Everything you log '
      'shows up here.';

  String get footnote =>
      'Showing your last ${NutritionLabels.count(_logs.length, 'food', 'foods')}. '
      'Tap a food to log it again today.';

  DateTime get today => AppDateUtils.dateOnly(DateTime.now());

  List<FoodLogHistoryGroup> get groups {
    final byDay = <DateTime, List<FoodLog>>{};
    for (final log in _logs) {
      byDay.putIfAbsent(AppDateUtils.dateOnly(log.loggedAt), () => []).add(log);
    }
    return [
      for (final entry in byDay.entries)
        FoodLogHistoryGroup(
          dateLabel: AppDateUtils.relativeDay(entry.key),
          totalLabel: NutritionLabels.kcal(
            entry.value.fold(0, (total, log) => total + log.macros.calories),
          ),
          items: [for (final log in entry.value) _itemOf(log)],
        ),
    ];
  }

  FoodLogHistoryItem _itemOf(FoodLog log) => FoodLogHistoryItem(
    log: log,
    name: log.food.name,
    detail: '${log.mealType.label} · ${log.food.servingDescription}',
    caloriesLabel: NutritionLabels.kcal(log.macros.calories),
    timeLabel: AppDateUtils.time(log.loggedAt),
  );

  bool canDelete(FoodLogHistoryItem item) =>
      !AppDateUtils.dateOnly(item.log.loggedAt).isBefore(today);

  Future<void> delete(String id) async {
    _errorMessage = null;
    try {
      await _logService.deleteFoodLog(id);
    } on NutritionLogException catch (e) {
      _errorMessage = e.message;
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
