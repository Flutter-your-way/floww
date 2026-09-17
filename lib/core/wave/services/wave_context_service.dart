import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/health/services/health_log_service.dart';
import 'package:floww/core/home/services/home_service.dart';
import 'package:floww/core/home/services/home_snapshot_builder.dart';
import 'package:floww/core/nutrition/services/nutrition_goal_calculator.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/profile/services/profile_service.dart';
import 'package:floww/core/progress/services/progress_service.dart';
import 'package:floww/core/wave/models/wave_context.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

class WaveContextService {
  WaveContextService({HomeService? homeService, HomeSnapshotBuilder? builder})
    : _homeService = homeService ?? _defaultHomeService(),
      _builder = builder ?? HomeSnapshotBuilder();

  static const NutritionGoalCalculator _goalCalculator =
      NutritionGoalCalculator();

  final HomeService _homeService;
  final HomeSnapshotBuilder _builder;

  Stream<WaveContext> watch() {
    final now = DateTime.now();
    final today = AppDateUtils.dateOnly(now);

    return _homeService.watchRecords(today).map((records) {
      final waterMl = records.nutrition.waters
          .where((log) => AppDateUtils.isSameDay(log.loggedAt, today))
          .fold<double>(0, (total, log) => total + log.amountMl);

      return WaveContext(
        snapshot: _builder.build(records, date: now),
        goal: _goalCalculator.build(records.account),
        waterMl: waterMl,
        recentLogs: records.nutrition.foods,
        plan: records.plan,
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
