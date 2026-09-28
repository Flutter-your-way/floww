import 'package:floww/config/entities/habit_day_log_entity.dart';

enum HabitMetric { minutes, hours, steps, liters, sessions }

enum HabitGoalType { build, limit }

enum HabitSource { manual, water, workout, steps, sleep }

extension HabitSourceMetrics on HabitSource {
  List<HabitMetric> get metrics => switch (this) {
    HabitSource.manual => HabitMetric.values,
    HabitSource.water => const [HabitMetric.liters],
    HabitSource.workout => const [
      HabitMetric.minutes,
      HabitMetric.hours,
      HabitMetric.sessions,
    ],
    HabitSource.steps => const [HabitMetric.steps],
    HabitSource.sleep => const [HabitMetric.hours, HabitMetric.minutes],
  };

  bool supports(HabitMetric metric) => metrics.contains(metric);
}

enum HabitIconKind {
  clipboard,
  book,
  journal,
  coldShower,
  stretching,
  sleep,
  noSugar,
  dumbbell,
  walk,
  water,
  meditation,
  screenFree,
  flame,
  trophy,
  trend,
  target,
}

class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.value,
    required this.target,
    required this.metric,
    this.goalType = HabitGoalType.build,
    this.source = HabitSource.manual,
    this.isDue = true,
    this.description,
  });

  final String id;
  final String title;
  final double value;
  final double target;
  final HabitMetric metric;
  final HabitGoalType goalType;
  final HabitSource source;
  final bool isDue;
  final String? description;

  bool get isLimit => goalType == HabitGoalType.limit;

  bool get isAuto => source != HabitSource.manual;

  bool get isCompleted =>
      HabitGoalMath.isCompleted(value, target, isLimit: isLimit);

  double get progress =>
      HabitGoalMath.progress(value, target, isLimit: isLimit);

  Habit toggled() {
    if (isLimit) return copyWith(value: isCompleted ? target + 1 : 0);
    return copyWith(value: isCompleted ? 0 : target);
  }

  Habit completed() => isCompleted ? this : toggled();

  Habit reopened() => isCompleted ? toggled() : this;

  Habit copyWith({double? value, bool? isDue}) => Habit(
    id: id,
    title: title,
    value: value ?? this.value,
    target: target,
    metric: metric,
    goalType: goalType,
    source: source,
    isDue: isDue ?? this.isDue,
    description: description,
  );
}
