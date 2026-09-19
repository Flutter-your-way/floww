import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/entities/workout_session_log_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';
import 'package:floww/core/progress/services/flow_score_calculator.dart';
import 'package:floww/core/progress/services/progress_service.dart';

class ProgressSnapshotResult {
  const ProgressSnapshotResult({
    required this.snapshot,
    required this.pendingFlowWrites,
    required this.flowHistory,
  });

  final ProgressSnapshot snapshot;
  final List<DailyFlowEntry> pendingFlowWrites;
  final List<DailyFlowEntry> flowHistory;
}

class ProgressSnapshotBuilder {
  const ProgressSnapshotBuilder({
    this._calculator = const FlowScoreCalculator(),
  });

  static const int _weekLength = DateTime.daysPerWeek;
  static const int _insightWindowDays = 30;
  static const int _maxHabitRows = 5;
  static const int _maxRecords = 3;
  static const double _proteinPerKg = 1.6;
  static const double _waterTargetMl = 2500;
  static const double _volumeTargetSetsPerWeek = 80;
  static const double _defaultBodyWeightKg = 70;

  static const List<ProgressChecklistItem> _checklistTemplate = [
    ProgressChecklistItem(
      id: 'log_meal',
      label: 'Log your first meal',
      isCompleted: false,
    ),
    ProgressChecklistItem(
      id: 'complete_workout',
      label: 'Complete a workout',
      isCompleted: false,
    ),
    ProgressChecklistItem(
      id: 'setup_habits',
      label: 'Set up your habits',
      isCompleted: false,
    ),
    ProgressChecklistItem(
      id: 'starting_weight',
      label: 'Add your starting weight',
      isCompleted: false,
    ),
    ProgressChecklistItem(
      id: 'explore_flow',
      label: 'Explore your Flow Score',
      isCompleted: false,
    ),
  ];

  final FlowScoreCalculator _calculator;

  ProgressSnapshotResult build(ProgressRecords records, {DateTime? now}) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final setsByDay = _setsByDay(records.sessions);
    final habitByDay = {
      for (final day in records.habitDays) AppDateUtils.dateKey(day.date): day,
    };
    final mealsByDay = <String, int>{};
    final proteinByDay = <String, double>{};
    for (final log in records.nutrition.foods) {
      final key = AppDateUtils.dateKey(log.loggedAt);
      mealsByDay[key] = (mealsByDay[key] ?? 0) + 1;
      proteinByDay[key] = (proteinByDay[key] ?? 0) + log.macros.proteinG;
    }
    final waterByDay = <String, double>{};
    for (final log in records.nutrition.waters) {
      final key = AppDateUtils.dateKey(log.loggedAt);
      waterByDay[key] = (waterByDay[key] ?? 0) + log.amountMl;
    }

    final storedFlow = {
      for (final entry in records.storedFlow)
        AppDateUtils.dateKey(entry.date): entry,
    };
    final computedFlow = <String, DailyFlowEntry>{};
    for (var offset = ProgressService.habitHistoryDays; offset >= 0; offset--) {
      final date = AppDateUtils.addDays(today, -offset);
      final key = AppDateUtils.dateKey(date);
      computedFlow[key] = _calculator.scoreOf(
        FlowScoreInputs(
          date: date,
          workoutSets: setsByDay[key] ?? 0,
          habitCompletion: habitByDay[key]?.completion ?? 0,
          mealCount: mealsByDay[key] ?? 0,
          waterMl: waterByDay[key] ?? 0,
        ),
      );
    }

    final flow = <String, DailyFlowEntry>{...storedFlow};
    final pendingFlowWrites = <DailyFlowEntry>[];
    final weekStart = AppDateUtils.startOfWeek(today);
    computedFlow.forEach((key, entry) {
      if (storedFlow.containsKey(key)) return;
      if (!entry.hasActivity) return;
      flow[key] = entry;
      if (!entry.date.isBefore(weekStart)) pendingFlowWrites.add(entry);
    });

    final weekDays = [
      for (var index = 0; index < _weekLength; index++)
        AppDateUtils.addDays(weekStart, index),
    ];
    final weekScores = [
      for (final date in weekDays)
        if (!date.isAfter(today))
          flow[AppDateUtils.dateKey(date)] ?? DailyFlowEntry.empty(date),
    ];
    final activeWeekScores = [
      for (final entry in weekScores)
        if (entry.hasActivity) entry,
    ];

