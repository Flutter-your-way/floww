import 'package:firebase_auth/firebase_auth.dart';

import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/health/services/health_log_service.dart';
import 'package:floww/core/home/services/home_service.dart';
import 'package:floww/core/home/services/home_snapshot_builder.dart';
import 'package:floww/core/nutrition/services/custom_food_service.dart';
import 'package:floww/core/nutrition/services/nutrition_goal_calculator.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/profile/services/profile_service.dart';
import 'package:floww/core/progress/services/progress_service.dart';
import 'package:floww/core/wave/models/wave_context.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

class WaveContextService {
  WaveContextService({
    HomeService? homeService,
    HomeSnapshotBuilder? builder,
    CustomFoodService? customFoodService,
    WorkoutPlanService? planService,
    WorkoutProgramService? programService,
  }) : _homeService = homeService ?? _defaultHomeService(),
       _customFoodService = customFoodService ?? CustomFoodService(),
       _builder = builder ?? HomeSnapshotBuilder(),
       _planService =
           planService ?? WorkoutPlanService(WorkoutCatalogService()),
       _programService = programService ?? WorkoutProgramService();

  static const int scheduleDays = 7;

  static WaveContext? _cached;
  static String? _cachedKey;

  static String? _cacheKey() {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;
      return '$uid/${AppDateUtils.dateKey(AppDateUtils.dateOnly(DateTime.now()))}';
    } catch (_) {
      return null;
    }
  }

  WaveContext? get cached {
    final key = _cacheKey();
    return key != null && key == _cachedKey ? _cached : null;
  }

  static const NutritionGoalCalculator _goalCalculator =
      NutritionGoalCalculator();

  final HomeService _homeService;
  final CustomFoodService _customFoodService;
  final HomeSnapshotBuilder _builder;
  final WorkoutPlanService _planService;
  final WorkoutProgramService _programService;

  Future<List<WorkoutPlanEntity>> upcomingSchedule() async {
    final tomorrow = AppDateUtils.addDays(
      AppDateUtils.dateOnly(DateTime.now()),
      1,
    );
    final state = await _programService.loadState();
    return _planService.loadScheduleBetween(
      tomorrow,
      AppDateUtils.addDays(tomorrow, scheduleDays),
      activeProgram: state.activeProgram,
    );
  }

  Stream<WaveContext> watch() {
    final now = DateTime.now();
    final today = AppDateUtils.dateOnly(now);

    return _homeService.watchRecords(today).asyncMap((records) async {
      final waters = [
        for (final log in records.nutrition.waters)
          if (AppDateUtils.isSameDay(log.loggedAt, today)) log,
      ];
      final activeSession = records.sessions
          .where(
            (session) =>
                session.isInProgress &&
                AppDateUtils.isSameDay(session.date, today),
          )
          .firstOrNull;
      final waterMl = waters.fold<double>(
        0,
        (total, log) => total + log.amountMl,
      );

      final context = WaveContext(
        snapshot: _builder.build(records, date: now),
        goal: _goalCalculator.build(records.account),
        waterMl: waterMl,
        recentLogs: records.nutrition.foods,
        todayFoods: [
          for (final log in records.nutrition.foods)
            if (AppDateUtils.isSameDay(log.loggedAt, today)) log,
        ],
        todayWaters: waters,
        customFoods: await _customFoodService.loadFoods(),
        plan: records.plan,
        hasActiveWorkout: activeSession != null,
        isReady: true,
        activeSession: activeSession,
        flowModeOverride: records.flowModeOverride,
        account: records.account,
      );
      _cached = context;
      _cachedKey = _cacheKey();
      return context;
    });
  }

  static HomeService _defaultHomeService() {
    final catalogService = WorkoutCatalogService();
    return HomeService(
      ProfileService(),
      HabitService(),
      NutritionLogService(),
      WorkoutPlanService(catalogService),
      WorkoutSessionService(),
      HealthLogService(),
      ProgressService(),
    );
  }
}
