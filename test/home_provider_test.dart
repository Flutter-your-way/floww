import 'package:flutter_test/flutter_test.dart';

import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/theme_controller.dart';
import 'package:floww/core/flow_mode/providers/flow_mode_controller.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/achievements/services/achievements_service.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_definition.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/home/providers/home_provider.dart';
import 'package:floww/core/home/services/home_service.dart';
import 'package:floww/core/home/services/home_snapshot_builder.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/water_log.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/profile/models/profile_account.dart';

import 'fakes/fake_home_service.dart';
import 'fakes/fake_nutrition_log_service.dart';

void main() {
  final today = AppDateUtils.dateOnly(DateTime.now());

  DateTime todayAt(int hour) =>
      DateTime(today.year, today.month, today.day, hour);

  HabitDefinition habitDefinition({
    required String id,
    required String title,
    required double target,
    HabitMetric metric = HabitMetric.liters,
  }) => HabitDefinition(
    id: id,
    title: title,
    target: target,
    metric: metric,
    icon: HabitIconKind.water,
    createdAt: AppDateUtils.addDays(today, -7),
    sortOrder: 0,
  );

  HomeRecords recordsOf({
    ProfileAccount account = ProfileAccount.empty,
    HabitRecords habits = HabitRecords.empty,
    NutritionLogs nutrition = NutritionLogs.empty,
    List<DailyFlowEntry> flowHistory = const [],
  }) => HomeRecords(
    account: account,
    habits: habits,
    nutrition: nutrition,
    plan: null,
    sessions: const [],
    healthDays: const [],
    flowHistory: flowHistory,
  );

  HomeProvider providerOf(FakeHomeService service) => HomeProvider(
    service,
    HomeSnapshotBuilder(),
    AchievementsService(),
    FlowModeController(ThemeModeController(AppThemeMode.flow)),
  );

  test('an empty account renders the home empty states', () async {
    final service = FakeHomeService();
    final provider = providerOf(service);
    await pumpEventQueue();

    expect(provider.isReady, isTrue);
    expect(provider.userName, '');
    expect(provider.habits, isEmpty);
    expect(provider.workout, isNull);
    expect(provider.flowScorePercent, 0);
    expect(provider.recoveryLevel, isNull);
    expect(provider.todayMode, isNull);
    expect(provider.nutrition.totalCalories, 0);
    expect(service.savedFlow, isEmpty);

    provider.dispose();
    service.dispose();
  });

  test('the header name comes from the stored profile', () async {
    final service = FakeHomeService(
      recordsOf(account: const ProfileAccount(name: 'Sarah Mitchell')),
    );
    final provider = providerOf(service);
    await pumpEventQueue();

    expect(provider.userName, 'Sarah Mitchell');

    provider.dispose();
    service.dispose();
  });

  test('the nutrition summary counts only today\'s logs', () async {
    final service = FakeHomeService(
      recordsOf(
        nutrition: NutritionLogs(
          foods: [
            testFoodLog(
              id: 'today',
              meal: MealType.lunch,
              at: todayAt(12),
              calories: 480,
              proteinG: 28,
              carbsG: 52,
              fatG: 15,
            ),
            testFoodLog(
              id: 'yesterday',
              meal: MealType.dinner,
              at: todayAt(19).subtract(const Duration(days: 1)),
              calories: 900,
              proteinG: 60,
            ),
          ],
          waters: const [],
        ),
      ),
    );
    final provider = providerOf(service);
    await pumpEventQueue();

    expect(provider.nutrition.totalCalories, 480);
    expect(provider.nutrition.proteinG, 28);
    expect(provider.nutrition.carbsG, 52);
    expect(provider.nutrition.fatsG, 15);
    expect(provider.nutrition.calorieGoal, 2450);

    provider.dispose();
    service.dispose();
  });

  test('the water goal follows the profile daily target', () async {
    final service = FakeHomeService(
      recordsOf(account: const ProfileAccount(waterTargetLiters: 3)),
    );
    final provider = providerOf(service);
    await pumpEventQueue();

    final nutritionComponent = provider.flowScoreBreakdown.components
        .firstWhere((component) => component.title == 'Nutrition');
    expect(nutritionComponent.points, 0);

    provider.dispose();
    service.dispose();
  });

  test('habits come from the stored habit definitions and logs', () async {
    final service = FakeHomeService(
      recordsOf(
        habits: HabitRecords(
          habits: [
            habitDefinition(id: 'water', title: 'Water Intake', target: 2.5),
          ],
          days: [
            HabitDayLog(
              date: today,
              entries: const [
                HabitLogEntry(
                  id: 'water',
                  title: 'Water Intake',
                  value: 2.5,
                  target: 2.5,
                  metric: 'liters',
                ),
              ],
            ),
          ],
        ),
      ),
    );
    final provider = providerOf(service);
    await pumpEventQueue();

    expect(provider.habits, hasLength(1));
    expect(provider.habits.first.title, 'Water Intake');
    expect(provider.habits.first.valueLabel, '2.5L / 2.5L Target');
    expect(provider.habits.first.completed, isTrue);

    final habitComponent = provider.flowScoreBreakdown.components.firstWhere(
      (component) => component.title == 'Habit Completion',
    );
    expect(habitComponent.points, habitComponent.maxPoints);

    provider.dispose();
    service.dispose();
  });

  test(
    'logging food raises the flow score and writes it to firestore',
    () async {
      final service = FakeHomeService();
      final provider = providerOf(service);
      await pumpEventQueue();
      expect(provider.flowScorePercent, 0);

      service.emit(
        recordsOf(
          nutrition: NutritionLogs(
            foods: [
              testFoodLog(
                id: 'lunch',
                meal: MealType.lunch,
                at: todayAt(13),
                calories: 800,
              ),
            ],
            waters: [
              WaterLog(id: 'glass', amountMl: 2500, loggedAt: todayAt(10)),
            ],
          ),
        ),
      );
      await pumpEventQueue();

      expect(provider.flowScorePercent, greaterThan(0));
      expect(service.savedFlow, hasLength(1));
      expect(service.savedFlow.single.score, provider.flowScorePercent);
      expect(provider.streakCount, 1);

      provider.dispose();
      service.dispose();
    },
  );

  test('an unchanged score is not written to firestore twice', () async {
    final service = FakeHomeService(
      recordsOf(
        flowHistory: [
          DailyFlowEntry(
            date: today,
            score: 25,
            workoutScore: 0,
            habitScore: 0,
            nutritionScore: 100,
          ),
        ],
        nutrition: NutritionLogs(
          foods: [
            testFoodLog(
              id: 'a',
              meal: MealType.breakfast,
              at: todayAt(8),
              calories: 400,
            ),
            testFoodLog(
              id: 'b',
              meal: MealType.lunch,
              at: todayAt(12),
              calories: 400,
            ),
            testFoodLog(
              id: 'c',
              meal: MealType.dinner,
              at: todayAt(19),
              calories: 400,
            ),
          ],
          waters: [
            WaterLog(id: 'water', amountMl: 2500, loggedAt: todayAt(10)),
          ],
        ),
      ),
    );
    final provider = providerOf(service);
    await pumpEventQueue();

    expect(provider.flowScorePercent, 25);
    expect(service.savedFlow, isEmpty);

    provider.dispose();
    service.dispose();
  });

  test('flow mode stays unset until health data exists', () async {
    final service = FakeHomeService();
    final provider = providerOf(service);
    await pumpEventQueue();

    expect(provider.flowModeDetail, isNull);
    expect(provider.recoveryDetail.hasData, isFalse);
    expect(AppThemeMode.values, contains(AppThemeMode.flow));

    provider.dispose();
    service.dispose();
  });
}
