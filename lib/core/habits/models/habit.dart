enum HabitMetric { minutes, hours, steps, liters, sessions }

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
    this.description,
  });

  final String id;
  final String title;
  final double value;
  final double target;
  final HabitMetric metric;
  final String? description;

  bool get isCompleted => target > 0 && value >= target;

  double get progress => target <= 0 ? 0 : (value / target).clamp(0.0, 1.0);

  Habit copyWith({double? value}) => Habit(
    id: id,
    title: title,
    value: value ?? this.value,
    target: target,
    metric: metric,
    description: description,
  );
}
