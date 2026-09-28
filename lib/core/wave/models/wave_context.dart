import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/core/nutrition/models/custom_food.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/water_log.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';

class WaveContext {
  const WaveContext({
    required this.snapshot,
    required this.goal,
    required this.waterMl,
    required this.recentLogs,
    required this.todayFoods,
    required this.todayWaters,
    required this.customFoods,
    required this.plan,
    required this.hasActiveWorkout,
    required this.isReady,
  });

  static const empty = WaveContext(
    snapshot: HomeSnapshot.empty,
    goal: NutritionGoal.defaults,
    waterMl: 0,
    recentLogs: [],
    todayFoods: [],
    todayWaters: [],
    customFoods: [],
    plan: null,
    hasActiveWorkout: false,
    isReady: false,
  );

  final HomeSnapshot snapshot;
  final NutritionGoal goal;
  final double waterMl;
  final List<FoodLog> recentLogs;
  final List<FoodLog> todayFoods;
  final List<WaterLog> todayWaters;
  final List<CustomFood> customFoods;
  final WorkoutPlanEntity? plan;
  final bool hasActiveWorkout;
  final bool isReady;

  String get userName => snapshot.userName;

  bool get hasName => userName.isNotEmpty;

  int get flowScore => snapshot.flowScorePercent;

  WorkoutRecommendation? get workout => snapshot.workout;

  NutritionSummary get nutrition => snapshot.nutrition;

  double get waterRemainingMl =>
      (goal.waterMl - waterMl).clamp(0, goal.waterMl.toDouble());

  int get caloriesRemaining =>
      (goal.calories - nutrition.totalCalories).clamp(0, goal.calories);

  int get proteinRemainingG =>
      (goal.proteinG - nutrition.proteinG).clamp(0, goal.proteinG);
}
