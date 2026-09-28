import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/workout/models/workout_history.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';

class WorkoutHistoryAnalyzer {
  WorkoutHistoryAnalyzer._();

  static const int consistencyWeeks = 4;
  static const int catchUpWindowDays = 1;
  static const int prioritizeWindowDays = 7;
  static const int patternThreshold = 2;
  static const int _topMuscles = 2;
  static const double _coveredShare = 0.5;

  static WorkoutHistoryAnalysis analyze({
    required DateTime today,
    required DateTime from,
    required List<WorkoutPlanEntity> plans,
    required List<WorkoutSessionEntity> sessions,
    required ActiveProgramEntry? activeProgram,
  }) {
    final plansByDay = {
      for (final plan in plans) AppDateUtils.dateKey(plan.date): plan,
    };
    final sessionsByDay = <String, List<WorkoutSessionEntity>>{};
    for (final session in sessions) {
      sessionsByDay
          .putIfAbsent(AppDateUtils.dateKey(session.date), () => [])
          .add(session);
    }
    final todaySessions =
        sessionsByDay[AppDateUtils.dateKey(today)] ?? const [];

    final end = AppDateUtils.endOfWeek(today);
    final days = <WorkoutHistoryDay>[];
    for (
      var date = AppDateUtils.dateOnly(from);
      !date.isAfter(end);
      date = AppDateUtils.addDays(date, 1)
    ) {
      final key = AppDateUtils.dateKey(date);
      final plan = plansByDay[key];
      final daySessions = sessionsByDay[key] ?? const [];
      final outcome = _outcomeOf(date, today, plan, daySessions);
      days.add(
        WorkoutHistoryDay(
          date: date,
          outcome: outcome,
          plan: plan,
          sessions: daySessions,
          insight: outcome == WorkoutDayOutcome.missed && plan != null
              ? _insightOf(
                  plan: plan,
                  date: date,
                  today: today,
                  sessions: sessions,
                  todaySessions: todaySessions,
                  activeProgram: activeProgram,
                )
              : null,
        ),
      );
    }

    final windowStart = AppDateUtils.addDays(
      AppDateUtils.startOfWeek(today),
      -DateTime.daysPerWeek * (consistencyWeeks - 1),
    );
    final consistencyDays = [
      for (final day in days)
        if (!day.date.isBefore(windowStart)) day,
    ];

    return WorkoutHistoryAnalysis(
      days: days,
      consistencyDays: consistencyDays,
      consistency: _consistencyOf(consistencyDays, days),
    );
  }

  static WorkoutDayOutcome _outcomeOf(
    DateTime date,
    DateTime today,
    WorkoutPlanEntity? plan,
    List<WorkoutSessionEntity> sessions,
  ) {
    if (sessions.any((session) => session.isCompleted)) {
      return WorkoutDayOutcome.completed;
    }
    final isPast = date.isBefore(today);
    if (sessions.isNotEmpty) {
      return isPast ? WorkoutDayOutcome.partial : WorkoutDayOutcome.pending;
    }
    if (plan == null) return WorkoutDayOutcome.rest;
    return isPast ? WorkoutDayOutcome.missed : WorkoutDayOutcome.pending;
  }

  static MissedWorkoutInsight _insightOf({
    required WorkoutPlanEntity plan,
    required DateTime date,
    required DateTime today,
    required List<WorkoutSessionEntity> sessions,
    required List<WorkoutSessionEntity> todaySessions,
    required ActiveProgramEntry? activeProgram,
  }) {
    final muscles = musclesOf(plan);
    final keyExercise = keyExerciseOf(plan);
    final age = AppDateUtils.daysBetween(date, today);
    final coveredOn = _coveredOn(muscles, date, sessions);

    final canCatchUp =
        age == catchUpWindowDays &&
        todaySessions.isEmpty &&
        activeProgram != null &&
        plan.programId == activeProgram.id;

    final recovery = canCatchUp
        ? MissedRecovery.catchUp
        : coveredOn != null
        ? MissedRecovery.covered
        : age <= prioritizeWindowDays
        ? MissedRecovery.prioritize
        : MissedRecovery.letGo;

    return MissedWorkoutInsight(
      recovery: recovery,
      muscles: muscles,
      coveredOn: coveredOn,
      keyExercise: keyExercise,
    );
  }

