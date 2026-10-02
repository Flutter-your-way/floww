import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:floww/config/utils/formatters/number_formatter.dart';

enum GoalPaceDifficulty {
  easy('Easy', 'Gentle and sustainable. Easy to stick with.'),
  moderate('Moderate', 'A solid push. Consistency carries it.'),
  hard('Hard', 'Aggressive. WAVE will watch recovery closely.');

  const GoalPaceDifficulty(this.label, this.hint);

  final String label;
  final String hint;
}

enum GoalProjectionKind { weightChange, recomposition, activeHours, holdRange }

class GoalPaceConfig {
  const GoalPaceConfig({
    required this.label,
    required this.icon,
    required this.unit,
    required this.min,
    required this.max,
    required this.step,
    required this.initial,
    required this.moderateAt,
    required this.hardAt,
    required this.kind,
    required this.outcome,
    this.digits = 2,
    this.valuePrefix = '',
    this.direction = 1,
    this.tighterIsHarder = false,
  });

  static const int horizonWeeks = 12;
  static const double fallbackWeight = 70;
  static const double recompNetShare = 0.4;

  final String label;
  final IconData icon;
  final String unit;
  final double min;
  final double max;
  final double step;
  final double initial;
  final double moderateAt;
  final double hardAt;
  final GoalProjectionKind kind;
  final String outcome;
  final int digits;
  final String valuePrefix;
  final int direction;
  final bool tighterIsHarder;

  static const Map<String, GoalPaceConfig> byGoal = {
    'Lose Fat': GoalPaceConfig(
      label: 'Fat loss pace',
      icon: Icons.local_fire_department_outlined,
      unit: 'kg / week',
      min: 0.1,
      max: 1.0,
      step: 0.05,
      initial: 0.5,
      moderateAt: 0.4,
      hardAt: 0.75,
      kind: GoalProjectionKind.weightChange,
      direction: -1,
      outcome: 'And keep the muscle you worked for.',
    ),
    'Gain Muscle': GoalPaceConfig(
      label: 'Muscle gain pace',
      icon: Icons.fitness_center,
      unit: 'kg / week',
      min: 0.05,
      max: 0.5,
      step: 0.05,
      initial: 0.25,
      moderateAt: 0.2,
      hardAt: 0.35,
      kind: GoalProjectionKind.weightChange,
      outcome: 'Lean, steady size that sticks.',
    ),
    'Recomposition': GoalPaceConfig(
      label: 'Recomp pace',
      icon: Icons.sync,
      unit: 'kg fat / week',
      min: 0.1,
      max: 0.5,
      step: 0.05,
      initial: 0.25,
      moderateAt: 0.2,
      hardAt: 0.35,
      kind: GoalProjectionKind.recomposition,
      direction: -1,
      outcome: 'Leaner and stronger at almost the same weight.',
    ),
    'Lifestyle': GoalPaceConfig(
      label: 'Active minutes',
      icon: Icons.self_improvement,
      unit: 'min / week',
      min: 60,
      max: 420,
      step: 10,
      initial: 150,
      moderateAt: 180,
      hardAt: 300,
      digits: 0,
      kind: GoalProjectionKind.activeHours,
      outcome: 'More energy, deeper sleep, steadier mood.',
    ),
    'Maintain': GoalPaceConfig(
      label: 'Weight range',
      icon: Icons.balance,
      unit: 'kg',
      min: 0.5,
      max: 3.0,
      step: 0.5,
      initial: 1.5,
      moderateAt: 1.5,
      hardAt: 0.75,
      digits: 1,
      valuePrefix: '± ',
      tighterIsHarder: true,
      kind: GoalProjectionKind.holdRange,
      outcome: 'Week after week, without the yo-yo.',
    ),
  };

  double snap(double value) {
    final snapped = min + ((value - min) / step).round() * step;
    return double.parse(snapped.clamp(min, max).toStringAsFixed(digits));
  }

  String format(double value) => '$valuePrefix${value.toStringAsFixed(digits)}';

  GoalPaceDifficulty difficultyOf(double pace) {
    if (tighterIsHarder) {
      if (pace <= hardAt) return GoalPaceDifficulty.hard;
      if (pace <= moderateAt) return GoalPaceDifficulty.moderate;
      return GoalPaceDifficulty.easy;
    }
    if (pace >= hardAt) return GoalPaceDifficulty.hard;
    if (pace >= moderateAt) return GoalPaceDifficulty.moderate;
    return GoalPaceDifficulty.easy;
  }
}

