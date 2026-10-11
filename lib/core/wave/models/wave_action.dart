import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/nutrition/models/custom_food.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';

enum WaveActionKind {
  none,
  completeAllHabits,
  completeHabit,
  uncompleteHabit,
  addHabit,
  editHabit,
  deleteHabit,
  logWater,
  unlogWater,
  logFood,
  unlogFood,
  createFood,
  startWorkout,
  completeWorkout,
  cancelWorkout,
  logSet,
  swapExercise,
  rescheduleWorkout,
  skipToday,
  shiftPlan,
  adjustIntensity,
  regeneratePlan,
  logWeight,
  logSleep,
  setFlowMode,
  setReminder,
  updateTargets,
  navigate;

  static const Set<WaveActionKind> confirmed = {
    deleteHabit,
    cancelWorkout,
    shiftPlan,
    regeneratePlan,
  };

  bool get needsConfirmation => confirmed.contains(this);

  bool get logsFood => this == logFood || this == createFood;
}

enum WaveIntensity { none, lighter, harder }

enum WaveFlowModeChoice { none, flow, steady, restore, auto }

enum WaveDestination {
  none,
  home,
  nutrition,
  workout,
  habits,
  progress,
  todaysWorkout,
  activeWorkout,
  dietPlan,
  weeklyNutritionReport,
  habitCalendar,
  foodScan,
  muscleRecovery,
  achievements,
  profile,
  editPersonalInfo,
  editDailyTargets,
  connectedApps,
  notificationSettings,
  units,
  privacyData,
  waveMemory,
  premium,
}

class WaveTargetsDraft {
  const WaveTargetsDraft({
    this.waterLiters = 0,
    this.steps = 0,
    this.sleepHours = 0,
  });

  factory WaveTargetsDraft.fromJson(Object? value) {
    if (value is! Map) return const WaveTargetsDraft();
    return WaveTargetsDraft(
      waterLiters: (value['waterLiters'] as num? ?? 0).toDouble(),
      steps: (value['steps'] as num? ?? 0).toDouble(),
      sleepHours: (value['sleepHours'] as num? ?? 0).toDouble(),
    );
  }

  final double waterLiters;
  final double steps;
  final double sleepHours;

  Map<String, dynamic> toJson() => {
    'waterLiters': waterLiters,
    'steps': steps,
    'sleepHours': sleepHours,
  };
}

class WaveAction {
  const WaveAction({
    required this.kind,
    this.target = '',
    this.replacement = '',
    this.value = 0,
    this.weightKg = 0,
    this.servings = 0,
    this.meal,
    this.date,
    this.intensity = WaveIntensity.none,
    this.mode = WaveFlowModeChoice.none,
    this.reminder = '',
    this.enabled = false,
    this.destination = WaveDestination.none,
    this.targets = const WaveTargetsDraft(),
    this.foodDraft,
    this.habitDraft,
  });

  factory WaveAction.fromJson(Map<String, dynamic> json) => WaveAction(
    kind:
        WaveActionKind.values.asNameMap()[json['action']] ??
        WaveActionKind.none,
    target: (json['target'] as String? ?? '').trim(),
    replacement: (json['replacement'] as String? ?? '').trim(),
    value: (json['value'] as num? ?? 0).toDouble(),
    weightKg: (json['weightKg'] as num? ?? 0).toDouble(),
    servings: (json['servings'] as num? ?? 0).toInt(),
    meal: MealType.values.asNameMap()[json['meal']],
    date: _dateOf(json['date']),
    intensity:
        WaveIntensity.values.asNameMap()[json['intensity']] ??
        WaveIntensity.none,
    mode:
        WaveFlowModeChoice.values.asNameMap()[json['mode']] ??
        WaveFlowModeChoice.none,
    reminder: _reminderOf(json['reminder']),
    enabled: json['enabled'] as bool? ?? false,
    destination:
        WaveDestination.values.asNameMap()[json['screen']] ??
        WaveDestination.none,
    targets: WaveTargetsDraft.fromJson(json['targets']),
    foodDraft: _foodDraftOf(json['foodDraft']),
    habitDraft: _habitDraftOf(json['habitDraft']),
  );

