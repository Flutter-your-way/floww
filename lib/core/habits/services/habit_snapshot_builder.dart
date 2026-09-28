import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_day.dart';
import 'package:floww/core/habits/models/habit_definition.dart';
import 'package:floww/core/habits/models/habit_detail.dart';
import 'package:floww/core/habits/services/habit_catalog_data.dart';
import 'package:floww/core/habits/services/habit_service.dart';

enum _DayOutcome { hit, miss, skip }

class HabitSnapshot {
  HabitSnapshot._(this.definitions, this._byDay);

  factory HabitSnapshot.of(HabitRecords records) => HabitSnapshot._(
    records.habits,
    {for (final day in records.days) AppDateUtils.dateKey(day.date): day},
  );

  static final empty = HabitSnapshot._(const [], const {});

  static const int _weekWindowDays = 7;

  final List<HabitDefinition> definitions;
  final Map<String, HabitDayLog> _byDay;

  final Map<String, HabitDetail?> _details = {};
  final Map<String, List<Habit>> _habitsByDay = {};

  late final DateTime _today = AppDateUtils.dateOnly(DateTime.now());

  late final HabitStats stats = HabitStats(
    currentStreakDays: currentStreak(),
    longestStreakDays: longestStreak(),
    weeklyCompletionPercent: weeklyAveragePercent(),
  );

  List<HabitDefinition> get activeDefinitions =>
      definitions.where((definition) => !definition.isArchived).toList();

