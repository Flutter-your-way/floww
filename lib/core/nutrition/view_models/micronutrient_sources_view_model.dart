import 'package:flutter/foundation.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';

class MicronutrientSourcesViewModel extends ChangeNotifier {
  MicronutrientSourcesViewModel(this._day, this._selected);

  final NutritionDay _day;
  final MicronutrientKind _selected;

  MicronutrientKind get selected => _selected;

  String get title => '${labelOf(_selected)} Sources';

  String labelOf(MicronutrientKind kind) => switch (kind) {
    MicronutrientKind.water => 'Water',
    MicronutrientKind.fiber => 'Fiber',
    MicronutrientKind.sugar => 'Sugar',
    MicronutrientKind.sodium => 'Sodium',
  };

  bool get isLimit => _selected != MicronutrientKind.fiber;

  double _amountIn(FoodLog log) => switch (_selected) {
    MicronutrientKind.fiber => log.macros.fiberG,
    MicronutrientKind.sugar => log.macros.sugarG,
    MicronutrientKind.sodium => log.food.nutrition.minerals.sodiumMg,
    MicronutrientKind.water => log.macros.waterMl,
  };

  double get _total => switch (_selected) {
    MicronutrientKind.fiber => _day.fiberG,
    MicronutrientKind.sugar => _day.sugarG,
    MicronutrientKind.sodium => _day.sodiumMg,
    MicronutrientKind.water => _day.foodWaterMl,
  };

  int get _goal => switch (_selected) {
    MicronutrientKind.fiber => _day.goal.fiberG,
    MicronutrientKind.sugar => _day.goal.sugarG,
    MicronutrientKind.sodium => _day.goal.sodiumMg,
    MicronutrientKind.water => _day.goal.waterMl,
  };

  String _format(double value) => _selected == MicronutrientKind.sodium
      ? NutritionLabels.milligrams(value)
      : NutritionLabels.preciseGrams(value);

  String get amountLabel => _format(_total);

  String get goalLabel {
    final unit = _selected == MicronutrientKind.sodium ? 'mg' : 'g';
    final kind = isLimit ? 'limit' : 'goal';
    return '/ ${NumberFormatter.grouped(_goal)}$unit $kind';
  }

  double get progress => _goal == 0 ? 0 : _total / _goal;

  bool get isOverLimit => isLimit && _total > _goal;

  String get percentLabel =>
      '${NutritionLabels.percent(progress)} of daily ${isLimit ? 'limit' : 'goal'}';

  String get statusLabel {
    final remaining = (_goal - _total).abs();
    if (isLimit) {
      return isOverLimit
          ? '${_format(remaining)} over limit'
          : '${_format(remaining)} left';
    }
    return _total >= _goal ? 'Goal reached' : '${_format(remaining)} to go';
  }

  String get sourcesTitle => 'Where it came from';

  String get emptyMessage =>
      'No ${labelOf(_selected).toLowerCase()} logged yet for this day.';

  List<NutrientSourceItem> get sources {
    final total = _total;
    final logs = _day.foodLogs.where((log) => _amountIn(log) > 0).toList()
      ..sort((a, b) => _amountIn(b).compareTo(_amountIn(a)));
    return [
      for (final log in logs)
        NutrientSourceItem(
          name: log.food.name,
          meal: log.mealType,
          detail: '${log.mealType.label} · ${log.food.servingDescription}',
          amountLabel: _format(_amountIn(log)),
          shareLabel: NutritionLabels.percent(_amountIn(log) / total),
          share: _amountIn(log) / total,
        ),
    ];
  }
}