  static List<String> musclesOf(WorkoutPlanEntity plan) {
    final main = [
      for (final entry in plan.exercises)
        if (entry.section == WorkoutSectionKind.main) entry,
    ];
    final scores = <String, double>{};
    for (final entry in main.isEmpty ? plan.exercises : main) {
      for (final share in entry.muscleShares.entries) {
        scores[share.key] =
            (scores[share.key] ?? 0) + share.value * entry.targetSets;
      }
    }
    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [for (final entry in ranked.take(_topMuscles)) entry.key];
  }

  static String? keyExerciseOf(WorkoutPlanEntity plan) {
    for (final entry in plan.exercises) {
      if (entry.section == WorkoutSectionKind.main) return entry.name;
    }
    return plan.exercises.isEmpty ? null : plan.exercises.first.name;
  }

  static DateTime? _coveredOn(
    List<String> muscles,
    DateTime missedOn,
    List<WorkoutSessionEntity> sessions,
  ) {
    if (muscles.isEmpty) return null;
    final target = muscles.first;
    DateTime? earliest;
    for (final session in sessions) {
      if (!session.isCompleted || !session.date.isAfter(missedOn)) continue;
      final hit = session.muscleActivation.any(
        (muscle) => muscle.name == target && muscle.share >= _coveredShare,
      );
      if (!hit) continue;
      if (earliest == null || session.date.isBefore(earliest)) {
        earliest = session.date;
      }
    }
    return earliest;
  }

  static WorkoutConsistency _consistencyOf(
    List<WorkoutHistoryDay> window,
    List<WorkoutHistoryDay> all,
  ) {
    var planned = 0;
    var completedPlanned = 0;
    var workouts = 0;
    var missed = 0;
    for (final day in window) {
      if (day.outcome == WorkoutDayOutcome.completed) workouts++;
      if (day.outcome == WorkoutDayOutcome.missed) missed++;
      if (!day.isPlanned || day.outcome == WorkoutDayOutcome.pending) continue;
      planned++;
      if (day.outcome == WorkoutDayOutcome.completed) completedPlanned++;
    }

    var streak = 0;
    var missedInRow = 0;
    var streakOpen = true;
    var missedOpen = true;
    for (final day in all.reversed) {
      switch (day.outcome) {
        case WorkoutDayOutcome.pending || WorkoutDayOutcome.rest:
          continue;
        case WorkoutDayOutcome.completed:
          if (streakOpen) streak++;
          missedOpen = false;
        case WorkoutDayOutcome.missed:
          if (missedOpen) missedInRow++;
          streakOpen = false;
        case WorkoutDayOutcome.partial:
          streakOpen = false;
          missedOpen = false;
      }
      if (!streakOpen && !missedOpen) break;
    }

    final missedByWeekday = <int, int>{};
    for (final day in all) {
      if (day.outcome != WorkoutDayOutcome.missed) continue;
      missedByWeekday[day.date.weekday] =
          (missedByWeekday[day.date.weekday] ?? 0) + 1;
    }
    int? mostMissedWeekday;
    var mostMissedCount = 0;
    var isTied = false;
    for (final entry in missedByWeekday.entries) {
      if (entry.value > mostMissedCount) {
        mostMissedWeekday = entry.key;
        mostMissedCount = entry.value;
        isTied = false;
      } else if (entry.value == mostMissedCount) {
        isTied = true;
      }
    }
    final hasPattern = !isTied && mostMissedCount >= patternThreshold;

    return WorkoutConsistency(
      planned: planned,
      completed: completedPlanned,
      workouts: workouts,
      missed: missed,
      streak: streak,
      missedInRow: missedInRow,
      mostMissedWeekday: hasPattern ? mostMissedWeekday : null,
      mostMissedCount: hasPattern ? mostMissedCount : 0,
    );
  }
}