  bool get hasHabits => activeDefinitions.isNotEmpty;

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
          if (_notArchivedOn(definition, day))
            _habitOf(definition, day, log?.entryOf(definition.id)?.value ?? 0),
      ];
    }

    if (log != null && log.entries.isNotEmpty) {
      return [
        for (final entry in log.entries)
          Habit(
            id: entry.id,
            title: HabitDefinition.titleOf(entry.title),
            value: entry.value,
            target: entry.target,
            metric: HabitDefinition.metricOf(entry.metric),
            goalType: entry.isLimit ? HabitGoalType.limit : HabitGoalType.build,
            source: definitionOf(entry.id)?.source ?? HabitSource.manual,
            isDue: entry.due,
            description: definitionOf(entry.id)?.description,
          ),
      ];
    }

    return [
      for (final definition in definitions)
        if (definition.activeOn(day)) _habitOf(definition, day, 0),
    ];
  }

  bool _notArchivedOn(HabitDefinition definition, DateTime day) {
    final archivedAt = definition.archivedAt;
    return archivedAt == null || day.isBefore(archivedAt);
  }

  Habit _habitOf(HabitDefinition definition, DateTime day, double value) {
    final habit = definition.toHabit(value: value);
    return habit.copyWith(isDue: _isDueOn(definition, day, habit.isCompleted));
  }

  bool _isDueOn(HabitDefinition definition, DateTime day, bool isCompleted) {
    final schedule = definition.schedule;
    if (!schedule.isFlexible) return schedule.isScheduledOn(day);
    if (isCompleted) return true;

    var done = 0;
    var cursor = AppDateUtils.startOfWeek(day);
    while (cursor.isBefore(day)) {
      if (logOf(cursor)?.entryOf(definition.id)?.isCompleted ?? false) done++;
      cursor = AppDateUtils.addDays(cursor, 1);
    }
    if (done >= schedule.timesPerWeek) return false;

    final daysLeft = DateTime.daysPerWeek - day.weekday + 1;
    return daysLeft <= schedule.timesPerWeek - done;
  }

  Habit? _habitOn(DateTime date, String habitId) =>
      habitsFor(date).where((habit) => habit.id == habitId).firstOrNull;

  List<Habit> _dueHabits(DateTime date) =>
      habitsFor(date).where((habit) => habit.isDue).toList();

  double completionFor(DateTime date, {String? habitId}) {
    if (habitId != null) return _habitOn(date, habitId)?.progress ?? 0;
    final due = _dueHabits(date);
    if (due.isEmpty) return 0;
    final total = due.fold<double>(0, (sum, habit) => sum + habit.progress);
    return total / due.length;
  }

  HabitDay dayFor(DateTime date, {String? habitId}) {
    final day = AppDateUtils.dateOnly(date);
    if (day.isAfter(_today)) return _dayOf(day, HabitDayStatus.upcoming);

    if (habitId != null) {
      final habit = _habitOn(day, habitId);
      if (habit == null) return _dayOf(day, HabitDayStatus.upcoming);
      if (!habit.isDue && !habit.isCompleted) {
        return _dayOf(day, HabitDayStatus.rest);
      }
      return HabitDay(
        date: day,
        completion: habit.progress,
        status: _statusOf(day, habit.progress),
      );
    }

    final habits = habitsFor(day);
    if (habits.isEmpty) return _dayOf(day, HabitDayStatus.upcoming);
    if (!habits.any((habit) => habit.isDue)) {
      return _dayOf(day, HabitDayStatus.rest);
    }
    final completion = completionFor(day);
    return HabitDay(
      date: day,
      completion: completion,
      status: _statusOf(day, completion),
    );
  }

  HabitDay _dayOf(DateTime day, HabitDayStatus status) =>
      HabitDay(date: day, completion: 0, status: status);

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

  _DayOutcome _outcomeOf(DateTime day, String? habitId) {
    if (habitId != null) {
      final habit = _habitOn(day, habitId);
      if (habit == null) return _DayOutcome.skip;
      if (habit.isCompleted) return _DayOutcome.hit;
      return habit.isDue ? _DayOutcome.miss : _DayOutcome.skip;
    }
    final due = _dueHabits(day);
    if (due.isEmpty) return _DayOutcome.skip;
    return due.every((habit) => habit.isCompleted)
        ? _DayOutcome.hit
        : _DayOutcome.miss;
  }

  int currentStreak({String? habitId}) {
    final first = _firstTrackedDay(habitId);
    var cursor = _outcomeOf(_today, habitId) == _DayOutcome.hit
        ? _today
        : AppDateUtils.addDays(_today, -1);
    var streak = 0;
    while (!cursor.isBefore(first)) {
      switch (_outcomeOf(cursor, habitId)) {
        case _DayOutcome.hit:
          streak++;
        case _DayOutcome.miss:
          return streak;
        case _DayOutcome.skip:
          break;
      }
      cursor = AppDateUtils.addDays(cursor, -1);
    }
    return streak;
  }

  int longestStreak({String? habitId}) {
    var longest = 0;
    var running = 0;
    for (final day in _trackedRange(habitId)) {
      switch (_outcomeOf(day, habitId)) {
        case _DayOutcome.hit:
          running++;
          if (running > longest) longest = running;
        case _DayOutcome.miss:
          if (!AppDateUtils.isSameDay(day, _today)) running = 0;
        case _DayOutcome.skip:
          break;
      }
    }
    return longest;
  }

  int totalCompletions({String? habitId}) {
    var total = 0;
    for (final day in _trackedRange(habitId)) {
      if (_outcomeOf(day, habitId) == _DayOutcome.hit) total++;
    }
    return total;
  }

  int weeklyAveragePercent({String? habitId}) {
    var total = 0.0;
    var trackedDays = 0;
    for (final day in _lastWeek()) {
      if (habitId != null) {
        final habit = _habitOn(day, habitId);
        if (habit == null || (!habit.isDue && !habit.isCompleted)) continue;
        trackedDays++;
        total += habit.progress;
        continue;
      }
      if (_dueHabits(day).isEmpty) continue;
      trackedDays++;
      total += completionFor(day);
    }
    return trackedDays == 0 ? 0 : (total / trackedDays * 100).round();
  }

  List<HabitStreak> habitStreaks() => [
    for (final definition in activeDefinitions)
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
      schedule: definition.schedule,
      goalType: definition.goalType,
      source: definition.source,
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

  HabitDayStatus _statusOf(DateTime date, double completion) {
    if (completion >= 1) return HabitDayStatus.completed;
    if (AppDateUtils.isSameDay(date, _today)) return HabitDayStatus.partial;
    return completion > 0 ? HabitDayStatus.partial : HabitDayStatus.missed;
  }
}
