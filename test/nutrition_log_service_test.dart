import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/water_log.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';

import 'fakes/fake_nutrition_log_service.dart';

void main() {
  final lunch = testFoodLog(
    id: 'lunch',
    meal: MealType.lunch,
    at: DateTime(2026, 9, 13, 13),
    calories: 480,
  );
  final glass = WaterLog(
    id: 'water',
    amountMl: 250,
    loggedAt: DateTime(2026, 9, 13, 9),
  );

  test('food shows up even when the water query is denied', () async {
    final foods = StreamController<List<FoodLog>>();
    final waters = StreamController<List<WaterLog>>();
    final emitted = <NutritionLogs>[];
    final errors = <Object>[];
    final subscription = NutritionLogService.combineLogs(
      foods.stream,
      waters.stream,
    ).listen(emitted.add, onError: errors.add);

    waters.addError(Exception('permission-denied'));
    foods.add([lunch]);
    await pumpEventQueue();

    expect(errors, isEmpty);
    expect(emitted.last.foods.single.id, 'lunch');
    expect(emitted.last.waters, isEmpty);
    await subscription.cancel();
  });

  test('food is emitted before water arrives and water updates later', () async {
    final foods = StreamController<List<FoodLog>>();
    final waters = StreamController<List<WaterLog>>();
    final emitted = <NutritionLogs>[];
    final subscription = NutritionLogService.combineLogs(
      foods.stream,
      waters.stream,
    ).listen(emitted.add);

    foods.add([lunch]);
    await pumpEventQueue();
    expect(emitted, hasLength(1));
    expect(emitted.single.waters, isEmpty);

    waters.add([glass]);
    await pumpEventQueue();
    expect(emitted.last.foods.single.id, 'lunch');
    expect(emitted.last.waters.single.amountMl, 250);
    await subscription.cancel();
  });

  test('food query errors are still reported', () async {
    final foods = StreamController<List<FoodLog>>();
    final errors = <Object>[];
    final subscription = NutritionLogService.combineLogs(
      foods.stream,
      const Stream.empty(),
    ).listen((_) {}, onError: errors.add);

    foods.addError(Exception('boom'));
    await pumpEventQueue();

    expect(errors, hasLength(1));
    await subscription.cancel();
  });

  test('an unreadable document is skipped instead of breaking the day', () {
    final logs = NutritionLogService.parseDocuments(
      [
        lunch.toJson(),
        {'id': 'broken', 'loggedAt': 'not a date'},
      ],
      FoodLog.fromJson,
    );

    expect(logs.map((log) => log.id), ['lunch']);
  });

  test('logged times are stored with a fixed millisecond precision', () {
    final withMicros = DateTime.utc(2026, 9, 13, 10, 5, 0, 123, 456);

    expect(AppDateUtils.isoKey(withMicros), '2026-09-13T10:05:00.123Z');
    expect(
      AppDateUtils.isoKey(DateTime.utc(2026, 9, 13)),
      '2026-09-13T00:00:00.000Z',
    );
    expect(
      FoodLog.fromJson(lunch.toJson()).loggedAt,
      DateTime(2026, 9, 13, 13),
    );
  });

  test('the rollover delay always lands on the next midnight', () {
    final evening = DateTime(2026, 9, 13, 23, 59, 30);

    expect(
      AppDateUtils.untilNextDay(evening),
      const Duration(seconds: 30),
    );
    expect(
      DateTime(2026, 9, 13, 10).add(
        AppDateUtils.untilNextDay(DateTime(2026, 9, 13, 10)),
      ),
      DateTime(2026, 9, 14),
    );
  });
}
