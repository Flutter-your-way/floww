import 'package:floww/core/habits/models/habit.dart';

class HabitDraft {
  const HabitDraft({
    required this.title,
    required this.target,
    required this.metric,
    this.description,
  });

  final String title;
  final double target;
  final HabitMetric metric;
  final String? description;
}
