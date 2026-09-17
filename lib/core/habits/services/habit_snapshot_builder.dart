import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_day.dart';
import 'package:floww/core/habits/models/habit_definition.dart';
import 'package:floww/core/habits/models/habit_detail.dart';
import 'package:floww/core/habits/services/habit_catalog_data.dart';
import 'package:floww/core/habits/services/habit_service.dart';

class HabitSnapshot {
  HabitSnapshot._(this.definitions, this._byDay);

  factory HabitSnapshot.of(HabitRecords records) => HabitSnapshot._(
    records.habits,
    {for (final day in records.days) AppDateUtils.dateKey(day.date): day},
  );

  static final empty = HabitSnapshot._(const [], const {});

  static const int _weekWindowDays = 7;
  static const int _minutesPerHour = 60;

  final List<HabitDefinition> definitions;
  final Map<String, HabitDayLog> _byDay;

  final Map<String, HabitDetail?> _details = {};
  final Map<String, List<Habit>> _habitsByDay = {};

  late final DateTime _today = AppDateUtils.dateOnly(DateTime.now());

  late final HabitStats stats = HabitStats(
    currentStreakDays: currentStreak(),
    longestStreakDays: longestStreak(),
    weeklyAverageMinutes: weeklyAverageMinutes(),
  );

  bool get hasHabits => definitions.isNotEmpty;

  HabitDayLog? logOf(DateTime date) => _byDay[AppDateUtils.dateKey(date)];

  HabitDefinition? definitionOf(String id) =>
      definitions.where((definition) => definition.id == id).firstOrNull;

  List<Habit> habitsFor(DateTime date) => _habitsByDay.putIfAbsent(
    AppDateUtils.dateKey(date),
    () => _buildHabitsFor(AppDateUtils.dateOnly(date)),
  );

  List<Habit> _buildHabitsFor(DateTime day) {
    final log = logOf(day);

    if (!day.isBefore(_today)) {
      return [
        for (final definition in definitions)
          definition.toHabit(value: log?.entryOf(definition.id)?.value ?? 0),
      ];
    }

    if (log != null && log.entries.isNotEmpty) {
      return [
        for (final entry in log.entries)
          Habit(
            id: entry.id,
            title: entry.title,
            value: entry.value,
            target: entry.target,
            metric: HabitDefinition.metricOf(entry.metric),
            description: definitionOf(entry.id)?.description,
          ),
      ];
    }

    return [
      for (final definition in definitions)
        if (definition.existedOn(day)) definition.toHabit(),
    ];
  }

  int trackedCountFor(DateTime date) {
    final log = logOf(date);
    if (log != null && log.entries.isNotEmpty) return log.entries.length;
    return definitions.where((definition) => definition.existedOn(date)).length;
  }

  double completionFor(DateTime date, {String? habitId}) {
    final habits = habitsFor(date);
    if (habitId != null) {
      final habit = habits.where((habit) => habit.id == habitId).firstOrNull;
      return habit?.progress ?? 0;
    }
    if (habits.isEmpty) return 0;
    final total = habits.fold<double>(0, (sum, habit) => sum + habit.progress);
    return total / habits.length;
  }

  HabitDay dayFor(DateTime date, {String? habitId}) {
    final day = AppDateUtils.dateOnly(date);
    if (day.isAfter(_today) || !_isTracked(day, habitId)) {
      return HabitDay(
        date: day,
        completion: 0,
        status: HabitDayStatus.upcoming,
      );
    }
    final completion = completionFor(day, habitId: habitId);
    return HabitDay(
      date: day,
      completion: completion,
      status: _statusOf(day, completion),
    );
  }

  List<HabitDay> weekFor(DateTime date, {String? habitId}) {
    final start = AppDateUtils.startOfWeek(date);
    return [
      for (var index = 0; index < DateTime.daysPerWeek; index++)
        dayFor(AppDateUtils.addDays(start, index), habitId: habitId),
    ];
  }

  List<HabitDay> monthFor(DateTime month, {String? habitId}) {
    final first = DateTime(month.year, month.month);
    final dayCount = DateTime(month.year, month.month + 1, 0).day;
    return [
      for (var index = 0; index < dayCount; index++)
        dayFor(AppDateUtils.addDays(first, index), habitId: habitId),
    ];
  }

