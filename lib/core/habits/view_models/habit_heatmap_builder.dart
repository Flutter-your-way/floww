import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_day.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/habits/services/habit_snapshot_builder.dart';
import 'package:floww/core/habits/view_models/habit_labels.dart';

class HabitHeatmapBuilder {
  HabitHeatmapBuilder._();

  static const int _minLabelGap = 3;
  static const double _lowLimit = 0.34;
  static const double _mediumLimit = 0.67;
  static const Set<int> _labelledWeekdays = {
    DateTime.monday,
    DateTime.wednesday,
    DateTime.friday,
  };

  static HabitHeatmapData build(
    HabitSnapshot snapshot, {
    String? habitId,
    DateTime? accountCreatedAt,
  }) {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final start = _startOf(snapshot, today, habitId, accountCreatedAt);
    final firstWeek = AppDateUtils.startOfWeek(start);
    final weekCount =
        AppDateUtils.daysBetween(firstWeek, AppDateUtils.startOfWeek(today)) ~/
            DateTime.daysPerWeek +
        1;
    final weeks = <List<HabitHeatmapCell?>>[];
    final months = <HabitHeatmapMonth>[];
    var completedDays = 0;
    int? lastMonth;

    for (var week = 0; week < weekCount; week++) {
      final weekStart = AppDateUtils.addDays(
        firstWeek,
        week * DateTime.daysPerWeek,
      );
      if (weekStart.month != lastMonth) {
        months.add(
          HabitHeatmapMonth(
            weekIndex: week,
            label: AppDateUtils.shortMonth(weekStart),
          ),
        );
        lastMonth = weekStart.month;
      }
      final cells = <HabitHeatmapCell?>[];
      for (var offset = 0; offset < DateTime.daysPerWeek; offset++) {
        final date = AppDateUtils.addDays(weekStart, offset);
        if (date.isBefore(start) || date.isAfter(today)) {
          cells.add(null);
          continue;
        }
        final day = snapshot.dayFor(date, habitId: habitId);
        if (day.status == HabitDayStatus.completed) completedDays++;
        cells.add(_cellOf(snapshot, day, today, habitId));
      }
      weeks.add(cells);
    }

    if (months.length > 1 &&
        months[1].weekIndex - months.first.weekIndex < _minLabelGap) {
      months.removeAt(0);
    }
    final startLabel = AppDateUtils.dayMonth(
      start,
      withYear: start.year != today.year,
    );
    return HabitHeatmapData(
      weeks: weeks,
      months: months,
      weekdayLabels: [
        for (var offset = 0; offset < DateTime.daysPerWeek; offset++)
          _labelledWeekdays.contains(offset + 1)
              ? AppDateUtils.shortWeekday(
                  AppDateUtils.addDays(firstWeek, offset),
                )
              : null,
      ],
      summaryLabel:
          '$completedDays ${completedDays == 1 ? 'day' : 'days'} fully '
          'completed since $startLabel',
    );
  }

  static DateTime _startOf(
    HabitSnapshot snapshot,
    DateTime today,
    String? habitId,
    DateTime? accountCreatedAt,
  ) {
    final tracked = snapshot.firstTrackedDay(habitId: habitId);
    final joined = accountCreatedAt == null
        ? tracked
        : AppDateUtils.dateOnly(accountCreatedAt);
    final earliest = AppDateUtils.addDays(today, -HabitService.historyDays);
    var start = tracked.isBefore(joined) ? tracked : joined;
    if (start.isBefore(earliest)) start = earliest;
    return start.isAfter(today) ? today : start;
  }

  static HabitHeatmapCell _cellOf(
    HabitSnapshot snapshot,
    HabitDay day,
    DateTime today,
    String? habitId,
  ) {
    final date = day.date;
    final isToday = AppDateUtils.isSameDay(date, today);
    final habits = [
      for (final habit in snapshot.habitsFor(date))
        if (habitId == null || habit.id == habitId) habit,
    ];
    final entries = [
      for (final habit in habits)
        HabitHeatmapEntry(
          title: habit.title,
          detail: _detailOf(habit),
          status: _entryStatusOf(habit, isToday),
          progress: habit.progress,
          percentLabel: HabitLabels.percent(habit.progress),
        ),
    ]..sort((a, b) => _rankOf(a.status).compareTo(_rankOf(b.status)));
    final weekday = AppDateUtils.weekdayName(date).toUpperCase();
    return HabitHeatmapCell(
      date: date,
      level: _levelOf(day),
      isToday: isToday,
      weekdayLabel: isToday ? '$weekday · TODAY' : weekday,
      dateLabel: AppDateUtils.dayMonth(date, withYear: date.year != today.year),
      summaryLabel: _summaryOf(day, habits),
      completion: day.completion,
      percentLabel: HabitLabels.percent(day.completion),
      entries: entries,
    );
  }

  static int _rankOf(HabitDayStatus status) => switch (status) {
    HabitDayStatus.completed => 0,
    HabitDayStatus.partial => 1,
    HabitDayStatus.missed => 2,
    HabitDayStatus.rest => 3,
    HabitDayStatus.upcoming => 4,
  };

  static String _summaryOf(HabitDay day, List<Habit> habits) {
    final due = habits.where((habit) => habit.isDue).toList();
    final done = due.where((habit) => habit.isCompleted).length;
    return switch (day.status) {
      HabitDayStatus.completed => 'Perfect day · all $done done',
      HabitDayStatus.partial => '$done of ${due.length} habits done',
      HabitDayStatus.missed => 'Missed · 0 of ${due.length} done',
      HabitDayStatus.rest => 'Rest day · nothing scheduled',
      HabitDayStatus.upcoming => 'No habits tracked',
    };
  }

  static String _detailOf(Habit habit) {
    if (habit.isQuit) return habit.value > 0 ? 'Slipped' : 'Clean';
    return HabitLabels.progress(habit);
  }

  static HabitDayStatus _entryStatusOf(Habit habit, bool isToday) {
    if (habit.isCompleted) return HabitDayStatus.completed;
    if (!habit.isDue) return HabitDayStatus.rest;
    if (habit.progress > 0 || isToday) return HabitDayStatus.partial;
    return HabitDayStatus.missed;
  }

  static HabitHeatmapLevel _levelOf(HabitDay day) {
    switch (day.status) {
      case HabitDayStatus.completed:
        return HabitHeatmapLevel.full;
      case HabitDayStatus.rest:
      case HabitDayStatus.upcoming:
      case HabitDayStatus.missed:
        return HabitHeatmapLevel.empty;
      case HabitDayStatus.partial:
        final completion = day.completion;
        if (completion <= 0) return HabitHeatmapLevel.empty;
        if (completion < _lowLimit) return HabitHeatmapLevel.low;
        if (completion < _mediumLimit) return HabitHeatmapLevel.medium;
        return HabitHeatmapLevel.high;
    }
  }
}
