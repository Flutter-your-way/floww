import 'package:flutter/foundation.dart';

import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/habits/view_models/habit_labels.dart';

class CustomHabitViewModel extends ChangeNotifier {
  String _name = '';
  String _description = '';
  String _target = '';
  HabitMetric _metric = HabitMetric.minutes;

  String get title => 'Custom Habit';

  String get subtitle => 'Build something uniquely yours';

  String get nameLabel => 'Habit Name';

  String get nameHint => 'e.g. Morning Run, Cold Shower...';

  String get descriptionLabel => 'Description (optional)';

  String get descriptionHint => 'e.g. Run for at least 5km';

  String get targetLabel => 'Target & Unit';

  String get targetHint => 'e.g. 10';

  String get submitLabel => 'Add Habit';

  HabitMetric get metric => _metric;

  List<HabitMetric> get metrics => HabitMetric.values;

  String get metricLabel => HabitLabels.unit(_metric);

  String labelOf(HabitMetric metric) => HabitLabels.unit(metric);

  double? get _targetValue => double.tryParse(_target.trim());

  bool get canSubmit {
    final target = _targetValue;
    return _name.trim().isNotEmpty && target != null && target > 0;
  }

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updateTarget(String value) {
    _target = value;
    notifyListeners();
  }

  void selectMetric(HabitMetric metric) {
    if (metric == _metric) return;
    _metric = metric;
    notifyListeners();
  }

  HabitDraft? buildDraft() {
    final target = _targetValue;
    if (!canSubmit || target == null) return null;
    final description = _description.trim();
    return HabitDraft(
      title: _name.trim(),
      target: target,
      metric: _metric,
      description: description.isEmpty ? null : description,
    );
  }
}
