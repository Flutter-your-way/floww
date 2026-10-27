import 'package:flutter/widgets.dart';

enum GuideSection { home, nutrition, workout, habits, progress }

enum GuideTargetId {
  homeFlowScore,
  homeMode,
  homeHabits,
  homeWorkout,
  homeNutrition,
  homeHealth,
  nutritionDate,
  nutritionCalories,
  nutritionMacros,
  nutritionMicros,
  nutritionMeals,
  workoutDate,
  workoutTabs,
  workoutAgenda,
  workoutOverview,
  workoutStart,
  habitsDate,
  habitsScore,
  habitsToday,
  habitsEmpty,
  habitsWeekly,
  habitsAdd,
  progressOverview,
  progressFlowScore,
  progressWeight,
  progressAnalytics,
  progressInsights,
}

@immutable
class GuideStep {
  const GuideStep({
    required this.icon,
    required this.title,
    required this.body,
    this.highlights = const [],
    this.targets = const [],
  });

  final IconData icon;
  final String title;
  final String body;
  final List<String> highlights;
  final List<GuideTargetId> targets;
}

@immutable
class GuideViewState {
  const GuideViewState({
    required this.flow,
    required this.step,
    required this.index,
    required this.count,
    required this.direction,
    required this.nextLabel,
    required this.skipLabel,
  });

  final GuideFlow flow;
  final GuideStep step;
  final int index;
  final int count;
  final int direction;
  final String nextLabel;
  final String skipLabel;

  bool get isFirst => index == 0;
  bool get isLast => index >= count - 1;
}

@immutable
class GuideFlow {
  const GuideFlow({
    required this.section,
    required this.label,
    required this.steps,
    required this.finishLabel,
  });

  final GuideSection section;
  final String label;
  final List<GuideStep> steps;
  final String finishLabel;
}

@immutable
class GuideTargetEntry {
  const GuideTargetEntry({
    required this.context,
    required this.radius,
    required this.padding,
  });

  final BuildContext context;
  final double radius;
  final double padding;
}
