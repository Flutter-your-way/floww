import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/nutrition/models/custom_food.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';

enum WaveCardKind {
  none,
  plan,
  mealLog,
  dietPlan,
  scoreReport,
  checkIn,
  injurySwap,
}

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
}

class WaveReply {
  const WaveReply({
    required this.text,
    required this.card,
    required this.injuryArea,
    required this.action,
    required this.actionTarget,
    required this.actionAmountMl,
    required this.servings,
    required this.meal,
    required this.foodDraft,
    required this.habitDraft,
  });

  factory WaveReply.fromJson(Map<String, dynamic> json) {
    final card =
        WaveCardKind.values.asNameMap()[json['card']] ?? WaveCardKind.none;
    return WaveReply(
      text: (json['reply'] as String? ?? '').trim(),
      card: card,
      injuryArea: card == WaveCardKind.injurySwap
          ? MuscleGroup.values.asNameMap()[json['injuryArea']]
          : null,
      action:
          WaveActionKind.values.asNameMap()[json['action']] ??
          WaveActionKind.none,
      actionTarget: (json['actionTarget'] as String? ?? '').trim(),
      actionAmountMl: (json['actionAmountMl'] as num? ?? 0).toDouble(),
      servings: (json['servings'] as num? ?? 0).toInt(),
      meal: MealType.values.asNameMap()[json['meal']],
      foodDraft: _foodDraftOf(json['foodDraft']),
      habitDraft: _habitDraftOf(json['habitDraft']),
    );
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

  final String text;
  final WaveCardKind card;
  final MuscleGroup? injuryArea;
  final WaveActionKind action;
  final String actionTarget;
  final double actionAmountMl;
  final int servings;
  final MealType? meal;
  final CustomFoodDraft? foodDraft;
  final HabitDraft? habitDraft;
}
