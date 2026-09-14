import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:floww/core/nutrition/models/food_model.dart';

void main() {
  late Map<String, dynamic> fixture;

  setUpAll(() {
    fixture =
        jsonDecode(File('test/fixtures/food_model.json').readAsStringSync())
            as Map<String, dynamic>;
  });

  test('parses the backend food model', () {
    final food = FoodModel.fromJson(fixture);

    expect(food.name, 'Grilled chicken rice bowl');
    expect(food.source, FoodSource.scan);
    expect(food.healthScore, 8);
    expect(food.ingredients, hasLength(4));
    expect(food.nutrition.macros.calories, 567);
    expect(food.nutrition.minerals.sodiumMg, 0);
    expect(food.createdAt, DateTime.utc(2026, 9, 10, 13, 5));
  });

  test('toJson round-trips to the exact backend shape', () {
    expect(FoodModel.fromJson(fixture).toJson(), fixture);
  });

  test('reads water and treats logs without it as 0 ml', () {
    expect(FoodModel.fromJson(fixture).nutrition.macros.waterMl, 271.4);

    final legacy = jsonDecode(jsonEncode(fixture)) as Map<String, dynamic>;
    ((legacy['nutrition'] as Map<String, dynamic>)['macros']
            as Map<String, dynamic>)
        .remove('waterMl');

    expect(FoodModel.fromJson(legacy).nutrition.macros.waterMl, 0);
  });

  test('copyWith replaces only the edited fields', () {
    final food = FoodModel.fromJson(fixture);
    final edited = food.copyWith(
      name: 'Rice bowl',
      nutrition: food.nutrition.copyWith(
        macros: food.nutrition.macros.copyWith(calories: 480, waterMl: 300),
        minerals: food.nutrition.minerals.copyWith(sodiumMg: 320),
      ),
    );

    expect(edited.name, 'Rice bowl');
    expect(edited.nutrition.macros.calories, 480);
    expect(edited.nutrition.macros.waterMl, 300);
    expect(edited.nutrition.macros.proteinG, food.nutrition.macros.proteinG);
    expect(edited.nutrition.minerals.sodiumMg, 320);
    expect(edited.nutrition.minerals.ironMg, food.nutrition.minerals.ironMg);
    expect(edited.id, food.id);
    expect(edited.createdAt, food.createdAt);
  });
}
