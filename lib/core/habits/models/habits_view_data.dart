import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_day.dart';

class HabitRowItem {
  const HabitRowItem({
    required this.id,
    required this.title,
    required this.progressLabel,
    required this.progress,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final String progressLabel;
  final double progress;
  final bool isCompleted;
}

class WeekdayProgressItem {
  const WeekdayProgressItem({
    required this.label,
    required this.percentLabel,
    required this.progress,
    required this.status,
  });

  final String label;
  final String percentLabel;
  final double progress;
  final HabitDayStatus status;
}

class CalendarDayItem {
  const CalendarDayItem({
    required this.label,
    required this.progress,
    required this.status,
    required this.isToday,
  });

  final String label;
  final double progress;
  final HabitDayStatus status;
  final bool isToday;
}

class HabitStreakItem {
  const HabitStreakItem({required this.title, required this.daysLabel});

  final String title;
  final String daysLabel;
}

class HabitLegendItem {
  const HabitLegendItem({required this.label, required this.status});

  final String label;
  final HabitDayStatus status;
}

class HabitSuggestionItem {
  const HabitSuggestionItem({
    required this.id,
    required this.title,
    required this.targetLabel,
    required this.icon,
  });

  final String id;
  final String title;
  final String targetLabel;
  final HabitIconKind icon;
}

class HabitStatItem {
  const HabitStatItem({
    required this.title,
    required this.value,
    required this.unit,
    this.icon,
  });

  final String title;
  final String value;
  final String unit;
  final HabitIconKind? icon;
}

class HabitOptionItem {
  const HabitOptionItem({required this.id, required this.label});

  final String id;
  final String label;
}
