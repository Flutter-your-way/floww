import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_definition.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/habits/services/habit_snapshot_builder.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/core/nutrition/models/custom_food.dart';
import 'package:floww/core/nutrition/models/diet_plan.dart';
import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/services/custom_food_service.dart';
import 'package:floww/core/nutrition/services/diet_plan_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/workout/models/exercise.dart' as catalog;
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/models/wave_context.dart';
import 'package:floww/core/wave/models/wave_quick_action.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

class WaveChatService {
  WaveChatService({
    NutritionLogService? logService,
    DietPlanService? dietPlanService,
    WorkoutCatalogService? catalogService,
    WorkoutPlanService? planService,
    HabitService? habitService,
    CustomFoodService? customFoodService,
    WorkoutSessionService? sessionService,
  }) : _sessionService = sessionService ?? WorkoutSessionService(),
       _logService = logService ?? NutritionLogService(),
       _habitService = habitService ?? HabitService(),
       _customFoodService = customFoodService ?? CustomFoodService(),
       _catalogService = catalogService ?? WorkoutCatalogService() {
    _dietPlanService = dietPlanService ?? DietPlanService(_logService);
    _planService = planService ?? WorkoutPlanService(_catalogService);
  }

  static const int quickFoodCount = 8;
  static const double waterQuickAmountMl = 250;

  static const List<catalog.Equipment> _lowLoadEquipment = [
    catalog.Equipment.machine,
    catalog.Equipment.cable,
    catalog.Equipment.band,
  ];

  static const Map<MuscleGroup, List<String>> _painKeywords = {
    MuscleGroup.shoulders: ['shoulder', 'delt', 'rotator'],
    MuscleGroup.back: ['back', 'lat', 'spine', 'lower back'],
    MuscleGroup.chest: ['chest', 'pec'],
    MuscleGroup.biceps: ['bicep', 'elbow'],
    MuscleGroup.triceps: ['tricep'],
    MuscleGroup.quadriceps: ['quad', 'knee'],
    MuscleGroup.hamstrings: ['hamstring'],
    MuscleGroup.glutes: ['glute', 'hip'],
    MuscleGroup.calves: ['calf', 'calves', 'ankle'],
  };

  static const List<String> _dietPlanKeywords = [
    'diet plan',
    'meal plan',
    'nutrition plan',
  ];

  final NutritionLogService _logService;
  final HabitService _habitService;
  final CustomFoodService _customFoodService;
  final WorkoutSessionService _sessionService;
  final WorkoutCatalogService _catalogService;
  late final DietPlanService _dietPlanService;
  late final WorkoutPlanService _planService;

