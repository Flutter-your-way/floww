import 'package:floww/core/nutrition/models/portion_unit.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';

class PortionSelection {
  PortionSelection({
    required String serving,
    required this.weightG,
    double servings = 1,
  }) : serving = serving.trim().isEmpty ? _fallbackServing : serving.trim(),
       _unit = PortionUnit.serving,
       _amount = 1 {
    final rounded = _roundServings(servings);
    final isWholeStep = (rounded / _servingStep) % 1 == 0;
    if (supportsGrams && (_isGramServing || !isWholeStep)) {
      _unit = PortionUnit.gram;
      _amount = (rounded * weightG).roundToDouble();
    } else {
      _amount = rounded;
    }
  }

  static const String _fallbackServing = '1 serving';
  static const double _servingStep = 0.5;
  static const double _gramStep = 10;
  static const double _maxServings = 50;
  static const double _maxGrams = 5000;
  static const List<double> _servingPresets = [0.5, 1, 2, 3];
  static const List<double> _gramPresets = [50, 100, 150, 200];
  static final RegExp _gramPattern = RegExp(r'\d\s*g\b', caseSensitive: false);

  final String serving;
  final double weightG;
  PortionUnit _unit;
  double _amount;

  bool get supportsGrams => weightG > 0;

  bool get _isGramServing => serving == NutritionLabels.preciseGrams(weightG);

  bool get _servingMentionsGrams => _gramPattern.hasMatch(serving);

  String get baseLabel {
    final base = '1 serving = $serving';
    if (!supportsGrams || _servingMentionsGrams) return base;
    return '$base (${NutritionLabels.preciseGrams(weightG)})';
  }

  List<PortionUnit> get units =>
      supportsGrams ? PortionUnit.values : const [PortionUnit.serving];

  bool get showsUnits => units.length > 1;

  PortionUnit get unit => _unit;

  double get amount => _amount;

  String get amountText => _amount > 0 ? NutritionLabels.quantity(_amount) : '';

  String get unitLabel => switch (_unit) {
    PortionUnit.gram => 'grams',
    PortionUnit.serving => _amount == 1 ? 'serving' : 'servings',
  };

  List<double> get presets =>
      _unit == PortionUnit.gram ? _gramPresets : _servingPresets;

  String presetLabelOf(double value) => _unit == PortionUnit.gram
      ? NutritionLabels.preciseGrams(value)
      : '${NutritionLabels.quantity(value)}×';

  double get _step => _unit == PortionUnit.gram ? _gramStep : _servingStep;

  double get _max => _unit == PortionUnit.gram ? _maxGrams : _maxServings;

  double get factor => _unit == PortionUnit.gram ? _amount / weightG : _amount;

  bool get isValid => _amount > 0;

  bool get canDecrement => _amount > _step;

  bool get canIncrement => _amount < _max;

  String get servingLabel {
    if (_unit == PortionUnit.gram || _isGramServing) {
      return NutritionLabels.preciseGrams(weightG * factor);
    }
    if (_amount == 1) return serving;
    return '${NutritionLabels.quantity(_amount)} × $serving';
  }

  String get summaryLabel {
    final label = servingLabel;
    if (!supportsGrams || _unit == PortionUnit.gram || _isGramServing) {
      return label;
    }
    return '$label · ${NutritionLabels.preciseGrams(weightG * factor)}';
  }

  void selectUnit(PortionUnit unit) {
    if (unit == _unit || !units.contains(unit)) return;
    _amount = unit == PortionUnit.gram
        ? (_amount * weightG).roundToDouble()
        : _roundServings(_amount / weightG);
    _unit = unit;
  }

  void setAmount(double value) => _amount = value.clamp(0, _max).toDouble();

  void updateAmount(String text) =>
      setAmount(double.tryParse(text.trim()) ?? 0);

  void increment() => setAmount(((_amount / _step).floor() + 1) * _step);

  void decrement() {
    final steps = (_amount / _step).ceil() - 1;
    setAmount((steps < 1 ? 1 : steps) * _step);
  }

  static double _roundServings(double value) => (value * 100).round() / 100;
}
