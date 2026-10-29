import 'package:floww/core/recovery/models/muscle_group.dart';

class StrengthTrendChart {
  const StrengthTrendChart({
    required this.samples,
    required this.axisLabels,
    required this.dateLabels,
    required this.minValue,
    required this.maxValue,
  });

  final List<double> samples;
  final List<String> axisLabels;
  final List<String> dateLabels;
  final double minValue;
  final double maxValue;
}

class StrengthMuscleView {
  const StrengthMuscleView({
    required this.group,
    required this.title,
    required this.hasData,
    this.levelLabel = '',
    this.valueLabel = '',
    this.unitLabel = '',
    this.exerciseLabel = '',
    this.changeLabel,
    this.isImproving,
    this.chart,
    this.trendHint,
  });

  final MuscleGroup group;
  final String title;
  final bool hasData;
  final String levelLabel;
  final String valueLabel;
  final String unitLabel;
  final String exerciseLabel;
  final String? changeLabel;
  final bool? isImproving;
  final StrengthTrendChart? chart;
  final String? trendHint;
}

class StrengthRadarAxis {
  const StrengthRadarAxis({required this.label, required this.value});

  final String label;
  final double value;
}
