import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_day.dart';
import 'package:floww/core/habits/models/habit_detail.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/habits/models/habit_period.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/habits/services/habit_snapshot_builder.dart';
import 'package:floww/core/habits/view_models/habit_labels.dart';

class HabitDetailsViewModel extends ChangeNotifier {
  HabitDetailsViewModel(this._service, this._habitId) {
    start();
  }

  final HabitService _service;
  final String _habitId;

  StreamSubscription<HabitRecords>? _subscription;
  HabitSnapshot _snapshot = HabitSnapshot.empty;
  HabitPeriod _period = HabitPeriod.thisMonth;
  bool _isLoading = true;
  String? _errorMessage;
  String? _actionMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get actionMessage => _actionMessage;

  void start() {
    _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _subscription = _service.watchRecords().listen(
      (records) {
        _snapshot = HabitSnapshot.of(records);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = 'Could not load this habit. Please try again.';
        notifyListeners();
      },
    );
  }

  Future<void> retry() async => start();

  HabitDetail? get _detail => _snapshot.detailFor(_habitId);

  DateTime get _today => AppDateUtils.dateOnly(DateTime.now());

  bool get hasHabit => _detail != null;

  String get title => 'Habit Details';

  String get missingLabel => 'This habit is no longer available.';

  String get habitTitle => _detail?.title ?? '';

  String get habitDescription {
    final detail = _detail;
    if (detail == null) return '';
    if (detail.description.isNotEmpty) return detail.description;
    return 'Daily target of ${HabitLabels.amount(detail.target, detail.metric)}';
  }

  HabitIconKind get habitIcon => _detail?.icon ?? HabitIconKind.clipboard;

  String get editLabel => 'Edit';

  String get deleteLabel => 'Delete Habit';

  String get logLabel => 'Log Progress';

  String get progressTitle => 'Habit Progress';

  String get aboutTitle => 'About This Habit';

  String get aboutMessage => _detail?.about ?? '';

  String get periodSheetTitle => 'Habit Progress';

  String get periodSheetSubtitle => 'Choose the range you want to review';

  String get logSheetTitle => 'Log Progress';

  String get logSheetSubtitle => 'Record what you have done today';

  String get logValueLabel => 'Today\'s Progress';

  String get logValueHint => 'e.g. 30';

  String get logSubmitLabel => 'Save Progress';

  String get todayProgressLabel {
    final habit = _todayHabit;
    return habit == null ? '' : HabitLabels.progress(habit);
  }

  String get initialLogValue => HabitLabels.decimal(_todayHabit?.value ?? 0);

  String get logUnitLabel =>
      HabitLabels.unit(_detail?.metric ?? HabitMetric.minutes);

  Habit? get _todayHabit => _snapshot
      .habitsFor(_today)
      .where((habit) => habit.id == _habitId)
      .firstOrNull;

  HabitPeriod get period => _period;

  List<HabitPeriod> get periods => HabitPeriod.values;

  String get periodLabel => labelOfPeriod(_period);

  String labelOfPeriod(HabitPeriod period) => switch (period) {
    HabitPeriod.thisWeek => 'This Week',
    HabitPeriod.thisMonth => 'This Month',
    HabitPeriod.lastMonth => 'Last Month',
  };

  List<HabitStatItem> get stats {
    final detail = _detail;
    if (detail == null) return const [];
    return [
      HabitStatItem(
        title: 'Current Streak',
        value: '${detail.currentStreakDays}',
        unit: 'days',
        icon: HabitIconKind.flame,
      ),
      HabitStatItem(
        title: 'Longest Streak',
        value: '${detail.longestStreakDays}',
        unit: 'days',
        icon: HabitIconKind.trophy,
      ),
      HabitStatItem(
        title: 'Weekly Average',
        value: '${detail.weeklyAveragePercent}',
        unit: '%',
        icon: HabitIconKind.trend,
      ),
      HabitStatItem(
        title: 'Total Completions',
        value: '${detail.totalCompletions}',
        unit: 'days',
        icon: HabitIconKind.target,
      ),
    ];
  }

  List<String> get weekdayLabels {
    final start = AppDateUtils.startOfWeek(_today);
    return [
      for (var index = 0; index < DateTime.daysPerWeek; index++)
        AppDateUtils.shortWeekday(
          AppDateUtils.addDays(start, index),
        ).substring(0, 1),
    ];
  }

  List<HabitDay> get _days => switch (_period) {
    HabitPeriod.thisWeek => _snapshot.weekFor(_today, habitId: _habitId),
    HabitPeriod.thisMonth => _snapshot.monthFor(
      DateTime(_today.year, _today.month),
      habitId: _habitId,
    ),
    HabitPeriod.lastMonth => _snapshot.monthFor(
      DateTime(_today.year, _today.month - 1),
      habitId: _habitId,
    ),
  };

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

  String get editSheetTitle => 'Edit Habit';

  String get editSheetSubtitle => 'Fine-tune what you are tracking';

  String get nameLabel => 'Habit Name';

  String get nameHint => 'e.g. Morning Run, Cold Shower...';

  String get descriptionLabel => 'Description (optional)';

  String get descriptionHint => 'e.g. Run for at least 5km';

  String get targetLabel => 'Target & Unit';

  String get metricSheetSubtitle => 'Pick the unit you want to track in';

  String get targetHint => 'e.g. 10';

  String get submitLabel => 'Save Changes';

  String get initialName => _detail?.title ?? '';

  String get initialDescription => _detail?.description ?? '';

  String get initialTarget => HabitLabels.decimal(_detail?.target ?? 0);

  HabitMetric get initialMetric => _detail?.metric ?? HabitMetric.minutes;

  void selectPeriod(HabitPeriod period) {
    if (period == _period) return;
    _period = period;
    notifyListeners();
  }

  Future<void> saveHabit(HabitDraft draft) =>
      _run(() => _service.updateHabit(_habitId, draft));

  Future<void> deleteHabit() => _run(() async {
    await _service.deleteHabit(_habitId);
    await _service.saveDay(_today, [
      for (final habit in _snapshot.habitsFor(_today))
        if (habit.id != _habitId) habit,
    ]);
  });

  Future<void> logProgress(double value) => _run(() {
    final habits = [
      for (final habit in _snapshot.habitsFor(_today))
        if (habit.id == _habitId)
          habit.copyWith(value: value < 0 ? 0 : value)
        else
          habit,
    ];
    return _service.saveDay(_today, habits);
  });

  Future<void> _run(Future<void> Function() action) async {
    _actionMessage = null;
    try {
      await action();
    } on HabitException catch (e) {
      _actionMessage = e.message;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
