import 'package:flutter/foundation.dart';

import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/habits/view_models/habit_labels.dart';
import 'package:floww/core/habits/view_models/habit_rules_view_model.dart';

class CustomHabitViewModel extends ChangeNotifier {
  CustomHabitViewModel(this._rules);

  final HabitRulesViewModel _rules;

  String _name = '';
  String _description = '';
  String _target = '';

  String get title => 'Custom Habit';

  String get subtitle => 'Build something uniquely yours';

  String get nameLabel => 'Habit Name';

  String get nameHint => 'e.g. Morning Run, Cold Shower...';

  String get descriptionLabel => 'Description (optional)';

  String get descriptionHint => 'e.g. Run for at least 5km';

  String get targetLabel => 'Target & Unit';

  String get targetHint => 'e.g. 10';

  String get submitLabel => 'Add Habit';

  HabitMetric get metric => _rules.metric;

  List<HabitMetric> get metrics => HabitMetric.values;

  String get metricLabel => HabitLabels.unit(_rules.metric);

  String labelOf(HabitMetric metric) => HabitLabels.unit(metric);

  double? get _targetValue => double.tryParse(_target.trim());

  bool get canSubmit =>
      _name.trim().isNotEmpty && _rules.isValidTarget(_targetValue);

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

  void selectMetric(HabitMetric metric) => _rules.selectMetric(metric);

  HabitDraft? buildDraft() {
    final target = _targetValue;
    if (!canSubmit || target == null) return null;
    final description = _description.trim();
    return HabitDraft(
      title: _name.trim(),
      target: target,
      metric: _rules.metric,
      schedule: _rules.schedule,
      goalType: _rules.goalType,
      source: _rules.source,
      description: description.isEmpty ? null : description,
    );
  }
}