class GoalPaceProjection {
  const GoalPaceProjection({
    required this.config,
    required this.pace,
    required this.difficulty,
    required this.headlineLead,
    required this.headlineValue,
    required this.headlineTail,
    required this.targetDate,
    required this.samples,
    required this.startLabel,
    required this.endLabel,
    required this.axisMin,
    required this.axisMax,
    this.bandMin,
    this.bandMax,
  });

  static const int sampleCount = 48;

  final GoalPaceConfig config;
  final double pace;
  final GoalPaceDifficulty difficulty;
  final String headlineLead;
  final String headlineValue;
  final String headlineTail;
  final DateTime targetDate;
  final List<double> samples;
  final String startLabel;
  final String endLabel;
  final double axisMin;
  final double axisMax;
  final double? bandMin;
  final double? bandMax;

  String get paceLabel => config.format(pace);

  factory GoalPaceProjection.from({
    required GoalPaceConfig config,
    required double pace,
    required double weight,
    required DateTime today,
  }) {
    const weeks = GoalPaceConfig.horizonWeeks;
    final targetDate = today.add(
      const Duration(days: DateTime.daysPerWeek * weeks),
    );
    final difficulty = config.difficultyOf(pace);

    String kg(double value) => '${value.toStringAsFixed(1)} kg';

    switch (config.kind) {
      case GoalProjectionKind.weightChange:
        final end = weight + config.direction * pace * weeks;
        final extreme = weight + config.direction * config.max * weeks;
        return GoalPaceProjection(
          config: config,
          pace: pace,
          difficulty: difficulty,
          headlineLead: "You'll be ",
          headlineValue: kg(end),
          headlineTail: ' by',
          targetDate: targetDate,
          samples: _curve(weight, end),
          startLabel: kg(weight),
          endLabel: kg(end),
          axisMin: math.min(weight, extreme),
          axisMax: math.max(weight, extreme),
        );
      case GoalProjectionKind.recomposition:
        final fatLost = pace * weeks;
        final end = weight - fatLost * GoalPaceConfig.recompNetShare;
        return GoalPaceProjection(
          config: config,
          pace: pace,
          difficulty: difficulty,
          headlineLead: "You'll drop ",
          headlineValue: '${NumberFormatter.trimmed(fatLost)} kg fat',
          headlineTail: ' by',
          targetDate: targetDate,
          samples: _curve(weight, end),
          startLabel: kg(weight),
          endLabel: kg(end),
          axisMin: weight - config.max * weeks * GoalPaceConfig.recompNetShare,
          axisMax: weight,
        );
      case GoalProjectionKind.activeHours:
        final hours = pace * weeks / Duration.minutesPerHour;
        return GoalPaceProjection(
          config: config,
          pace: pace,
          difficulty: difficulty,
          headlineLead: "You'll bank ",
          headlineValue: '${hours.round()} active hrs',
          headlineTail: ' by',
          targetDate: targetDate,
          samples: _curve(0, hours, eased: false),
          startLabel: '0 hrs',
          endLabel: '${hours.round()} hrs',
          axisMin: 0,
          axisMax: config.max * weeks / Duration.minutesPerHour,
        );
      case GoalProjectionKind.holdRange:
        return GoalPaceProjection(
          config: config,
          pace: pace,
          difficulty: difficulty,
          headlineLead: "You'll hold ",
          headlineValue: kg(weight),
          headlineTail: ' through',
          targetDate: targetDate,
          samples: _wave(weight, pace),
          startLabel: kg(weight),
          endLabel: '${kg(weight - pace)} – ${kg(weight + pace)}',
          axisMin: weight - config.max,
          axisMax: weight + config.max,
          bandMin: weight - pace,
          bandMax: weight + pace,
        );
    }
  }

  static List<double> _curve(double start, double end, {bool eased = true}) {
    return [
      for (var i = 0; i < sampleCount; i++)
        start + (end - start) * _shape(i / (sampleCount - 1), eased),
    ];
  }

  static double _shape(double t, bool eased) {
    if (!eased) return 1 - math.pow(1 - t, 1.6).toDouble();
    return t * t * (3 - 2 * t);
  }

  static List<double> _wave(double center, double range) {
    return [
      for (var i = 0; i < sampleCount; i++)
        center +
            range *
                0.45 *
                math.sin(i / (sampleCount - 1) * math.pi * 3) *
                (1 - i / sampleCount * 0.5),
    ];
  }
}