  String greetingFor(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  WaveDailyBrief briefOf(WaveContext context) {
    final workout = context.workout;
    final nutrition = context.nutrition;

    return WaveDailyBrief(
      greeting: greetingFor(DateTime.now()),
      userName: context.hasName ? context.userName : 'there',
      flowScore: context.flowScore,
      modeLabel: context.snapshot.flowMode.mode.name.toUpperCase(),
      workoutTitle: workout?.title ?? 'Rest day',
      workoutDetail: workout == null
          ? 'No session scheduled'
          : '${workout.durationLabel} · ${workout.intensityLabel}',
      calories: nutrition.calorieGoal,
      proteinDetail: 'Protein ${nutrition.proteinG}/${context.goal.proteinG}g',
      focusItems: _focusItemsOf(context),
    );
  }

  List<WavePlanItem> planItemsOf(WaveContext context) {
    final workout = context.workout;
    final nutrition = context.nutrition;
    final waterLeft = context.waterRemainingMl;

    return [
      WavePlanItem(
        emoji: '💪',
        label: 'WORKOUT',
        title: workout?.title ?? 'Rest & recover',
        detail: workout == null
            ? 'No session scheduled for today'
            : '${workout.durationLabel} · ${workout.intensityLabel}',
        actionLabel: context.hasActiveWorkout
            ? 'Resume Workout'
            : workout == null
            ? 'Browse Workouts'
            : 'Start Workout',
        action: context.hasActiveWorkout
            ? WavePlanAction.resumeWorkout
            : WavePlanAction.startWorkout,
      ),
      WavePlanItem(
        emoji: '🍽️',
        label: 'MEAL',
        title: MealType.forTime(DateTime.now()).label,
        detail:
            '${nutrition.totalCalories} / ${nutrition.calorieGoal} kcal logged',
        actionLabel: 'Log Meal',
        action: WavePlanAction.logMeal,
      ),
      WavePlanItem(
        emoji: '💧',
        label: 'WATER',
        title: waterLeft <= 0
            ? 'Goal reached'
            : '${_liters(waterLeft)}L Remaining',
        detail:
            '${_liters(context.waterMl)}L / '
            '${_liters(context.goal.waterMl.toDouble())}L target',
        actionLabel: 'Log Water',
        action: WavePlanAction.logWater,
      ),
    ];
  }

  WaveScoreReport scoreReportOf(WaveContext context) {
    final breakdown = context.snapshot.flowScoreBreakdown;
    final factors = <WaveScoreFactor>[
      for (final component in breakdown.components)
        WaveScoreFactor(
          icon: _componentIcon(component.title),
          label: component.title,
          value: (component.fraction * 100).round(),
          isLow: component.fraction < _lowFactorThreshold,
        ),
      for (final metric in context.snapshot.recovery.metrics)
        WaveScoreFactor(
          icon: _recoveryIcon(metric.accent),
          label: metric.label,
          value: metric.percent,
          isLow: metric.percent < _lowFactorThreshold * 100,
        ),
    ];

    return WaveScoreReport(
      score: context.flowScore,
      potentialLabel: 'Could be ${_potentialOf(context)}+',
      factors: factors,
    );
  }

  List<WaveQuickFood> quickFoodsOf(WaveContext context) {
    final foods = <WaveQuickFood>[];
    final seen = <String>{};

    for (final log in context.recentLogs.reversed) {
      if (foods.length >= quickFoodCount) break;
      if (!seen.add(log.food.name.toLowerCase())) continue;
      foods.add(WaveQuickFood.fromLoggedFood(log.food));
    }

    for (final food in FoodCatalog.items) {
      if (foods.length >= quickFoodCount) break;
      if (!seen.add(food.name.toLowerCase())) continue;
      foods.add(WaveQuickFood.fromCatalog(food));
    }

    return foods;
  }

  WaveMealSlot currentMealSlot() => slotOf(MealType.forTime(DateTime.now()));

  MuscleGroup? painAreaOf(String text) {
    final normalized = text.toLowerCase();
    for (final entry in _painKeywords.entries) {
      if (entry.value.any(normalized.contains)) return entry.key;
    }
    return null;
  }

  bool asksForDietPlan(String text) {
    final normalized = text.toLowerCase();
    return _dietPlanKeywords.any(normalized.contains);
  }

  WaveQuickAction? actionOf(String text) {
    final normalized = text.toLowerCase();
    for (final action in WaveQuickAction.values) {
      if (action.keywords.any(normalized.contains)) return action;
    }
    return null;
  }

  Future<WaveInjurySwap?> swapFor(
    WaveContext context, {
    required MuscleGroup area,
  }) async {
    final plan = context.plan;
    if (plan == null || plan.exercises.isEmpty) return null;

    final target = _mostLoadedEntry(plan, area);
    if (target == null) return null;

    final exercises = await _catalogService.loadExercises();
    final planned = plan.exercises.map((entry) => entry.exerciseId).toSet();
    final coarseGroup = _coarseGroupOf(area);
    final candidates = exercises.where(
      (exercise) =>
          exercise.group == coarseGroup &&
          !planned.contains(exercise.id) &&
          _lowLoadEquipment.contains(exercise.equipment),
    );
    final alternative =
        candidates.where((exercise) => exercise.isAdded).firstOrNull ??
        candidates.firstOrNull;
    if (alternative == null) return null;

    return WaveInjurySwap(
      title: 'Detected: ${area.label} discomfort',
      removing: target.entry.name,
      adding: alternative.name,
      rationale:
          'Swapping to ${alternative.equipment.label.toLowerCase()} work keeps '
          'the same ${area.label.toLowerCase()} stimulus with less '
          'joint load while you recover.',
      removingEntryId: target.entry.id,
      addingExerciseId: alternative.id,
    );
  }

  Future<bool> applySwap(WaveContext context, WaveInjurySwap swap) async {
    final plan = context.plan;
    final entryId = swap.removingEntryId;
    final exerciseId = swap.addingExerciseId;
    if (plan == null || entryId == null || exerciseId == null) return false;

    final replacement = await _catalogService.exerciseById(exerciseId);
    if (replacement == null) return false;

    final index = plan.exercises.indexWhere((entry) => entry.id == entryId);
    if (index < 0) return false;

    final original = plan.exercises[index];
    final updated = [...plan.exercises];
    updated[index] = _planService.entryFrom(
      replacement,
      section: original.section,
      sets: original.targetSets,
      reps: original.targetReps,
      restSeconds: original.restSeconds,
    );

    await _planService.savePlan(plan.copyWithExercises(updated));
    return true;
  }

  Future<void> logWater(double amountMl) =>
      _logService.addWaterLog(amountMl, DateTime.now());

  Future<int> completeHabits({String? title}) async {
    final records = await _habitService.watchRecords().first;
    final today = AppDateUtils.dateOnly(DateTime.now());
    final habits = HabitSnapshot.of(records).habitsFor(today);
    if (habits.isEmpty) return 0;

    final wanted = title?.trim().toLowerCase();
    final changedIds = <String>{};

    final updated = [
      for (final habit in habits)
        if (_matchesHabit(habit, wanted) && !habit.isCompleted)
          () {
            changedIds.add(habit.id);
            return habit.completed();
          }()
        else
          habit,
    ];

    if (changedIds.isEmpty) return 0;
    await _habitService.saveDay(today, updated, changedIds: changedIds);
    return changedIds.length;
  }

  Future<int> uncompleteHabits({required String title}) async {
    final records = await _habitService.watchRecords().first;
    final today = AppDateUtils.dateOnly(DateTime.now());
    final habits = HabitSnapshot.of(records).habitsFor(today);
    final wanted = title.trim().toLowerCase();
    final changedIds = <String>{};

    final updated = [
      for (final habit in habits)
        if (_matchesHabit(habit, wanted) && habit.isCompleted)
          () {
            changedIds.add(habit.id);
            return habit.reopened();
          }()
        else
          habit,
    ];

    if (changedIds.isEmpty) return 0;
    await _habitService.saveDay(today, updated, changedIds: changedIds);
    return changedIds.length;
  }

  Future<void> addHabit(HabitDraft draft) => _habitService.createHabit(draft);

  Future<bool> editHabit(String title, HabitDraft draft) async {
    final definition = await _habitDefinition(title);
    if (definition == null) return false;
    await _habitService.updateHabit(
      definition.id,
      HabitDraft(
        title: draft.title,
        target: draft.target,
        metric: draft.metric,
        schedule: definition.schedule,
        goalType: definition.goalType,
        source: definition.source.supports(draft.metric)
            ? definition.source
            : HabitSource.manual,
        description: draft.description,
      ),
    );
    return true;
  }

  Future<bool> deleteHabit(String title) async {
    final definition = await _habitDefinition(title);
    if (definition == null) return false;
    await _habitService.deleteHabit(definition.id);
    return true;
  }

  Future<HabitDefinition?> _habitDefinition(String title) async {
    final records = await _habitService.watchRecords().first;
    final wanted = title.trim().toLowerCase();
    return records.habits
        .where(
          (definition) =>
              definition.title.toLowerCase().contains(wanted) ||
              wanted.contains(definition.title.toLowerCase()),
        )
        .firstOrNull;
  }

  Future<double> unlogWater(WaveContext context, double amountMl) async {
    final logs = [...context.todayWaters]
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    if (logs.isEmpty) return 0;

    if (amountMl <= 0) {
      await _logService.deleteWaterLog(logs.first.id);
      return logs.first.amountMl;
    }

    var removed = 0.0;
    for (final log in logs) {
      if (removed >= amountMl) break;
      await _logService.deleteWaterLog(log.id);
      removed += log.amountMl;
    }
    return removed;
  }

  Future<CustomFood> createFood(CustomFoodDraft draft) =>
      _customFoodService.create(draft);

  Future<WaveQuickFood?> findFood(WaveContext context, String name) async {
    final wanted = name.trim().toLowerCase();
    if (wanted.isEmpty) return null;

    for (final food in context.customFoods) {
      if (_matchesName(food.name, wanted)) {
        return WaveQuickFood.fromCatalog(food.catalog);
      }
    }
    for (final food in FoodCatalog.items) {
      if (_matchesName(food.name, wanted)) {
        return WaveQuickFood.fromCatalog(food);
      }
    }
    for (final log in context.recentLogs.reversed) {
      if (_matchesName(log.food.name, wanted)) {
        return WaveQuickFood.fromLoggedFood(log.food);
      }
    }
    return null;
  }

  Future<int> logFood(
    WaveQuickFood food,
    WaveMealSlot slot, {
    int servings = 1,
  }) async {
    var logged = 0;
    for (var index = 0; index < servings; index++) {
      logged += await logFoods([food], slot);
    }
    return logged;
  }

  Future<String?> unlogFood(WaveContext context, String name) async {
    final wanted = name.trim().toLowerCase();
    final logs = [...context.todayFoods]
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

    for (final log in logs) {
      if (_matchesName(log.food.name, wanted)) {
        await _logService.deleteFoodLog(log.id);
        return log.food.name;
      }
    }
    return null;
  }

  Future<String?> startWorkout(WaveContext context) async {
    final plan = context.plan;
    if (plan == null) return null;

    final today = AppDateUtils.dateOnly(DateTime.now());
    final existing = await _sessionService.loadInProgressSession(today);
    if (existing != null) return existing.name;

    final session = await _sessionService.startSession(plan);
    await _planService.linkSession(today, session.id);
    return session.name;
  }

  Future<String?> completeWorkout() async {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final session = await _sessionService.loadInProgressSession(today);
    if (session == null) return null;

    final logged = session.withPlannedSetsLogged(DateTime.now());
    await _sessionService.completeSession(
      logged.copyWith(durationSeconds: logged.activeSeconds),
    );
    return session.name;
  }

  Future<String?> cancelWorkout() async {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final session = await _sessionService.loadInProgressSession(today);
    if (session == null) return null;

    await _sessionService.cancelSession(session.id);
    await _planService.unlinkSession(session.scheduledDate);
    return session.name;
  }

  static bool _matchesName(String value, String wanted) {
    final name = value.toLowerCase();
    return name.contains(wanted) || wanted.contains(name);
  }

  static bool _matchesHabit(Habit habit, String? wanted) {
    if (wanted == null || wanted.isEmpty) return true;
    return habit.title.toLowerCase().contains(wanted) ||
        wanted.contains(habit.title.toLowerCase());
  }

  Future<int> logFoods(List<WaveQuickFood> foods, WaveMealSlot slot) async {
    final userId = _logService.userId;
    if (userId == null || foods.isEmpty) return 0;

    final now = DateTime.now();
    final meal = _mealTypeOf(slot);
    var logged = 0;

    for (final food in foods) {
      final id = _logService.newFoodLogId();
      final catalog = food.catalog;
      final template = food.template;
      final model = catalog != null
          ? catalog.toFoodModel(id: id, userId: userId, createdAt: now)
          : template?.copyWith(id: id, createdAt: now);
      if (model == null) continue;

      await _logService.addFoodLog(
        FoodLog(food: model, mealType: meal, loggedAt: now),
      );
      logged += 1;
    }

    return logged;
  }

  Future<WaveDietPlan?> ensureDietPlan(WaveContext context) async {
    final progress = await _dietPlanService.loadProgress(
      targetCalories: context.goal.calories,
      startIfMissing: true,
    );
    if (progress == null) return null;

    final day = progress.plan.days.firstWhere(
      (day) => day.dayNumber == progress.currentDayNumber,
      orElse: () => progress.plan.days.first,
    );

    return WaveDietPlan(
      title: '${DietPlan.lengthDays}-Day Diet Plan Ready',
      description:
          'Your plan targets '
          '${progress.plan.targetCalories} kcal a day and is on your Nutrition '
          'screen. Here is day ${day.dayNumber}.',
      meals: [
        for (final meal in day.meals)
          WaveDietMeal(
            emoji: slotOf(meal.mealType).emoji,
            name: meal.name,
            calories: meal.calories,
          ),
      ],
    );
  }

  static const double _lowFactorThreshold = 0.6;

  static String _liters(double ml) => (ml / 1000).toStringAsFixed(1);

  static int _potentialOf(WaveContext context) {
    final breakdown = context.snapshot.flowScoreBreakdown;
    final reachable = context.flowScore + breakdown.pointsLeftPercent;
    return reachable.clamp(context.flowScore, 100);
  }

  static List<String> _focusItemsOf(WaveContext context) {
    final items = <String>[];
    final workout = context.workout;
    if (workout != null) items.add('Complete ${workout.title}');

    final proteinLeft = context.proteinRemainingG;
    if (proteinLeft > 0) items.add('Hit ${proteinLeft}g more protein');

    final waterLeft = context.waterRemainingMl;
    if (waterLeft > 0) items.add('Drink ${_liters(waterLeft)}L more water');

    final habitsLeft = context.snapshot.habits
        .where((habit) => !habit.completed)
        .length;
    if (habitsLeft > 0) items.add('Finish $habitsLeft habits');

    if (items.isEmpty) items.add('Everything is done — enjoy the recovery');
    return items;
  }

  static IconData _componentIcon(String title) => switch (title) {
    'Workout' => Icons.fitness_center_rounded,
    'Habit Completion' => Icons.check_circle_outline_rounded,
    'Nutrition' => Icons.restaurant_outlined,
    _ => Icons.insights_rounded,
  };

  static IconData _recoveryIcon(RecoveryMetricAccent accent) =>
      switch (accent) {
        RecoveryMetricAccent.sleep => Icons.bed_outlined,
        RecoveryMetricAccent.hrv => Icons.monitor_heart_outlined,
        RecoveryMetricAccent.energy => Icons.local_fire_department_outlined,
      };

  static catalog.MuscleGroup _coarseGroupOf(MuscleGroup area) => switch (area) {
    MuscleGroup.chest => catalog.MuscleGroup.chest,
    MuscleGroup.back || MuscleGroup.traps => catalog.MuscleGroup.back,
    MuscleGroup.shoulders => catalog.MuscleGroup.shoulders,
    MuscleGroup.biceps || MuscleGroup.triceps => catalog.MuscleGroup.arms,
    MuscleGroup.abdominals => catalog.MuscleGroup.core,
    MuscleGroup.quadriceps ||
    MuscleGroup.hamstrings ||
    MuscleGroup.glutes ||
    MuscleGroup.calves ||
    MuscleGroup.adductors => catalog.MuscleGroup.legs,
  };

  static WaveMealSlot slotOf(MealType meal) => switch (meal) {
    MealType.breakfast => WaveMealSlot.breakfast,
    MealType.lunch => WaveMealSlot.lunch,
    MealType.dinner => WaveMealSlot.dinner,
    MealType.snacks => WaveMealSlot.snack,
  };

  static MealType _mealTypeOf(WaveMealSlot slot) => switch (slot) {
    WaveMealSlot.breakfast => MealType.breakfast,
    WaveMealSlot.lunch => MealType.lunch,
    WaveMealSlot.dinner => MealType.dinner,
    WaveMealSlot.snack => MealType.snacks,
  };

  static _PlanTarget? _mostLoadedEntry(
    WorkoutPlanEntity plan,
    MuscleGroup area,
  ) {
    _PlanTarget? best;
    for (final entry in plan.exercises) {
      final share = entry.muscleShares[area.name] ?? 0;
      if (share <= 0) continue;
      if (best == null || share > best.share) {
        best = _PlanTarget(entry: entry, group: area, share: share);
      }
    }
    return best;
  }
}

class _PlanTarget {
  const _PlanTarget({
    required this.entry,
    required this.group,
    required this.share,
  });

  final WorkoutEntryEntity entry;
  final MuscleGroup group;
  final double share;
}
