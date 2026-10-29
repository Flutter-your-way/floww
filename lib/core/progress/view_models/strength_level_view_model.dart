import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/progress/models/strength_view_data.dart';
import 'package:floww/core/progress/services/progress_service.dart';
import 'package:floww/core/progress/services/strength_level_calculator.dart';
import 'package:floww/core/progress/services/strength_service.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';

class StrengthLevelViewModel extends ChangeNotifier {
  StrengthLevelViewModel(this._service) {
    _subscription = _service.watch().listen(
      _apply,
      onError: (Object error) {
        debugPrint('strength watch failed: $error');
        _isLoading = false;
        _errorMessage = 'Could not load your strength data.';
        notifyListeners();
      },
    );
  }

  static const int _assessmentMinimum = 3;
  static const int _maxReps = 30;
  static const double _chartPaddingRatio = 0.1;
  static const double _chartMinSpanKg = 5;

  final StrengthService _service;
  StreamSubscription<StrengthRecords>? _subscription;
  List<StrengthMuscleSummary> _summaries = [
    for (final group in StrengthLevelCalculator.trackedGroups)
      StrengthMuscleSummary(group: group, points: const []),
  ];
  bool _isLoading = true;
  String? _errorMessage;
  bool _disposed = false;

  String get title => 'Strength Level';

  String get unit => 'kg';

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String get infoTitle => 'How Strength Level works';

  String get infoMessage =>
      'For each muscle group, WAVE tracks the lift you log most and estimates '
      'your one-rep max from your best set. That number, compared with your '
      'body weight, places you from Beginner to Elite. Your workouts update '
      'it automatically, or tap a muscle to log a benchmark set.';

  String get emptyValueLabel => 'N/A';

  String get addLabel => 'Tap to add';

  String get logAgainLabel => 'Log benchmark';

  List<StrengthMuscleSummary> get _assessed =>
      _summaries.where((summary) => summary.level != null).toList();

  String get assessmentMessage {
    final assessed = _assessed;
    if (assessed.length < _assessmentMinimum) {
      return 'Log more benchmarks to get your personalized strength '
          'assessment.';
    }
    final average =
        assessed.fold<double>(0, (sum, item) => sum + item.level!) /
        assessed.length;
    return "You're at an overall ${StrengthLevelCalculator.levelLabelOf(average)} "
        'level across ${assessed.length} muscle groups.';
  }

  List<StrengthRadarAxis> get radarAxes => [
    for (final summary in _summaries)
      StrengthRadarAxis(
        label: summary.group.label,
        value: ((summary.level ?? 0) / StrengthLevelCalculator.maxLevel).clamp(
          0.0,
          1.0,
        ),
      ),
  ];

  List<StrengthMuscleView> get muscles => [
    for (final summary in _summaries) _viewOf(summary),
  ];

  String benchmarkTitleOf(MuscleGroup group) => 'Log ${group.label} Benchmark';

  String get benchmarkSubtitle =>
      'Enter your heaviest recent set. We estimate your one-rep max from it.';

  String defaultExerciseOf(MuscleGroup group) {
    final summary = _summaries.where((item) => item.group == group).firstOrNull;
    return summary?.exercise ??
        StrengthLevelCalculator.benchmarkExerciseOf(group);
  }

  String get exerciseHint => 'Exercise';

  String get weightHint => 'Weight ($unit)';

  String get repsHint => 'Reps';

  String get saveBenchmarkLabel => 'Save Benchmark';

  bool canLogBenchmark(String exercise, String weight, String reps) =>
      _validated(exercise, weight, reps) == null;

  Future<String?> logBenchmark(
    MuscleGroup group, {
    required String exercise,
    required String weight,
    required String reps,
  }) async {
    final error = _validated(exercise, weight, reps);
    if (error != null) return error;
    try {
      await _service.addBenchmark(
        muscle: group.name,
        exercise: exercise.trim(),
        weightKg: double.parse(weight.trim()),
        reps: int.parse(reps.trim()),
      );
      return null;
    } on ProgressException catch (e) {
      return e.message;
    }
  }

  String? _validated(String exercise, String weight, String reps) {
    if (exercise.trim().isEmpty) return 'Enter the exercise name.';
    final weightKg = double.tryParse(weight.trim());
    if (weightKg == null || weightKg <= 0) return 'Enter a valid weight.';
    final repCount = int.tryParse(reps.trim());
    if (repCount == null || repCount <= 0 || repCount > _maxReps) {
      return 'Enter between 1 and $_maxReps reps.';
    }
    return null;
  }

  StrengthMuscleView _viewOf(StrengthMuscleSummary summary) {
    final latest = summary.latestKg;
    final level = summary.level;
    if (latest == null || level == null) {
      return StrengthMuscleView(
        group: summary.group,
        title: summary.group.label,
        hasData: false,
      );
    }

    final change = summary.changeKg;
    final points = summary.points;
    return StrengthMuscleView(
      group: summary.group,
      title: summary.group.label,
      hasData: true,
      levelLabel: StrengthLevelCalculator.levelLabelOf(level),
      valueLabel: WorkoutMetrics.weightLabel(_rounded(latest)),
      unitLabel: unit,
      exerciseLabel: '${summary.exercise} · est. 1RM',
      changeLabel: change == null ? null : _changeLabelOf(change, points),
      isImproving: change == null || _rounded(change) == 0 ? null : change > 0,
      chart: points.length < 2 ? null : _chartOf(summary),
      trendHint: points.length < 2
          ? 'Log this lift again to see your strength trend.'
          : null,
    );
  }

  String _changeLabelOf(double change, List<OneRepMaxPoint> points) {
    final since = AppDateUtils.shortMonthDay(points.first.date);
    final rounded = _rounded(change);
    if (rounded == 0) return 'No change since $since';
    final sign = rounded > 0 ? '+' : '−';
    return '$sign${WorkoutMetrics.weightLabel(rounded.abs())} $unit since $since';
  }

  StrengthTrendChart _chartOf(StrengthMuscleSummary summary) {
    final values = [for (final point in summary.points) point.oneRepMaxKg];
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    final span = math.max(high - low, _chartMinSpanKg);
    final padding = span * _chartPaddingRatio;
    final minValue = math.max(0.0, low - padding);
    final maxValue = minValue + span + padding * 2;
    final middle = (minValue + maxValue) / 2;
    final points = summary.points;

    return StrengthTrendChart(
      samples: values,
      minValue: minValue,
      maxValue: maxValue,
      axisLabels: [
        for (final value in [maxValue, middle, minValue])
          value.round().toString(),
      ],
      dateLabels: [
        AppDateUtils.shortMonthDay(points.first.date),
        AppDateUtils.shortMonthDay(points.last.date),
      ],
    );
  }

  static double _rounded(double value) => (value * 2).round() / 2;

  void _apply(StrengthRecords records) {
    _summaries = StrengthLevelCalculator.summariesOf(
      sessions: records.sessions,
      benchmarks: records.benchmarks,
      bodyWeightKg: records.bodyWeightKg,
    );
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
