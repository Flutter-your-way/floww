import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/dates/date_change_direction.dart';
import 'package:floww/config/utils/dates/day_rollover_timer.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_day.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/habits/models/habit_suggestion.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/services/habit_log_service.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/habits/view_models/habit_labels.dart';

enum HabitDateStatus { past, today, future }

class HabitsViewModel extends ChangeNotifier {
  HabitsViewModel(this._service, this._logService)
    : _selectedDate = AppDateUtils.dateOnly(DateTime.now()) {
    _loadHabits();
    _dayRollover = DayRolloverTimer(_onNewDay);
  }

  static const int _selectableRangeDays = 365;
  static const int _maxFlowPoints = 20;
  static const double _greatScore = 0.8;
  static const double _goodScore = 0.5;

  final HabitService _service;
  final HabitLogService _logService;

  DateTime _selectedDate;
  DateChangeDirection _dateDirection = DateChangeDirection.forward;
  List<Habit> _habits = const [];
  late final DayRolloverTimer _dayRollover;

  DateTime get selectedDate => _selectedDate;

  DateChangeDirection get dateDirection => _dateDirection;

  DateTime get _today => AppDateUtils.dateOnly(DateTime.now());

  DateTime get firstSelectableDate =>
      AppDateUtils.addDays(_today, -_selectableRangeDays);

  DateTime get lastSelectableDate =>
      AppDateUtils.addDays(_today, _selectableRangeDays);

  bool get canGoPrevious => _selectedDate.isAfter(firstSelectableDate);

  bool get canGoNext => _selectedDate.isBefore(lastSelectableDate);

  HabitDateStatus get dateStatus {
    if (AppDateUtils.isSameDay(_selectedDate, _today)) {
      return HabitDateStatus.today;
    }
    return _selectedDate.isAfter(_today)
        ? HabitDateStatus.future
        : HabitDateStatus.past;
  }

  bool get canEdit => dateStatus == HabitDateStatus.today;

  bool get isReadOnly => dateStatus == HabitDateStatus.past;