  int currentStreak({String? habitId}) {
    final today = _today;
    var cursor = _isComplete(today, habitId)
        ? today
        : AppDateUtils.addDays(today, -1);
    var streak = 0;
    while (_isComplete(cursor, habitId)) {
      streak++;
      cursor = AppDateUtils.addDays(cursor, -1);
    }
    return streak;
  }

  int longestStreak({String? habitId}) {
    var longest = 0;
    var running = 0;
    for (final day in _trackedRange(habitId)) {
      if (_isComplete(day, habitId)) {
        running++;
        if (running > longest) longest = running;
      } else {
        running = 0;
      }
    }
    return longest;
  }

  int totalCompletions({String? habitId}) {
    var total = 0;
    for (final day in _trackedRange(habitId)) {
      if (_isComplete(day, habitId)) total++;
    }
    return total;
  }

  int weeklyAverageMinutes() {
    var minutes = 0.0;
    var trackedDays = 0;
    for (final day in _lastWeek()) {
      if (trackedCountFor(day) == 0) continue;
      trackedDays++;
      for (final entry in logOf(day)?.entries ?? const <HabitLogEntry>[]) {
        minutes += switch (HabitDefinition.metricOf(entry.metric)) {
          HabitMetric.minutes => entry.value,
          HabitMetric.hours => entry.value * _minutesPerHour,
          _ => 0,
        };
      }
    }
    return trackedDays == 0 ? 0 : (minutes / trackedDays).round();
  }

  int weeklyAveragePercent({String? habitId}) {
    var total = 0.0;
    var trackedDays = 0;
    for (final day in _lastWeek()) {
      if (!_isTracked(day, habitId)) continue;
      trackedDays++;
      total += completionFor(day, habitId: habitId);
    }
    return trackedDays == 0 ? 0 : (total / trackedDays * 100).round();
  }

  List<HabitStreak> habitStreaks() => [
    for (final definition in definitions)
      HabitStreak(
        title: definition.title,
        days: currentStreak(habitId: definition.id),
      ),
  ];

  HabitDetail? detailFor(String id) =>
      _details.putIfAbsent(id, () => _buildDetail(id));

  HabitDetail? _buildDetail(String id) {
    final definition = definitionOf(id);
    if (definition == null) return null;
    return HabitDetail(
      id: definition.id,
      title: definition.title,
      description: definition.description ?? '',
      about: definition.about ?? HabitCatalogData.fallbackAbout,
      target: definition.target,
      metric: definition.metric,
      icon: definition.icon,
      currentStreakDays: currentStreak(habitId: id),
      longestStreakDays: longestStreak(habitId: id),
      weeklyAveragePercent: weeklyAveragePercent(habitId: id),
      totalCompletions: totalCompletions(habitId: id),
    );
  }

  List<DateTime> _lastWeek() {
    final today = _today;
    return [
      for (var index = _weekWindowDays - 1; index >= 0; index--)
        AppDateUtils.addDays(today, -index),
    ];
  }

  Iterable<DateTime> _trackedRange(String? habitId) sync* {
    final today = _today;
    var cursor = _firstTrackedDay(habitId);
    while (!cursor.isAfter(today)) {
      yield cursor;
      cursor = AppDateUtils.addDays(cursor, 1);
    }
  }

  DateTime _firstTrackedDay(String? habitId) {
    final today = _today;
    final definition = habitId == null ? null : definitionOf(habitId);
    var first = definition?.createdAt ?? today;
    if (habitId == null) {
      for (final candidate in definitions) {
        if (candidate.createdAt.isBefore(first)) first = candidate.createdAt;
      }
    }
    for (final log in _byDay.values) {
      if (habitId != null && log.entryOf(habitId) == null) continue;
      final day = AppDateUtils.dateOnly(log.date);
      if (day.isBefore(first)) first = day;
    }
    return first;
  }

  bool _isTracked(DateTime date, String? habitId) {
    if (habitId == null) return trackedCountFor(date) > 0;
    if (logOf(date)?.entryOf(habitId) != null) return true;
    final definition = definitionOf(habitId);
    return definition != null && definition.existedOn(date);
  }

  bool _isComplete(DateTime date, String? habitId) =>
      _isTracked(date, habitId) && completionFor(date, habitId: habitId) >= 1;

  HabitDayStatus _statusOf(DateTime date, double completion) {
    if (completion >= 1) return HabitDayStatus.completed;
    if (AppDateUtils.isSameDay(date, _today)) return HabitDayStatus.partial;
    return completion > 0 ? HabitDayStatus.partial : HabitDayStatus.missed;
  }
}
