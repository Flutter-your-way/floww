import 'package:floww/core/habits/models/habit.dart';

class HabitSuggestion {
  const HabitSuggestion({
    required this.id,
    required this.title,
    required this.target,
    required this.metric,
    required this.icon,
    this.goalType = HabitGoalType.build,
    this.source = HabitSource.manual,
    this.description,
    this.about,
  });

  final String id;
  final String title;
  final double target;
  final HabitMetric metric;
  final HabitIconKind icon;
  final HabitGoalType goalType;
  final HabitSource source;
  final String? description;
  final String? about;
}

class HabitSuggestionGroup {
  const HabitSuggestionGroup({
    required this.id,
    required this.title,
    required this.suggestionIds,
  });

  final String id;
  final String title;
  final List<String> suggestionIds;
}
