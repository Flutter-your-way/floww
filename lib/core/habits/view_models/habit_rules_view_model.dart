import 'package:flutter/foundation.dart';

import 'package:floww/config/widgets/buttons/select_buttons/weekday_picker.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_schedule.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/view_models/habit_labels.dart';

class HabitRulesViewModel extends ChangeNotifier {
  HabitRulesViewModel({
    HabitMetric metric = HabitMetric.minutes,
    HabitGoalType goalType = HabitGoalType.build,
    HabitSchedule schedule = const HabitSchedule.daily(),
    HabitSource source = HabitSource.manual,
  }) : _metric = metric,
       _goalType = goalType,
       _schedule = schedule,
       _source = source;

  static const List<int> _defaultWeekdays = [
    DateTime.monday,
    DateTime.wednesday,
    DateTime.friday,
  ];
  static const int _minTimesPerWeek = 1;
  static const int _maxTimesPerWeek = 6;
  static const String _dailyId = 'daily';
  static const String _weekdaysId = 'weekdays';
  static const String _weeklyPrefix = 'weekly_';

  HabitMetric _metric;
  HabitGoalType _goalType;
  HabitSchedule _schedule;
  HabitSource _source;

  HabitMetric get metric => _metric;

  HabitGoalType get goalType => _goalType;

  HabitSchedule get schedule => _schedule;

  HabitSource get source => _source;

  String get goalLabel => 'Goal';

  String get scheduleLabel => 'Schedule';

  String get scheduleSheetSubtitle => 'Choose the days this habit counts';

  String get sourceLabel => 'Auto-track';

  String get sourceSheetSubtitle => 'Fill your progress in automatically';

  List<HabitGoalType> get goalTypes => HabitGoalType.values;

  String labelOfGoal(HabitGoalType goalType) => HabitLabels.goal(goalType);

  String get scheduleValueLabel => HabitLabels.schedule(_schedule);

  String get scheduleId => switch (_schedule.type) {
    HabitScheduleType.daily => _dailyId,
    HabitScheduleType.weekdays => _weekdaysId,
    HabitScheduleType.weekly => '$_weeklyPrefix${_schedule.timesPerWeek}',
  };

  List<HabitOptionItem> get scheduleItems => [
    const HabitOptionItem(id: _dailyId, label: 'Every day'),
    const HabitOptionItem(id: _weekdaysId, label: 'Specific days'),
    for (var times = _minTimesPerWeek; times <= _maxTimesPerWeek; times++)
      HabitOptionItem(
        id: '$_weeklyPrefix$times',
        label: HabitLabels.timesPerWeek(times),
      ),
  ];

  bool get showsWeekdays => _schedule.type == HabitScheduleType.weekdays;

  List<WeekdayPickerItem> get weekdayItems => [
    for (final weekday in HabitSchedule.allWeekdays)
      WeekdayPickerItem(
        weekday: weekday,
        label: HabitLabels.weekdayInitial(weekday),
        isSelected: _schedule.weekdays.contains(weekday),
      ),
  ];

  List<HabitSource> get _sources => [
    for (final source in HabitSource.values)
      if (source.supports(_metric)) source,
  ];

  bool get showsSource =>
      _goalType == HabitGoalType.build && _sources.length > 1;

  String get sourceValueLabel => HabitLabels.source(_source);

  List<HabitOptionItem> get sourceItems => [
    for (final source in _sources)
      HabitOptionItem(id: source.name, label: HabitLabels.source(source)),
  ];

  bool isValidTarget(double? target) {
    if (target == null) return false;
    return _goalType == HabitGoalType.limit ? target >= 0 : target > 0;
  }

  void selectMetric(HabitMetric metric) {
    if (metric == _metric) return;
    _metric = metric;
    if (!_source.supports(metric)) _source = HabitSource.manual;
    notifyListeners();
  }

  void selectGoal(HabitGoalType goalType) {
    if (goalType == _goalType) return;
    _goalType = goalType;
    if (goalType == HabitGoalType.limit) _source = HabitSource.manual;
    notifyListeners();
  }

  void selectSchedule(String id) {
    if (id == scheduleId) return;
    if (id == _dailyId) {
      _schedule = const HabitSchedule.daily();
    } else if (id == _weekdaysId) {
      _schedule = const HabitSchedule.weekdays(_defaultWeekdays);
    } else if (id.startsWith(_weeklyPrefix)) {
      final times = int.tryParse(id.substring(_weeklyPrefix.length));
      if (times == null) return;
      _schedule = HabitSchedule.weekly(times);
    }
    notifyListeners();
  }

  void toggleWeekday(int weekday) {
    if (!showsWeekdays) return;
    final days = [..._schedule.weekdays];
    if (days.contains(weekday)) {
      if (days.length == 1) return;
      days.remove(weekday);
    } else {
      days.add(weekday);
    }
    days.sort();
    _schedule = days.length == DateTime.daysPerWeek
        ? const HabitSchedule.daily()
        : HabitSchedule.weekdays(days);
    notifyListeners();
  }

  void selectSource(String id) {
    final source = HabitSource.values
        .where((source) => source.name == id)
        .firstOrNull;
    if (source == null || source == _source || !source.supports(_metric)) {
      return;
    }
    _source = source;
    notifyListeners();
  }
}
