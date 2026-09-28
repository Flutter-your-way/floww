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
import 'package:floww/core/workout/services/workout_session_service.dart';

class WaveContextService {
  WaveContextService({
    HomeService? homeService,
    HomeSnapshotBuilder? builder,
    CustomFoodService? customFoodService,
  }) : _homeService = homeService ?? _defaultHomeService(),
       _customFoodService = customFoodService ?? CustomFoodService(),
       _builder = builder ?? HomeSnapshotBuilder();

  static const NutritionGoalCalculator _goalCalculator =
      NutritionGoalCalculator();

  final HomeService _homeService;
  final CustomFoodService _customFoodService;
  final HomeSnapshotBuilder _builder;

  Stream<WaveContext> watch() {
    final now = DateTime.now();
    final today = AppDateUtils.dateOnly(now);

    return _homeService.watchRecords(today).asyncMap((records) async {
      final waters = [
        for (final log in records.nutrition.waters)
          if (AppDateUtils.isSameDay(log.loggedAt, today)) log,
      ];
      final waterMl = waters.fold<double>(
        0,
        (total, log) => total + log.amountMl,
      );

      return WaveContext(
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
        hasActiveWorkout: records.sessions.any(
          (session) =>
              session.isInProgress &&
              AppDateUtils.isSameDay(session.date, today),
        ),
        isReady: true,
      );
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
