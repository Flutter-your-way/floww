import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/entities/health_day_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/streams/combine_latest.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/health/services/health_log_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/profile/models/profile_account.dart';
import 'package:floww/core/profile/services/profile_service.dart';
import 'package:floww/core/progress/services/progress_service.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

class HomeRecords {
  const HomeRecords({
    required this.account,
    required this.habits,
    required this.nutrition,
    required this.plan,
    required this.sessions,
    required this.healthDays,
    required this.flowHistory,
  });

  static const empty = HomeRecords(
    account: ProfileAccount.empty,
    habits: HabitRecords.empty,
    nutrition: NutritionLogs.empty,
    plan: null,
    sessions: [],
    healthDays: [],
    flowHistory: [],
  );

  final ProfileAccount account;
  final HabitRecords habits;
  final NutritionLogs nutrition;
  final WorkoutPlanEntity? plan;
  final List<WorkoutSessionEntity> sessions;
  final List<HealthDayLog> healthDays;
  final List<DailyFlowEntry> flowHistory;
}

class HomeService {
  HomeService(
    this._profileService,
    this._habitService,
    this._nutritionLogService,
    this._planService,
    this._sessionService,
    this._healthLogService,
    this._progressService,
  );

  static const int healthHistoryDays = 30;
  static const int flowHistoryDays = 90;

  final ProfileService _profileService;
  final HabitService _habitService;
  final NutritionLogService _nutritionLogService;
  final WorkoutPlanService _planService;
  final WorkoutSessionService _sessionService;
  final HealthLogService _healthLogService;
  final ProgressService _progressService;

  Stream<HomeRecords> watchRecords(DateTime date) {
    final day = AppDateUtils.dateOnly(date);

    return combineLatest([
      _guarded(_profileService.watchAccount(), ProfileAccount.empty, 'profile'),
      _guarded(_habitService.watchRecords(), HabitRecords.empty, 'habits'),
      _guarded(
        _nutritionLogService.watchLogs(day, AppDateUtils.addDays(day, 1)),
        NutritionLogs.empty,
        'nutrition',
      ),
      _guarded<WorkoutPlanEntity?>(
        _planService.watchPlan(day),
        null,
        'workout plan',
      ),
      _guarded<List<WorkoutSessionEntity>>(
        _sessionService.watchRecentSessions(),
        const [],
        'workout sessions',
      ),
      _guarded<List<HealthDayLog>>(
        _healthLogService.watchDays(
          AppDateUtils.addDays(day, -healthHistoryDays),
        ),
        const [],
        'health logs',
      ),
      _guarded<List<DailyFlowEntry>>(
        _progressService.watchDailyFlow(
          AppDateUtils.addDays(day, -flowHistoryDays),
        ),
        const [],
        'daily flow',
      ),
    ]).map(
      (values) => HomeRecords(
        account: values[0]! as ProfileAccount,
        habits: values[1]! as HabitRecords,
        nutrition: values[2]! as NutritionLogs,
        plan: values[3] as WorkoutPlanEntity?,
        sessions: values[4]! as List<WorkoutSessionEntity>,
        healthDays: values[5]! as List<HealthDayLog>,
        flowHistory: values[6]! as List<DailyFlowEntry>,
      ),
    );
  }

  Future<void> saveDailyFlow(DailyFlowEntry entry) =>
      _progressService.saveDailyFlow([entry]);

  Future<void> saveHabitDay(DateTime date, List<Habit> habits) =>
      _habitService.saveDay(date, habits);

  static Stream<Object?> _guarded<T>(
    Stream<T> source,
    T fallback,
    String label,
  ) => source.transform(
    StreamTransformer<T, T>.fromHandlers(
      handleData: (data, sink) => sink.add(data),
      handleError: (error, stackTrace, sink) {
        debugPrint('Home $label stream failed: $error');
        sink.add(fallback);
      },
    ),
  );
}
