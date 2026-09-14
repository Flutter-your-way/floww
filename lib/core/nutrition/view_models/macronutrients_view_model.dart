import 'package:flutter/foundation.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/macro_nutrient.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';

class MacronutrientsViewModel extends ChangeNotifier {
  MacronutrientsViewModel(this._day, this._selected);

  final NutritionDay _day;
  MacroNutrient _selected;

  List<MacroNutrient> get macros => MacroNutrient.values;

  MacroNutrient get selected => _selected;

  String get splitTitle => AppDateUtils.isSameDay(_day.date, DateTime.now())
      ? 'Today\'s Macro Split'
      : 'Macro Split';

  List<MacroShare> get shares => [
    for (final macro in MacroNutrient.values)
      MacroShare(
        macro: macro,
        share: _day.macroSplit.shareOf(macro),
        shareLabel: NutritionLabels.percent(_day.macroSplit.shareOf(macro)),
      ),
  ];

  double get _grams => _day.macroSplit.gramsOf(_selected);

  String get amountLabel => NutritionLabels.grams(_grams);

  String get goalLabel => '/ ${_day.goalGramsOf(_selected)}g goal';

  double get progress => _grams / _day.goalGramsOf(_selected);

  String get percentOfGoalLabel =>
      '${NutritionLabels.percent(progress)} of daily goal';

  String get energyLabel =>
      '${_selected.kcalPerGram} kcal/g · '
      '${NutritionLabels.number(_day.macroSplit.caloriesOf(_selected))} kcal total';

  String get recommendedLabel =>
      '${_selected.recommendedRange} of total calories';

  void select(MacroNutrient macro) {
    if (macro == _selected) return;
    _selected = macro;
    notifyListeners();
  }
}
