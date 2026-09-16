import 'package:floww/core/habits/models/habit.dart';

class HabitSuggestion {
  const HabitSuggestion({
    required this.id,
    required this.title,
    required this.target,
    required this.metric,
    required this.icon,
  });

  final String id;
  final String title;
  final double target;
  final HabitMetric metric;
  final HabitIconKind icon;
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
