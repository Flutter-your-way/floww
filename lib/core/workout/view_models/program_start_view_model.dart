import 'package:flutter/foundation.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/widgets/buttons/select_buttons/weekday_picker.dart';
import 'package:floww/core/workout/models/add_exercise_view_data.dart';
import 'package:floww/core/workout/models/program_start_config.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';

enum ProgramStartDay { today, tomorrow, nextMonday }

class ProgramStartViewModel extends ChangeNotifier {
  ProgramStartViewModel(this._setup)
    : _weeks = _setup.weeks,
      _selected = {..._setup.dayWeekdays};

  static const int _minWeeks = 1;
  static const int _maxWeeks = 24;

  final ProgramStartSetup _setup;
  final Set<int> _selected;
  int _weeks;
  ProgramStartDay _startDay = ProgramStartDay.today;

  DateTime get _today => AppDateUtils.dateOnly(DateTime.now());

  int get _needed => _setup.sessionsPerWeek;

  String get title => 'Set up ${_setup.name}';

  String get subtitle => 'Make it fit your week';

  String get daysLabel => 'Training days';

  String get daysHint => _selected.length == _needed
      ? '$_needed days a week'
      : 'Pick $_needed days · ${_selected.length} selected';

  bool get isDaysComplete => _selected.length == _needed;

  String get lengthLabel => 'Program length';

  String get startLabel => 'Start date';

  String get submitLabel => 'Start program';

  bool get canStart => isDaysComplete;

  List<WeekdayPickerItem> get weekdayItems => [
    for (var i = 0; i < DateTime.daysPerWeek; i++)
      WeekdayPickerItem(
        weekday: DateTime.monday + i,
        label: AppDateUtils.shortWeekday(
          AppDateUtils.addDays(AppDateUtils.startOfWeek(_today), i),
        ).substring(0, 1),
        isSelected: _selected.contains(DateTime.monday + i),
      ),
  ];

  bool toggleWeekday(int weekday) {
    if (_selected.remove(weekday)) {
      notifyListeners();
      return true;
    }
    if (_selected.length >= _needed) return false;
    _selected.add(weekday);
    notifyListeners();
    return true;
  }

  AddExerciseTargetItem get weeksTarget => _setup.hasFixedLength
      ? AddExerciseTargetItem(
          label: 'Length',
          value: '${_setup.lengthDays}',
          unit: 'days',
          canDecrease: false,
          canIncrease: false,
        )
      : AddExerciseTargetItem(
          label: 'Length',
          value: '$_weeks',
          unit: _weeks == 1 ? 'week' : 'weeks',
          canDecrease: _weeks > _minWeeks,
          canIncrease: _weeks < _maxWeeks,
        );

  void adjustWeeks(int delta) {
    if (_setup.hasFixedLength) return;
    final next = (_weeks + delta).clamp(_minWeeks, _maxWeeks);
    if (next == _weeks) return;
    _weeks = next;
    notifyListeners();
  }

  List<ProgramFilterItem<ProgramStartDay>> get startOptions => [
    for (final day in ProgramStartDay.values)
      ProgramFilterItem(
        value: day,
        label: switch (day) {
          ProgramStartDay.today => 'Today',
          ProgramStartDay.tomorrow => 'Tomorrow',
          ProgramStartDay.nextMonday => 'Next Monday',
        },
        isSelected: day == _startDay,
      ),
  ];

  void selectStartDay(ProgramStartDay day) {
    if (day == _startDay) return;
    _startDay = day;
    notifyListeners();
  }

  DateTime get startDate => switch (_startDay) {
    ProgramStartDay.today => _today,
    ProgramStartDay.tomorrow => AppDateUtils.addDays(_today, 1),
    ProgramStartDay.nextMonday => AppDateUtils.addDays(
      AppDateUtils.startOfWeek(_today),
      DateTime.daysPerWeek,
    ),
  };

  String get summary {
    final days = [
      for (final weekday in _sortedSelection)
        AppDateUtils.shortWeekday(
          AppDateUtils.addDays(
            AppDateUtils.startOfWeek(_today),
            weekday - DateTime.monday,
          ),
        ),
    ];
    final end = _setup.hasFixedLength
        ? AppDateUtils.addDays(startDate, _setup.lengthDays - 1)
        : AppDateUtils.addDays(
            AppDateUtils.startOfWeek(startDate),
            _weeks * DateTime.daysPerWeek - 1,
          );
    return '${days.join(', ')} · starts '
        '${AppDateUtils.dayMonth(startDate)} · ends '
        '${AppDateUtils.dayMonth(end, withYear: end.year != _today.year)}';
  }

  List<int> get _sortedSelection => _selected.toList()..sort();

  ProgramStartConfig get config {
    final chosen = _sortedSelection;
    final days = _setup.dayWeekdays;
    final order = [for (var i = 0; i < days.length; i++) i]
      ..sort((a, b) => days[a].compareTo(days[b]));
    final mapped = List<int>.filled(days.length, DateTime.monday);
    for (var k = 0; k < order.length && k < chosen.length; k++) {
      mapped[order[k]] = chosen[k];
    }
    return ProgramStartConfig(
      weekdays: mapped,
      weeks: _weeks,
      startDate: startDate,
    );
  }
}
