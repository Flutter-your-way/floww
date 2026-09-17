import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/services/nutrition_goal_service.dart';

class FakeNutritionGoalService implements NutritionGoalService {
  FakeNutritionGoalService([this.goal = NutritionGoal.defaults]);

  final NutritionGoal goal;

  @override
  NutritionGoal goalOf(Object? account) => goal;

  @override
  Stream<NutritionGoal> watch() => Stream.value(goal);

  @override
  Future<NutritionGoal> load() async => goal;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
