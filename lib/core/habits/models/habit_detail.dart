import 'package:floww/core/habits/models/habit.dart';

class HabitDetail {
  const HabitDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.about,
    required this.target,
    required this.metric,
    required this.icon,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.weeklyAveragePercent,
    required this.totalCompletions,
  });

  final String id;
  final String title;
  final String description;
  final String about;
  final double target;
  final HabitMetric metric;
  final HabitIconKind icon;
  final int currentStreakDays;
  final int longestStreakDays;
  final int weeklyAveragePercent;
  final int totalCompletions;
}
