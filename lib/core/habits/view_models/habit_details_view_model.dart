import 'package:flutter/foundation.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_day.dart';
import 'package:floww/core/habits/models/habit_detail.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/habits/models/habit_period.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/habits/view_models/habit_labels.dart';

class HabitDetailsViewModel extends ChangeNotifier {
  HabitDetailsViewModel(this._service, this._habitId);

  final HabitService _service;
  final String _habitId;

  HabitPeriod _period = HabitPeriod.thisMonth;

  HabitDetail? get _detail => _service.detailFor(_habitId);

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

  String get progressTitle => 'Habit Progress';

  String get aboutTitle => 'About This Habit';

  String get aboutMessage => _detail?.about ?? '';

  String get periodSheetTitle => 'Habit Progress';

  String get periodSheetSubtitle => 'Choose the range you want to review';

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

  List<HabitDay> get _days => _service.daysFor(_period);

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

  void saveHabit(HabitDraft draft) {
    _service.updateHabit(_habitId, draft);
    notifyListeners();
  }
}