  String get readOnlyLabel {
    final isYesterday = AppDateUtils.isSameDay(
      _selectedDate,
      AppDateUtils.addDays(_today, -1),
    );
    final reference = AppDateUtils.relativeDay(_selectedDate);
    return '${isYesterday ? '$reference\'s' : reference} habits — historical '
        'data (read-only)';
  }

  String get titlePrefix => dateStatus == HabitDateStatus.today
      ? 'Today\'s'
      : '${AppDateUtils.weekdayName(_selectedDate)}\'s';

  String get dateLabel => AppDateUtils.dayMonth(
    _selectedDate,
    withYear: _selectedDate.year != _today.year,
  );

  String get habitsTitle => dateStatus == HabitDateStatus.today
      ? 'Today\'s Habits'
      : '${AppDateUtils.weekdayName(_selectedDate)}\'s Habits';

  bool get showEmptyState => _habits.isEmpty;

  String get emptyTitle => 'No habits yet';

  String get emptyMessage =>
      'Build consistent daily routines and track your progress. Start with '
      'one habit and grow from there.';

  String get createFirstHabitLabel => 'CREATE FIRST HABIT';

  List<HabitSuggestionItem> get popularHabits => [
    for (final suggestion in _service.popularHabits())
      HabitSuggestionItem(
        id: suggestion.id,
        title: suggestion.title,
        targetLabel: HabitLabels.target(suggestion),
        icon: suggestion.icon,
      ),
  ];

  int get totalCount => _habits.length;

  int get completedCount => _habits.where((habit) => habit.isCompleted).length;

  String get scoreLabel => '$completedCount';

  String get scoreTotalLabel => '/$totalCount';

  double get dailyScore {
    if (_habits.isEmpty) return 0;
    final total = _habits.fold<double>(0, (sum, habit) => sum + habit.progress);
    return total / _habits.length;
  }

  String get dailyScoreLabel => '${(dailyScore * 100).round()}';

  int get flowPoints => (dailyScore * _maxFlowPoints).round();

  String get flowPointsLabel => HabitLabels.points(flowPoints);

  String get headline {
    if (dailyScore >= _greatScore) return 'Great consistency!';
    if (dailyScore >= _goodScore) return 'Good momentum';
    return completedCount > 0 ? 'Keep going' : 'Nothing done yet';
  }

  String get headlineMessage {
    if (dailyScore >= _greatScore) {
      return 'You\'re building strong daily habits.';
    }
    if (dailyScore >= _goodScore) {
      return 'You\'re halfway there — finish what\'s left.';
    }
    return completedCount > 0
        ? 'Small wins add up. Tick off one more habit.'
        : 'Tick off your first habit to start the day.';
  }

  String get noteTitle {
    if (showEmptyState) return 'Start small, build big';
    return completedCount == totalCount ? 'All done!' : 'Keep it up!';
  }

  String get noteMessage {
    if (showEmptyState) {
      return 'Research shows that starting with 1-3 habits makes them far '
          'more likely to stick.';
    }
    return 'You\'ve completed $completedCount of your $totalCount habits. '
        'Consistency is your superpower.';
  }

  List<HabitRowItem> get habits => [
    for (final habit in _habits)
      HabitRowItem(
        id: habit.id,
        title: habit.title,
        progressLabel: HabitLabels.progress(habit),
        progress: habit.progress,
        isCompleted: habit.isCompleted,
      ),
  ];

  List<HabitStatItem> get stats {
    final stats = _service.statsFor(_selectedDate);
    return [
      HabitStatItem(
        title: 'CURRENT STREAK',
        value: '${stats.currentStreakDays}',
        unit: 'days',
      ),
      HabitStatItem(
        title: 'LONGEST STREAK',
        value: '${stats.longestStreakDays}',
        unit: 'days',
      ),
      HabitStatItem(
        title: 'WEEKLY AVERAGE',
        value: '${stats.weeklyAverageMinutes}',
        unit: 'min',
      ),
    ];
  }

  List<HabitDay> get _week =>
      _service.weekFor(_selectedDate, todayCompletion: _todayCompletion);

  double get _todayCompletion => AppDateUtils.isSameDay(_selectedDate, _today)
      ? dailyScore
      : _completionOfToday;

  double get _completionOfToday {
    final habits = _service.habitsFor(_today);
    if (habits.isEmpty) return 0;
    final total = habits.fold<double>(0, (sum, habit) => sum + habit.progress);
    return total / habits.length;
  }

  List<WeekdayProgressItem> get weekdays => [
    for (final day in _week)
      WeekdayProgressItem(
        label: AppDateUtils.shortWeekday(day.date).substring(0, 1),
        percentLabel: HabitLabels.percent(day.completion),
        progress: day.completion,
        status: day.status,
      ),
  ];

  String get weekRangeLabel {
    final start = AppDateUtils.startOfWeek(_selectedDate);
    final end = AppDateUtils.endOfWeek(_selectedDate);
    return '${AppDateUtils.dayMonth(start)} — ${AppDateUtils.dayMonth(end)}';
  }

  List<HabitLegendItem> get legend {
    final week = _week;
    int countOf(HabitDayStatus status) =>
        week.where((day) => day.status == status).length;
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

  void previousDay() {
    if (canGoPrevious) _setDate(AppDateUtils.addDays(_selectedDate, -1));
  }

  void nextDay() {
    if (canGoNext) _setDate(AppDateUtils.addDays(_selectedDate, 1));
  }

  void selectDate(DateTime date) => _setDate(AppDateUtils.dateOnly(date));

  List<HabitSuggestion> get suggestions => _service.popularHabits();

  List<HabitSuggestionGroup> get suggestionGroups =>
      _service.suggestionGroups();

  void addSuggestion(HabitSuggestion suggestion) {
    _service.addHabit(suggestion);
    _loadHabits();
    _syncTodayLog();
    notifyListeners();
  }

  void addCustomHabit(HabitDraft draft) {
    _service.addCustomHabit(draft);
    _loadHabits();
    _syncTodayLog();
    notifyListeners();
  }

  void addSuggestedHabit(String id) {
    final suggestion = _service
        .popularHabits()
        .where((suggestion) => suggestion.id == id)
        .firstOrNull;
    if (suggestion == null) return;
    _service.addHabit(suggestion);
    _loadHabits();
    _syncTodayLog();
    notifyListeners();
  }

  void toggleHabit(String id) {
    if (!canEdit) return;
    _habits = [
      for (final habit in _habits)
        if (habit.id == id)
          habit.copyWith(value: habit.isCompleted ? 0 : habit.target)
        else
          habit,
    ];
    _syncTodayLog();
    notifyListeners();
  }

  void _syncTodayLog() {
    final habits = AppDateUtils.isSameDay(_selectedDate, _today)
        ? _habits
        : _service.habitsFor(_today);
    unawaited(_logService.saveDay(_today, habits));
  }

  void _setDate(DateTime date) {
    if (AppDateUtils.isSameDay(date, _selectedDate)) return;
    _dateDirection = date.isAfter(_selectedDate)
        ? DateChangeDirection.forward
        : DateChangeDirection.backward;
    _selectedDate = date;
    _loadHabits();
    notifyListeners();
  }

  void _loadHabits() => _habits = _service.habitsFor(_selectedDate);

  void _onNewDay() {
    final previous = AppDateUtils.addDays(_today, -1);
    if (AppDateUtils.isSameDay(_selectedDate, previous)) {
      _setDate(_today);
      return;
    }
    _loadHabits();
    notifyListeners();
  }

  @override
  void dispose() {
    _dayRollover.cancel();
    super.dispose();
  }
}
