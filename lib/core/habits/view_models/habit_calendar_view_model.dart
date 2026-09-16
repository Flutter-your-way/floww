import 'package:flutter/foundation.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit_day.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/services/habit_service.dart';

class HabitCalendarViewModel extends ChangeNotifier {
  HabitCalendarViewModel(this._service, DateTime date)
    : _month = DateTime(date.year, date.month);

  static const int _monthRangeMonths = 12;

  final HabitService _service;

  DateTime _month;

  DateTime get month => _month;

  String get monthLabel => AppDateUtils.monthYear(_month);

  DateTime get _today => AppDateUtils.dateOnly(DateTime.now());

  DateTime get _firstSelectableMonth =>
      DateTime(_today.year, _today.month - _monthRangeMonths);

  DateTime get _lastSelectableMonth =>
      DateTime(_today.year, _today.month + _monthRangeMonths);

  bool get canGoPrevious => _month.isAfter(_firstSelectableMonth);

  bool get canGoNext => _month.isBefore(_lastSelectableMonth);

  List<String> get weekdayLabels {
    final start = AppDateUtils.startOfWeek(_today);
    return [
      for (var index = 0; index < DateTime.daysPerWeek; index++)
        AppDateUtils.shortWeekday(
          AppDateUtils.addDays(start, index),
        ).substring(0, 1),
    ];
  }

  List<HabitDay> get _days => _service.monthFor(_month);

  List<CalendarDayItem?> get days {
    final days = _days;
    final leadingBlanks = days.isEmpty ? 0 : days.first.date.weekday - 1;
    return [
      for (var index = 0; index < leadingBlanks; index++) null,
      for (final day in days)
        CalendarDayItem(
          label: '${day.date.day}',
          progress: day.completion,
          status: day.status,
          isToday: AppDateUtils.isSameDay(day.date, _today),
        ),
    ];
  }

  List<HabitLegendItem> get legend {
    final days = _days;
    int countOf(HabitDayStatus status) =>
        days.where((day) => day.status == status).length;
    return [
      HabitLegendItem(
        label: 'Completed (${countOf(HabitDayStatus.completed)})',
        status: HabitDayStatus.completed,
      ),
      HabitLegendItem(
        label: 'Partial (${countOf(HabitDayStatus.partial)})',
        status: HabitDayStatus.partial,
      ),
      HabitLegendItem(
        label: 'Missed (${countOf(HabitDayStatus.missed)})',
        status: HabitDayStatus.missed,
      ),
    ];
  }

  String get bestStreakValue =>
      '${_service.statsFor(_today).longestStreakDays}';

  String get bestStreakUnit => 'days';

  String get topHabitTitle {
    final streaks = _service.habitStreaks();
    if (streaks.isEmpty) return '—';
    return streaks
        .reduce((best, streak) => streak.days > best.days ? streak : best)
        .title;
  }

  List<HabitStreakItem> get streaks => [
    for (final streak in _service.habitStreaks())
      HabitStreakItem(title: streak.title, daysLabel: '${streak.days}'),
  ];

  void previousMonth() {
    if (!canGoPrevious) return;
    _month = DateTime(_month.year, _month.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    if (!canGoNext) return;
    _month = DateTime(_month.year, _month.month + 1);
    notifyListeners();
  }
}