  static const String _noReminder = 'none';

  final WaveActionKind kind;
  final String target;
  final String replacement;
  final double value;
  final double weightKg;
  final int servings;
  final MealType? meal;
  final DateTime? date;
  final WaveIntensity intensity;
  final WaveFlowModeChoice mode;
  final String reminder;
  final bool enabled;
  final WaveDestination destination;
  final WaveTargetsDraft targets;
  final CustomFoodDraft? foodDraft;
  final HabitDraft? habitDraft;

  bool get needsConfirmation => kind.needsConfirmation;

  Map<String, dynamic> toJson() => {
    'action': kind.name,
    'target': target,
    'replacement': replacement,
    'value': value,
    'weightKg': weightKg,
    'servings': servings,
    if (meal != null) 'meal': meal!.name,
    if (date != null) 'date': AppDateUtils.dateKey(date!),
    'intensity': intensity.name,
    'mode': mode.name,
    'reminder': reminder,
    'enabled': enabled,
    'screen': destination.name,
    'targets': targets.toJson(),
    if (foodDraft != null) 'foodDraft': _foodDraftJson(foodDraft!),
    if (habitDraft != null) 'habitDraft': _habitDraftJson(habitDraft!),
  };

  static List<WaveAction> listOf(Object? value) => value is List
      ? [
          for (final item in value)
            if (item is Map)
              if (WaveAction.fromJson(Map<String, dynamic>.from(item))
                  case final action when action.kind != WaveActionKind.none)
                action,
        ]
      : const [];

  static DateTime? _dateOf(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(value.trim());
    return parsed == null ? null : AppDateUtils.dateOnly(parsed);
  }

  static String _reminderOf(Object? value) {
    final reminder = (value as String? ?? '').trim();
    return reminder == _noReminder ? '' : reminder;
  }

  static CustomFoodDraft? _foodDraftOf(Object? value) {
    if (value is! Map) return null;
    final data = Map<String, dynamic>.from(value);
    final name = (data['name'] as String? ?? '').trim();
    if (name.isEmpty) return null;
    return CustomFoodDraft(
      name: name,
      serving: (data['serving'] as String? ?? '').trim(),
      weightG: (data['weightG'] as num? ?? 0).toDouble(),
      calories: (data['calories'] as num? ?? 0).toDouble(),
      proteinG: (data['proteinG'] as num? ?? 0).toDouble(),
      carbsG: (data['carbsG'] as num? ?? 0).toDouble(),
      fatG: (data['fatG'] as num? ?? 0).toDouble(),
      fiberG: (data['fiberG'] as num? ?? 0).toDouble(),
      sugarG: (data['sugarG'] as num? ?? 0).toDouble(),
      sodiumMg: (data['sodiumMg'] as num? ?? 0).toDouble(),
      waterMl: (data['waterMl'] as num? ?? 0).toDouble(),
    );
  }

  static Map<String, dynamic> _foodDraftJson(CustomFoodDraft draft) => {
    'name': draft.name,
    'serving': draft.serving,
    'weightG': draft.weightG,
    'calories': draft.calories,
    'proteinG': draft.proteinG,
    'carbsG': draft.carbsG,
    'fatG': draft.fatG,
    'fiberG': draft.fiberG,
    'sugarG': draft.sugarG,
    'sodiumMg': draft.sodiumMg,
    'waterMl': draft.waterMl,
  };

  static HabitDraft? _habitDraftOf(Object? value) {
    if (value is! Map) return null;
    final data = Map<String, dynamic>.from(value);
    final title = (data['title'] as String? ?? '').trim();
    if (title.isEmpty) return null;
    return HabitDraft(
      title: title,
      target: (data['target'] as num? ?? 0).toDouble(),
      metric:
          HabitMetric.values.asNameMap()[data['metric']] ?? HabitMetric.minutes,
    );
  }

  static Map<String, dynamic> _habitDraftJson(HabitDraft draft) => {
    'title': draft.title,
    'target': draft.target,
    'metric': draft.metric.name,
  };
}
