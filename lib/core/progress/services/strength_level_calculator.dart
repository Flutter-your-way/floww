import 'package:floww/config/entities/strength_benchmark_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/services/muscle_recovery_service.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';

class StrengthStandard {
  const StrengthStandard({
    required this.benchmarkExercise,
    required this.ratios,
  });

  final String benchmarkExercise;
  final List<double> ratios;
}

class StrengthMuscleSummary {
  const StrengthMuscleSummary({
    required this.group,
    required this.points,
    this.exercise,
    this.level,
  });

  final MuscleGroup group;
  final String? exercise;
  final List<OneRepMaxPoint> points;
  final double? level;

  bool get hasData => points.isNotEmpty;

  double? get latestKg => points.isEmpty ? null : points.last.oneRepMaxKg;

  double? get changeKg => points.length < 2
      ? null
      : points.last.oneRepMaxKg - points.first.oneRepMaxKg;
}

class StrengthLevelCalculator {
  StrengthLevelCalculator._();

  static const double maxLevel = 5;
  static const int trendLimit = 12;

  static const List<MuscleGroup> trackedGroups = [
    MuscleGroup.chest,
    MuscleGroup.shoulders,
    MuscleGroup.biceps,
    MuscleGroup.quadriceps,
    MuscleGroup.hamstrings,
    MuscleGroup.triceps,
    MuscleGroup.back,
  ];

  static const List<String> levelLabels = [
    'Beginner',
    'Novice',
    'Intermediate',
    'Advanced',
    'Elite',
  ];

  static const Map<MuscleGroup, StrengthStandard> standards = {
    MuscleGroup.chest: StrengthStandard(
      benchmarkExercise: 'Bench Press',
      ratios: [0.5, 0.75, 1.0, 1.5, 2.0],
    ),
    MuscleGroup.shoulders: StrengthStandard(
      benchmarkExercise: 'Overhead Press',
      ratios: [0.35, 0.55, 0.75, 1.0, 1.3],
    ),
    MuscleGroup.biceps: StrengthStandard(
      benchmarkExercise: 'Barbell Curl',
      ratios: [0.2, 0.35, 0.5, 0.7, 0.9],
    ),
    MuscleGroup.quadriceps: StrengthStandard(
      benchmarkExercise: 'Back Squat',
      ratios: [0.75, 1.0, 1.5, 2.0, 2.5],
    ),
    MuscleGroup.hamstrings: StrengthStandard(
      benchmarkExercise: 'Romanian Deadlift',
      ratios: [0.6, 0.9, 1.25, 1.75, 2.25],
    ),
    MuscleGroup.triceps: StrengthStandard(
      benchmarkExercise: 'Close-Grip Bench Press',
      ratios: [0.45, 0.65, 0.9, 1.25, 1.6],
    ),
    MuscleGroup.back: StrengthStandard(
      benchmarkExercise: 'Barbell Row',
      ratios: [0.4, 0.65, 0.9, 1.2, 1.5],
    ),
  };

  static String benchmarkExerciseOf(MuscleGroup group) =>
      standards[group]!.benchmarkExercise;

  static String levelLabelOf(double level) =>
      levelLabels[level.floor().clamp(0, levelLabels.length - 1)];

  static double levelOf(
    MuscleGroup group,
    double oneRepMaxKg,
    double bodyWeightKg,
  ) {
    final ratios = standards[group]!.ratios;
    if (bodyWeightKg <= 0) return 0;
    final ratio = oneRepMaxKg / bodyWeightKg;
    var floor = 0.0;
    for (var index = 0; index < ratios.length; index++) {
      final ceiling = ratios[index];
      if (ratio < ceiling) {
        return index + (ratio - floor) / (ceiling - floor);
      }
      floor = ceiling;
    }
    return maxLevel;
  }

  static List<StrengthMuscleSummary> summariesOf({
    required List<WorkoutSessionEntity> sessions,
    required List<StrengthBenchmark> benchmarks,
    required double bodyWeightKg,
  }) {
    final samples = <MuscleGroup, List<_LiftSample>>{};

    for (final session in sessions) {
      if (!session.isCompleted) continue;
      for (final exercise in session.exercises) {
        final oneRepMax = exercise.bestEstimatedOneRepMaxKg;
        if (oneRepMax == null || oneRepMax <= 0) continue;
        final group = _primaryGroupOf(exercise.muscleShares);
        if (group == null || !standards.containsKey(group)) continue;
        samples
            .putIfAbsent(group, () => [])
            .add(_LiftSample(exercise.name, session.date, oneRepMax));
      }
    }

    for (final benchmark in benchmarks) {
      final group = MuscleGroup.values
          .where((value) => value.name == benchmark.muscle)
          .firstOrNull;
      if (group == null || benchmark.oneRepMaxKg <= 0) continue;
      samples
          .putIfAbsent(group, () => [])
          .add(
            _LiftSample(
              benchmark.exercise,
              AppDateUtils.dateOnly(benchmark.loggedAt),
              benchmark.oneRepMaxKg,
            ),
          );
    }

    return [
      for (final group in trackedGroups)
        _summaryOf(group, samples[group] ?? const [], bodyWeightKg),
    ];
  }

  static StrengthMuscleSummary _summaryOf(
    MuscleGroup group,
    List<_LiftSample> samples,
    double bodyWeightKg,
  ) {
    if (samples.isEmpty) {
      return StrengthMuscleSummary(group: group, points: const []);
    }

    final byExercise = <String, List<_LiftSample>>{};
    final names = <String, String>{};
    for (final sample in samples) {
      final key = sample.exercise.trim().toLowerCase();
      byExercise.putIfAbsent(key, () => []).add(sample);
      names.putIfAbsent(key, () => sample.exercise.trim());
    }

    String? tracked;
    for (final entry in byExercise.entries) {
      final current = byExercise[tracked];
      if (current == null ||
          entry.value.length > current.length ||
          (entry.value.length == current.length &&
              _bestOf(entry.value) > _bestOf(current))) {
        tracked = entry.key;
      }
    }

    final bestByDay = <DateTime, double>{};
    for (final sample in byExercise[tracked]!) {
      final previous = bestByDay[sample.date];
      if (previous == null || sample.oneRepMaxKg > previous) {
        bestByDay[sample.date] = sample.oneRepMaxKg;
      }
    }
    final days = bestByDay.keys.toList()..sort();
    final recent = days.length > trendLimit
        ? days.sublist(days.length - trendLimit)
        : days;
    final points = [
      for (final day in recent)
        OneRepMaxPoint(date: day, oneRepMaxKg: bestByDay[day]!),
    ];

    return StrengthMuscleSummary(
      group: group,
      exercise: names[tracked],
      points: points,
      level: levelOf(group, points.last.oneRepMaxKg, bodyWeightKg),
    );
  }

  static double _bestOf(List<_LiftSample> samples) => samples.fold(
    0,
    (best, sample) => sample.oneRepMaxKg > best ? sample.oneRepMaxKg : best,
  );

  static MuscleGroup? _primaryGroupOf(Map<String, double> shares) {
    String? primary;
    var top = 0.0;
    for (final entry in shares.entries) {
      if (entry.value > top) {
        top = entry.value;
        primary = entry.key;
      }
    }
    return primary == null ? null : MuscleRecoveryService.groupOf(primary);
  }
}

class _LiftSample {
  const _LiftSample(this.exercise, this.date, this.oneRepMaxKg);

  final String exercise;
  final DateTime date;
  final double oneRepMaxKg;
}