    return ProgressSnapshotResult(
      snapshot: ProgressSnapshot(
        averageFlow: _averageOf([
          for (var offset = 0; offset < _weekLength; offset++)
            flow[AppDateUtils.dateKey(AppDateUtils.addDays(today, -offset))],
        ]),
        streakDays: _streakOf(flow, today),
        completedWorkouts: records.sessions
            .where((session) => session.isCompleted)
            .length,
        flowScore: _flowSummary(
          flow: flow,
          today: today,
          weekDays: weekDays,
          activeWeekScores: activeWeekScores,
        ),
        insights: _insights(
          flow: flow,
          setsByDay: setsByDay,
          proteinByDay: proteinByDay,
          waterByDay: waterByDay,
          habitByDay: habitByDay,
          bodyWeightKg: _currentWeightOf(records),
          today: today,
        ),
        weight: _weight(records, today),
        volume: _volume(records.sessions, weekDays, today),
        habits: _habits(records.habitDays, weekStart, today),
        records: _records(flow, today),
        checklist: _checklist(records, flow),
      ),
      pendingFlowWrites: pendingFlowWrites,
      flowHistory: flow.values.toList(),
    );
  }

  Map<String, int> _setsByDay(List<WorkoutSessionLog> sessions) {
    final sets = <String, int>{};
    for (final session in sessions) {
      if (!session.isCompleted) continue;
      final key = AppDateUtils.dateKey(session.date);
      sets[key] = (sets[key] ?? 0) + session.totalSets;
    }
    return sets;
  }

  FlowScoreSummary _flowSummary({
    required Map<String, DailyFlowEntry> flow,
    required DateTime today,
    required List<DateTime> weekDays,
    required List<DailyFlowEntry> activeWeekScores,
  }) {
    if (activeWeekScores.isEmpty) return const FlowScoreSummary.empty();

    final todayEntry = flow[AppDateUtils.dateKey(today)];
    final best = activeWeekScores.reduce(
      (best, entry) => entry.score >= best.score ? entry : best,
    );
    final worst = activeWeekScores.reduce(
      (worst, entry) => entry.score <= worst.score ? entry : worst,
    );
    final average = _averageOf(activeWeekScores);
    final previousStart = AppDateUtils.addDays(
      AppDateUtils.startOfWeek(today),
      -_weekLength,
    );
    final previousAverage = _averageOf([
      for (var index = 0; index < _weekLength; index++)
        flow[AppDateUtils.dateKey(AppDateUtils.addDays(previousStart, index))],
    ]);

    return FlowScoreSummary(
      score: todayEntry?.score ?? 0,
      weeklyDelta: average - previousAverage,
      bestScore: best.score,
      bestDay: AppDateUtils.weekdayName(best.date),
      worstScore: worst.score,
      worstDay: AppDateUtils.weekdayName(worst.date),
      averageScore: average,
      days: [
        for (final date in weekDays)
          FlowScoreDay(
            label: AppDateUtils.shortWeekday(date),
            percent: date.isAfter(today)
                ? 0
                : (flow[AppDateUtils.dateKey(date)]?.score ?? 0),
          ),
      ],
    );
  }

  WaveInsights? _insights({
    required Map<String, DailyFlowEntry> flow,
    required Map<String, int> setsByDay,
    required Map<String, double> proteinByDay,
    required Map<String, double> waterByDay,
    required Map<String, HabitDayLog> habitByDay,
    required double bodyWeightKg,
    required DateTime today,
  }) {
    final current = _componentScores(
      start: AppDateUtils.addDays(today, -_insightWindowDays + 1),
      flow: flow,
      setsByDay: setsByDay,
      proteinByDay: proteinByDay,
      waterByDay: waterByDay,
      habitByDay: habitByDay,
      bodyWeightKg: bodyWeightKg,
    );
    if (current.values.every((score) => score == 0)) return null;

    final previous = _componentScores(
      start: AppDateUtils.addDays(today, -_insightWindowDays * 2 + 1),
      flow: flow,
      setsByDay: setsByDay,
      proteinByDay: proteinByDay,
      waterByDay: waterByDay,
      habitByDay: habitByDay,
      bodyWeightKg: bodyWeightKg,
      length: _insightWindowDays,
    );

    var improvement = current.keys.first;
    var weakness = current.keys.first;
    for (final label in current.keys) {
      final delta = current[label]! - (previous[label] ?? 0);
      final bestDelta = current[improvement]! - (previous[improvement] ?? 0);
      if (delta > bestDelta) improvement = label;
      if (current[label]! < current[weakness]!) weakness = label;
    }
    if (improvement == weakness) {
      for (final label in current.keys) {
        if (label != weakness && current[label]! >= current[improvement]!) {
          improvement = label;
        }
      }
    }

    return WaveInsights(improvement: improvement, weakness: weakness);
  }

  Map<String, double> _componentScores({
    required DateTime start,
    required Map<String, DailyFlowEntry> flow,
    required Map<String, int> setsByDay,
    required Map<String, double> proteinByDay,
    required Map<String, double> waterByDay,
    required Map<String, HabitDayLog> habitByDay,
    required double bodyWeightKg,
    int length = _insightWindowDays,
  }) {
    var activeDays = 0;
    var sets = 0;
    var protein = 0.0;
    var water = 0.0;
    var habit = 0.0;

    for (var index = 0; index < length; index++) {
      final key = AppDateUtils.dateKey(AppDateUtils.addDays(start, index));
      if (flow[key]?.hasActivity ?? false) activeDays++;
      sets += setsByDay[key] ?? 0;
      protein += proteinByDay[key] ?? 0;
      water += waterByDay[key] ?? 0;
      habit += habitByDay[key]?.completion ?? 0;
    }

    final weeks = length / _weekLength;
    final proteinTarget = bodyWeightKg * _proteinPerKg * length;
    final waterTarget = _waterTargetMl * length;
    final volumeTarget = _volumeTargetSetsPerWeek * weeks;

    return {
      'Consistency': _ratio(activeDays / length),
      'Workout volume': _ratio(sets / volumeTarget),
      'Habits': _ratio(habit / length),
      'Protein intake': _ratio(protein / proteinTarget),
      'Hydration': _ratio(water / waterTarget),
    };
  }

  double _ratio(double value) =>
      value.isFinite ? (value.clamp(0.0, 1.0)) * 100 : 0;

  double _currentWeightOf(ProgressRecords records) {
    if (records.weights.isNotEmpty) return records.weights.last.weightKg;
    return records.goals.startWeightKg ?? _defaultBodyWeightKg;
  }

  WeightTracking _weight(ProgressRecords records, DateTime today) {
    final entries = [
      for (final log in records.weights)
        WeightEntry(id: log.id, date: log.loggedAt, weight: log.weightKg),
    ];
    final startWeight =
        records.goals.startWeightKg ??
        (entries.isEmpty ? 0 : entries.first.weight);
    final weekAgo = AppDateUtils.addDays(today, -_weekLength);
    final recent = [
      for (final entry in entries)
        if (!entry.date.isBefore(weekAgo)) entry,
    ];
    final weeklyChange = recent.length < 2
        ? 0.0
        : recent.last.weight - recent.first.weight;

    return WeightTracking(
      entries: entries,
      targetWeight: records.goals.targetWeightKg ?? 0,
      startWeight: startWeight,
      weeklyChange: weeklyChange,
    );
  }

  WorkoutVolume _volume(
    List<WorkoutSessionLog> sessions,
    List<DateTime> weekDays,
    DateTime today,
  ) {
    final setsByDay = _setsByDay(sessions);
    return WorkoutVolume(
      days: [
        for (final date in weekDays)
          VolumeDay(
            label: AppDateUtils.shortWeekday(date),
            sets: date.isAfter(today)
                ? 0
                : (setsByDay[AppDateUtils.dateKey(date)] ?? 0),
          ),
      ],
    );
  }

  List<HabitConsistencyItem> _habits(
    List<HabitDayLog> habitDays,
    DateTime weekStart,
    DateTime today,
  ) {
    final titles = <String, String>{};
    final completed = <String, int>{};

    for (final day in habitDays) {
      if (day.date.isBefore(weekStart) || day.date.isAfter(today)) continue;
      for (final entry in day.entries) {
        titles[entry.id] = entry.title;
        completed[entry.id] =
            (completed[entry.id] ?? 0) + (entry.isCompleted ? 1 : 0);
      }
    }

    final items = [
      for (final id in titles.keys)
        HabitConsistencyItem(
          label: titles[id]!,
          completedDays: completed[id] ?? 0,
          targetDays: _weekLength,
        ),
    ]..sort((a, b) => b.completedDays.compareTo(a.completedDays));

    return items.length <= _maxHabitRows
        ? items
        : items.sublist(0, _maxHabitRows);
  }

  List<PersonalRecord> _records(
    Map<String, DailyFlowEntry> flow,
    DateTime today,
  ) {
    final entries = flow.values.where((entry) => entry.hasActivity).toList();
    if (entries.isEmpty) return const [];

    final highest = entries.reduce(
      (best, entry) => entry.score >= best.score ? entry : best,
    );
    final longestStreak = _longestStreakOf(flow, today);
    final bestWeek = _bestWeekAverageOf(flow, today);

    return [
      PersonalRecord(
        label: 'Longest Streak',
        value: '$longestStreak',
        caption: 'Days',
        tone: ProgressTone.accent,
      ),
      PersonalRecord(
        label: 'Highest FLOW',
        value: '${highest.score}',
        caption: 'Score',
        tone: ProgressTone.primary,
      ),
      PersonalRecord(
        label: 'Best Week',
        value: '$bestWeek',
        caption: 'Avg score',
        tone: ProgressTone.neutral,
      ),
    ].take(_maxRecords).toList();
  }

  List<ProgressChecklistItem> _checklist(
    ProgressRecords records,
    Map<String, DailyFlowEntry> flow,
  ) {
    if (records.state.isChecklistDismissed) return const [];

    final derived = {
      'log_meal': records.nutrition.foods.isNotEmpty,
      'complete_workout': records.sessions.isNotEmpty,
      'setup_habits': records.habitDays.isNotEmpty,
      'starting_weight': records.weights.isNotEmpty,
      'explore_flow': flow.values.any((entry) => entry.hasActivity),
    };
    final items = [
      for (final item in _checklistTemplate)
        item.copyWith(
          isCompleted:
              (derived[item.id] ?? false) ||
              records.state.completedChecklistIds.contains(item.id),
        ),
    ];

    return items.every((item) => item.isCompleted) ? const [] : items;
  }

  int _streakOf(Map<String, DailyFlowEntry> flow, DateTime today) {
    var streak = 0;
    var cursor = today;
    if (!(flow[AppDateUtils.dateKey(cursor)]?.hasActivity ?? false)) {
      cursor = AppDateUtils.addDays(cursor, -1);
    }
    while (flow[AppDateUtils.dateKey(cursor)]?.hasActivity ?? false) {
      streak++;
      cursor = AppDateUtils.addDays(cursor, -1);
    }
    return streak;
  }

  int _longestStreakOf(Map<String, DailyFlowEntry> flow, DateTime today) {
    var longest = 0;
    var running = 0;
    for (var offset = ProgressService.historyDays; offset >= 0; offset--) {
      final key = AppDateUtils.dateKey(AppDateUtils.addDays(today, -offset));
      if (flow[key]?.hasActivity ?? false) {
        running++;
        if (running > longest) longest = running;
      } else {
        running = 0;
      }
    }
    return longest;
  }

  int _bestWeekAverageOf(Map<String, DailyFlowEntry> flow, DateTime today) {
    final weekStart = AppDateUtils.startOfWeek(today);
    var best = 0;
    for (
      var week = 0;
      week * _weekLength <= ProgressService.historyDays;
      week++
    ) {
      final start = AppDateUtils.addDays(weekStart, -week * _weekLength);
      final average = _averageOf([
        for (var index = 0; index < _weekLength; index++)
          flow[AppDateUtils.dateKey(AppDateUtils.addDays(start, index))],
      ]);
      if (average > best) best = average;
    }
    return best;
  }

  int _averageOf(List<DailyFlowEntry?> entries) {
    final active = [
      for (final entry in entries)
        if (entry != null && entry.hasActivity) entry.score,
    ];
    if (active.isEmpty) return 0;
    return (active.reduce((sum, score) => sum + score) / active.length).round();
  }
}
