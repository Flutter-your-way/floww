import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_suggestion.dart';

class HabitLabels {
  HabitLabels._();

  static String decimal(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1);
  }

  static String percent(double ratio) => '${(ratio * 100).round()}%';

  static String points(int value) => '+$value Flow pts';

  static String progress(Habit habit) => switch (habit.metric) {
    HabitMetric.minutes =>
      '${decimal(habit.value)} / ${decimal(habit.target)} min',
    HabitMetric.hours => '${decimal(habit.value)} / ${decimal(habit.target)} h',
    HabitMetric.steps =>
      '${NumberFormatter.grouped(habit.value.round())} / '
          '${NumberFormatter.grouped(habit.target.round())} Steps',
    HabitMetric.liters =>
      '${decimal(habit.value)}L / ${decimal(habit.target)}L Target',
    HabitMetric.sessions =>
      '${decimal(habit.value)} / ${decimal(habit.target)} '
          '${habit.target == 1 ? 'session' : 'sessions'}',
  };

  static String unit(HabitMetric metric) => switch (metric) {
    HabitMetric.minutes => 'min',
    HabitMetric.hours => 'h',
    HabitMetric.steps => 'steps',
    HabitMetric.liters => 'L',
    HabitMetric.sessions => 'session',
  };

  static String amount(double target, HabitMetric metric) => switch (metric) {
    HabitMetric.minutes => '${decimal(target)} min',
    HabitMetric.hours => '${decimal(target)} h',
    HabitMetric.steps => '${NumberFormatter.grouped(target.round())} steps',
    HabitMetric.liters => '${decimal(target)}L',
    HabitMetric.sessions =>
      '${decimal(target)} ${target == 1 ? 'session' : 'sessions'}',
  };

  static String target(HabitSuggestion suggestion) =>
      amount(suggestion.target, suggestion.metric);
}
