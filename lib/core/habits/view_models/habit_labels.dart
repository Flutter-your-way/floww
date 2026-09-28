import 'package:flutter/foundation.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_schedule.dart';
import 'package:floww/core/habits/models/habit_suggestion.dart';

class HabitLabels {
  HabitLabels._();

  static const List<String> _weekdayInitials = [
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  static String decimal(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1);
  }

  static String percent(double ratio) => '${(ratio * 100).round()}%';

  static String points(int value) => '+$value Flow pts';

  static String progress(Habit habit) {
    if (habit.isLimit) {
      return '${_valueOf(habit.value, habit.metric)} / max '
          '${amount(habit.target, habit.metric)}';
    }
    return switch (habit.metric) {
      HabitMetric.minutes =>
        '${decimal(habit.value)} / ${decimal(habit.target)} min',
      HabitMetric.hours =>
        '${decimal(habit.value)} / ${decimal(habit.target)} h',
      HabitMetric.steps =>
        '${NumberFormatter.grouped(habit.value.round())} / '
            '${NumberFormatter.grouped(habit.target.round())} Steps',
      HabitMetric.liters =>
        '${decimal(habit.value)}L / ${decimal(habit.target)}L Target',
      HabitMetric.sessions =>
        '${decimal(habit.value)} / ${decimal(habit.target)} '
            '${habit.target == 1 ? 'session' : 'sessions'}',
    };
  }

  static String _valueOf(double value, HabitMetric metric) => switch (metric) {
    HabitMetric.steps => NumberFormatter.grouped(value.round()),
    HabitMetric.liters => '${decimal(value)}L',
    _ => decimal(value),
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
      suggestion.goalType == HabitGoalType.limit
      ? 'Max ${amount(suggestion.target, suggestion.metric)}'
      : amount(suggestion.target, suggestion.metric);

  static String goal(HabitGoalType goalType) => switch (goalType) {
    HabitGoalType.build => 'Build up',
    HabitGoalType.limit => 'Keep under',
  };

  static String weekdayInitial(int weekday) => _weekdayInitials[weekday - 1];

  static String schedule(HabitSchedule schedule) => switch (schedule.type) {
    HabitScheduleType.daily => 'Every day',
    HabitScheduleType.weekdays => [
      for (final day in schedule.weekdays)
        AppDateUtils.shortWeekday(
          AppDateUtils.addDays(
            AppDateUtils.startOfWeek(DateTime.now()),
            day - DateTime.monday,
          ),
        ),
    ].join(', '),
    HabitScheduleType.weekly => timesPerWeek(schedule.timesPerWeek),
  };

  static String timesPerWeek(int times) => '$times× a week';

  static String _healthName() => defaultTargetPlatform == TargetPlatform.iOS
      ? 'Apple Health'
      : 'Health Connect';

  static String source(HabitSource source) => switch (source) {
    HabitSource.manual => 'Off — log manually',
    HabitSource.water => 'Nutrition water log',
    HabitSource.workout => 'Completed workouts',
    HabitSource.steps => '${_healthName()} steps',
    HabitSource.sleep => '${_healthName()} sleep',
  };

  static String? sourceTag(HabitSource source) => switch (source) {
    HabitSource.manual => null,
    HabitSource.water => 'Auto · Nutrition',
    HabitSource.workout => 'Auto · Workouts',
    HabitSource.steps || HabitSource.sleep => 'Auto · ${_healthName()}',
  };

  static String restTag(HabitSchedule schedule) => schedule.isFlexible
      ? 'Optional today · ${timesPerWeek(schedule.timesPerWeek)}'
      : 'Rest day';
}
