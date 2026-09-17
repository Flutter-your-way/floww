import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';

class WaveContext {
  const WaveContext({
    required this.snapshot,
    required this.goal,
    required this.waterMl,
    required this.recentLogs,
    required this.plan,
    required this.isReady,
  });

  static const empty = WaveContext(
    snapshot: HomeSnapshot.empty,
    goal: NutritionGoal.defaults,
    waterMl: 0,
    recentLogs: [],
    plan: null,
    isReady: false,
  );

  final HomeSnapshot snapshot;
  final NutritionGoal goal;
  final double waterMl;
  final List<FoodLog> recentLogs;
  final WorkoutPlanEntity? plan;
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
