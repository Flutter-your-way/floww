import 'dart:async';

import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/water_log.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';

class FakeNutritionLogService implements NutritionLogService {
  FakeNutritionLogService({this.userId = 'user-1', this.addError});

  @override
  final String? userId;

  final NutritionLogException? addError;

  final List<FoodLog> foodLogs = [];
  final List<WaterLog> waterLogs = [];
  final StreamController<void> _changes = StreamController.broadcast();
  int _nextId = 0;

  NutritionLogs _between(DateTime from, DateTime to) => NutritionLogs(
    foods: foodLogs
        .where((log) => !log.loggedAt.isBefore(from) && log.loggedAt.isBefore(to))
        .toList(),
    waters: waterLogs
        .where((log) => !log.loggedAt.isBefore(from) && log.loggedAt.isBefore(to))
        .toList(),
  );

  @override
  String newFoodLogId() => 'log-${++_nextId}';

  @override
  Stream<NutritionLogs> watchLogs(DateTime from, DateTime to) async* {
    yield _between(from, to);
    await for (final _ in _changes.stream) {
      yield _between(from, to);
    }
  }

  @override
  Stream<List<FoodLog>> watchRecentFoodLogs() async* {
    yield foodLogs.reversed.toList();
    await for (final _ in _changes.stream) {
      yield foodLogs.reversed.toList();
    }
  }

  @override
  Future<List<FoodLog>> fetchFoodLogs(DateTime from, DateTime to) async =>
      _between(from, to).foods;

  @override
  Future<void> addFoodLog(FoodLog log) async {
    final error = addError;
    if (error != null) throw error;
    foodLogs.add(log);
    _changes.add(null);
  }

  @override
  Future<void> deleteFoodLog(String id) async {
    foodLogs.removeWhere((log) => log.id == id);
    _changes.add(null);
  }

  @override
  Future<void> addWaterLog(double amountMl, DateTime loggedAt) async {
    waterLogs.add(
      WaterLog(id: 'water-${++_nextId}', amountMl: amountMl, loggedAt: loggedAt),
    );
    _changes.add(null);
  }

  @override
  Future<void> deleteWaterLog(String id) async {
    waterLogs.removeWhere((log) => log.id == id);
    _changes.add(null);
  }
}

FoodLog testFoodLog({
  required String id,
  required MealType meal,
  required DateTime at,
  double calories = 0,
  double proteinG = 0,
  double carbsG = 0,
  double fatG = 0,
  double fiberG = 0,
  double sugarG = 0,
  double sodiumMg = 0,
  double waterMl = 0,
  String name = 'Test food',
}) {
  final food = CatalogFood(
    name: name,
    serving: '1 serving',
    weightG: 100,
    calories: calories,
    proteinG: proteinG,
    carbsG: carbsG,
    fatG: fatG,
    fiberG: fiberG,
    sugarG: sugarG,
    sodiumMg: sodiumMg,
    waterMl: waterMl,
  );
  return FoodLog(
    food: food.toFoodModel(id: id, userId: 'user-1', createdAt: at),
    mealType: meal,
    loggedAt: at,
  );
}
