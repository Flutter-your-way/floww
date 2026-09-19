import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/core/nutrition/models/diet_plan.dart';
import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/services/diet_plan_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/workout/models/exercise.dart' as catalog;
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/models/wave_context.dart';
import 'package:floww/core/wave/models/wave_quick_action.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';

class WaveChatService {
  WaveChatService({
    NutritionLogService? logService,
    DietPlanService? dietPlanService,
    WorkoutCatalogService? catalogService,
    WorkoutPlanService? planService,
  }) : _logService = logService ?? NutritionLogService(),
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
        actionLabel: workout == null ? 'Browse Workouts' : 'Start Workout',
        action: WavePlanAction.startWorkout,
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

  WaveMealSlot currentMealSlot() => _slotOf(MealType.forTime(DateTime.now()));

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
    final alternative = exercises
        .where(
          (exercise) =>
              exercise.group == coarseGroup &&
              !planned.contains(exercise.id) &&
              _lowLoadEquipment.contains(exercise.equipment),
        )
        .firstOrNull;
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
            emoji: _slotOf(meal.mealType).emoji,
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

  static IconData _recoveryIcon(RecoveryMetricAccent accent) => switch (accent) {
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

  static WaveMealSlot _slotOf(MealType meal) => switch (meal) {
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

