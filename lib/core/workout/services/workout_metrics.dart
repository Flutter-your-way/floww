import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';

class ExerciseBest {
  const ExerciseBest({required this.weightKg, required this.reps});

  static const none = ExerciseBest(weightKg: 0, reps: 0);

  final double weightKg;
  final int reps;
}

class WorkoutTotals {
  const WorkoutTotals({
    required this.volumeKg,
    required this.totalSets,
    required this.totalReps,
    required this.exerciseCount,
    required this.weightedMet,
  });

  final double volumeKg;
  final int totalSets;
  final int totalReps;
  final int exerciseCount;
  final double weightedMet;
}

class WorkoutMetrics {
  WorkoutMetrics._();

  static const double fallbackBodyWeightKg = 70;
  static const double fallbackMet = 5;
  static const int effectSegments = 7;
  static const double maxTrainingEffect = 5;
  static const int _secondsPerHour = 3600;
  static const int _targetSets = 20;
  static const int _targetMinutes = 60;
  static const double _targetMet = 8;
  static const double _weightPrThresholdKg = 0.5;

  static WorkoutTotals totalsOf(List<WorkoutEntryEntity> exercises) {
    var volume = 0.0;
    var sets = 0;
    var reps = 0;
    var count = 0;
    var metWeighted = 0.0;

    for (final exercise in exercises) {
      if (exercise.sets.isEmpty) continue;
      count++;
      sets += exercise.sets.length;
      reps += exercise.completedReps;
      volume += exercise.completedVolumeKg;
      metWeighted += exercise.met * exercise.sets.length;
    }

    return WorkoutTotals(
      volumeKg: volume,
      totalSets: sets,
      totalReps: reps,
      exerciseCount: count,
      weightedMet: sets == 0 ? fallbackMet : metWeighted / sets,
    );
  }

  static int caloriesOf({
    required WorkoutTotals totals,
    required int durationSeconds,
    required double bodyWeightKg,
  }) {
    if (durationSeconds <= 0) return 0;
    final hours = durationSeconds / _secondsPerHour;
    return (totals.weightedMet * bodyWeightKg * hours).round();
  }

  static double trainingEffectOf({
    required WorkoutTotals totals,
    required int durationSeconds,
  }) {
    if (totals.totalSets == 0) return 0;
    final setScore = (totals.totalSets / _targetSets).clamp(0.0, 1.0) * 2;
    final minutes = durationSeconds / Duration.secondsPerMinute;
    final durationScore = (minutes / _targetMinutes).clamp(0.0, 1.0) * 1.5;
    final intensityScore =
        (totals.weightedMet / _targetMet).clamp(0.0, 1.0) * 0.5;
    final effect = 1 + setScore + durationScore + intensityScore;
    return double.parse(effect.clamp(1.0, maxTrainingEffect).toStringAsFixed(1));
  }

  static String effectRatingOf(double effect) {
    if (effect < 2) return 'Easy';
    if (effect < 3) return 'Maintaining';
    if (effect < 4) return 'Improving';
    if (effect < 4.6) return 'Great';
    return 'Highly Impactful';
  }

  static String effectSummaryOf(double effect, List<MuscleShareEntry> muscles) {
    final focus = muscles.isEmpty ? 'your body' : muscles.first.name;
    if (effect < 2) {
      return 'A light session that keeps blood flowing to $focus without '
          'adding fatigue.';
    }
    if (effect < 3) {
      return 'Enough work on $focus to hold your current level of fitness.';
    }
    if (effect < 4) {
      return 'This workout built strength and muscular endurance in $focus.';
    }
    return 'This workout improved your strength and muscular endurance in '
        '$focus.';
  }

  static int recoveryHoursOf(double effect) {
    if (effect < 2) return 12;
    if (effect < 3) return 24;
    if (effect < 4) return 36;
    return 48;
  }

  static List<MuscleShareEntry> muscleActivationOf(
    List<WorkoutEntryEntity> exercises,
  ) {
    final scores = <String, double>{};
    for (final exercise in exercises) {
      if (exercise.sets.isEmpty) continue;
      final effort = exercise.completedReps.toDouble();
      for (final entry in exercise.muscleShares.entries) {
        scores[entry.key] = (scores[entry.key] ?? 0) + entry.value * effort;
      }
    }
    if (scores.isEmpty) return const [];

    var peak = 0.0;
    for (final score in scores.values) {
      if (score > peak) peak = score;
    }
    if (peak == 0) return const [];

    final completion = _completionRatioOf(exercises);
    final activation = [
      for (final entry in scores.entries)
        MuscleShareEntry(
          name: entry.key,
          share: double.parse(
            ((entry.value / peak) * completion).clamp(0.0, 1.0)
                .toStringAsFixed(2),
          ),
        ),
    ]..sort((a, b) => b.share.compareTo(a.share));

    return activation;
  }

  static double _completionRatioOf(List<WorkoutEntryEntity> exercises) {
    var planned = 0;
    var logged = 0;
    for (final exercise in exercises) {
      planned += exercise.targetSets;
      logged += exercise.sets.length;
    }
    if (planned == 0) return logged == 0 ? 0 : 1;
    return (logged / planned).clamp(0.0, 1.0);
  }

  static List<PersonalRecordEntry> personalRecordsOf({
    required List<WorkoutEntryEntity> exercises,
    required Map<String, ExerciseBest> previousBests,
  }) {
    final records = <PersonalRecordEntry>[];
    for (final exercise in exercises) {
      if (exercise.sets.isEmpty) continue;
      final best = previousBests[exercise.exerciseId] ?? ExerciseBest.none;
      final weight = exercise.bestSetWeightKg;

      if (weight != null && weight > best.weightKg + _weightPrThresholdKg) {
        final gain = best.weightKg == 0 ? weight : weight - best.weightKg;
        records.add(
          PersonalRecordEntry(
            exerciseId: exercise.exerciseId,
            exercise: exercise.name,
            improvement: '+${_weightLabel(gain)}kg',
            glyph: '🏋️',
          ),
        );
        continue;
      }

      if (weight == null && exercise.bestSetReps > best.reps) {
        final gain = best.reps == 0
            ? exercise.bestSetReps
            : exercise.bestSetReps - best.reps;
        records.add(
          PersonalRecordEntry(
            exerciseId: exercise.exerciseId,
            exercise: exercise.name,
            improvement: '+$gain rep${gain == 1 ? '' : 's'}',
            glyph: '💪',
          ),
        );
      }
    }
    return records;
  }

  static Map<String, ExerciseBest> bestsOf(
    List<WorkoutSessionEntity> sessions,
  ) {
    final bests = <String, ExerciseBest>{};
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        for (final set in exercise.sets) {
          final current = bests[exercise.exerciseId] ?? ExerciseBest.none;
          final weight = set.weightKg ?? 0;
          bests[exercise.exerciseId] = ExerciseBest(
            weightKg: weight > current.weightKg ? weight : current.weightKg,
            reps: set.reps > current.reps ? set.reps : current.reps,
          );
        }
      }
    }
    return bests;
  }

  static String _weightLabel(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}
