import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_schedule.dart';

class HabitDraft {
  const HabitDraft({
    required this.title,
    required this.target,
    required this.metric,
    this.schedule = const HabitSchedule.daily(),
    this.goalType = HabitGoalType.build,
    this.source = HabitSource.manual,
    this.description,
  });

  final String title;
  final double target;
  final HabitMetric metric;
  final HabitSchedule schedule;
  final HabitGoalType goalType;
  final HabitSource source;
  final String? description;
}
