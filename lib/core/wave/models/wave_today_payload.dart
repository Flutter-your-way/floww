import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/wave/models/wave_context.dart';

class WaveTodayPayload {
  const WaveTodayPayload(this._values);

  static const int maxListItems = 8;
  static const int maxLongList = 30;
  static const int maxLabelLength = 60;
  static const int maxTitleLength = 80;

  factory WaveTodayPayload.fromContext(WaveContext context) {
    final snapshot = context.snapshot;
    final nutrition = context.nutrition;
    final workout = context.workout;
    final recovery = snapshot.recovery;
    final muscles = snapshot.muscleRecovery;
    final pending = snapshot.habits.where((habit) => !habit.completed);

    return WaveTodayPayload({
      'flowScore': context.flowScore,
      'mode': _label(snapshot.flowMode.mode.name),
      'streakDays': snapshot.streakCount,
      'workoutTitle': _label(workout?.title ?? '', max: maxTitleLength),
      'workoutDetail': _label(
        workout == null
            ? ''
            : '${workout.durationLabel} · ${workout.intensityLabel}',
        max: maxTitleLength,
      ),
      'planExercises': _list(
        context.plan?.exercises.map((entry) => entry.name) ?? const [],
      ),
      'calories': nutrition.totalCalories,
      'calorieGoal': context.goal.calories,
      'proteinG': nutrition.proteinG,
      'proteinGoalG': context.goal.proteinG,
      'carbsG': nutrition.carbsG,
      'fatG': nutrition.fatsG,
      'waterMl': context.waterMl.round(),
      'waterGoalMl': context.goal.waterMl,
      'recentFoods': _list(
        context.recentLogs.reversed.map((log) => log.food.name),
      ),
      'loggedFoods': _list(
        context.todayFoods.map(
          (log) => '${log.food.name} (${log.mealType.label})',
        ),
        max: maxLongList,
        length: maxTitleLength,
      ),
      'knownFoods': _list(
        [
          ...context.customFoods.map((food) => food.name),
          ...FoodCatalog.items.map((food) => food.name),
        ],
        max: maxLongList,
        length: maxTitleLength,
      ),
      'habitsDone': snapshot.habits.length - pending.length,
      'habitsTotal': snapshot.habits.length,
      'habits': _list(
        snapshot.habits.map(
          (habit) =>
              '${habit.title} (${habit.completed ? "done" : habit.valueLabel})',
        ),
        max: maxLongList,
        length: maxTitleLength,
      ),
      'pendingHabits': _list(pending.map((habit) => habit.title)),
      'workoutStatus': _label(_workoutStatusOf(context), max: 30),
      'recoveryPercent': recovery.percent,
      'recoveryLabel': _label(recovery.hasData ? recovery.levelLabel : ''),
      'musclesReady': muscles.readyMusclesCount,
      'musclesRecovering': muscles.inRecoveryCount,
      'musclesFatigued': muscles.fatiguedMusclesCount,
      'localTime': _label(AppDateUtils.time(DateTime.now(), padHour: true)),
    });
  }

  final Map<String, dynamic> _values;

  Map<String, dynamic> toJson() => _values;

  static String _workoutStatusOf(WaveContext context) {
    if (context.hasActiveWorkout) return 'in progress';
    if (context.snapshot.completedWorkout != null) return 'completed today';
    if (context.plan == null) return 'no session planned';
    return 'planned, not started';
  }

  static String _label(String value, {int max = maxLabelLength}) {
    final trimmed = value.trim();
    return trimmed.length <= max ? trimmed : trimmed.substring(0, max);
  }

  static List<String> _list(
    Iterable<String> values, {
    int max = maxListItems,
    int length = maxLabelLength,
  }) {
    final items = <String>[];
    final seen = <String>{};
    for (final value in values) {
      if (items.length >= max) break;
      final label = _label(value, max: length);
      if (label.isEmpty || !seen.add(label.toLowerCase())) continue;
      items.add(label);
    }
    return items;
  }
}
