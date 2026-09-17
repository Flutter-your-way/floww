import 'package:flutter/material.dart';

enum WaveQuickAction {
  todayPlan,
  shoulderPain,
  finishedWorkout,
  logMeal,
  scoreBreakdown;

  String get label => switch (this) {
    WaveQuickAction.todayPlan => 'What should I do today?',
    WaveQuickAction.shoulderPain => 'My shoulder hurts',
    WaveQuickAction.finishedWorkout => 'I just finished my workout',
    WaveQuickAction.logMeal => 'Log my meal',
    WaveQuickAction.scoreBreakdown => 'Why is my score low?',
  };

  IconData get icon => switch (this) {
    WaveQuickAction.todayPlan => Icons.bolt,
    WaveQuickAction.shoulderPain => Icons.favorite_border_rounded,
    WaveQuickAction.finishedWorkout => Icons.monitor_heart_outlined,
    WaveQuickAction.logMeal => Icons.restaurant_outlined,
    WaveQuickAction.scoreBreakdown => Icons.trending_up_rounded,
  };

  List<String> get keywords => switch (this) {
    WaveQuickAction.todayPlan => const ['today', 'plan', 'what should'],
    WaveQuickAction.shoulderPain => const ['shoulder', 'hurt', 'pain', 'injury'],
    WaveQuickAction.finishedWorkout => const [
      'finished',
      'done',
      'completed workout',
    ],
    WaveQuickAction.logMeal => const ['log my meal', 'log meal', 'ate', 'food'],
    WaveQuickAction.scoreBreakdown => const [
      'score',
      'flow score',
      'why is my',
    ],
  };
}
