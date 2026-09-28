import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';

class ProgressionSuggestion {
  const ProgressionSuggestion({
    required this.sets,
    required this.reps,
    this.weightKg,
    this.reason,
  });

  final int sets;
  final int reps;
  final double? weightKg;
  final String? reason;
}

class WorkoutProgression {
  WorkoutProgression._();

  static const double _deloadFactor = 0.9;
  static const double _deloadVolumeFactor = 0.6;
  static const int _maxBodyweightReps = 20;
  static const int _maxSets = 6;
  static const int _timedStepSeconds = 5;
  static const int _maxTimedSeconds = 600;

  static List<WorkoutEntryEntity> historyOf(
    List<WorkoutSessionEntity> sessions,
    String exerciseId, {
    String? excludeSessionId,
  }) {
    final sorted = [
      for (final session in sessions)
        if (session.isCompleted && session.id != excludeSessionId) session,
    ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return [
      for (final session in sorted)
        for (final entry in session.exercises)
          if (entry.exerciseId == exerciseId && entry.workingSetCount > 0)
            entry,
    ];
  }

  static int deloadSetsOf(int sets) {
    final reduced = (sets * _deloadVolumeFactor).round();
    return reduced < 1 ? 1 : reduced;
  }

  static ProgressionSuggestion suggest({
    required WorkoutEntryEntity planned,
    required List<WorkoutEntryEntity> history,
    required double weightStepKg,
    bool isDeload = false,
  }) {
    final hold = ProgressionSuggestion(
      sets: planned.targetSets,
      reps: planned.targetReps,
      weightKg: planned.targetWeightKg,
    );
    if (history.isEmpty) return hold;
    final last = history.first;

    if (planned.isTimed) return _timedOf(planned, last, isDeload);
    if (planned.isBodyweight) return _bodyweightOf(planned, last, isDeload);
    return _weightedOf(planned, history, weightStepKg, isDeload);
  }

  static ProgressionSuggestion _timedOf(
    WorkoutEntryEntity planned,
    WorkoutEntryEntity last,
    bool isDeload,
  ) {
    final base = last.targetReps > planned.targetReps
        ? last.targetReps
        : planned.targetReps;
    if (isDeload || !_hitTarget(last)) {
      return ProgressionSuggestion(
        sets: planned.targetSets,
        reps: base,
        reason: isDeload ? null : 'Hold ${base}s until every set is full.',
      );
    }
    final next = (base + _timedStepSeconds).clamp(0, _maxTimedSeconds);
    return ProgressionSuggestion(
      sets: planned.targetSets,
      reps: next,
      reason:
          '${last.name} +${_timedStepSeconds}s — you held every set last time.',
    );
  }

  static ProgressionSuggestion _bodyweightOf(
    WorkoutEntryEntity planned,
    WorkoutEntryEntity last,
    bool isDeload,
  ) {
    final baseReps = last.targetReps > planned.targetReps
        ? last.targetReps
        : planned.targetReps;
    final baseSets = last.targetSets > planned.targetSets && !isDeload
        ? last.targetSets
        : planned.targetSets;
    if (isDeload || !_hitTarget(last) || !_hadReserve(last)) {
      return ProgressionSuggestion(sets: baseSets, reps: baseReps);
    }
    if (baseReps >= _maxBodyweightReps && baseSets < _maxSets) {
      return ProgressionSuggestion(
        sets: baseSets + 1,
        reps: baseReps,
        reason: '${last.name} gets an extra set — reps are maxed out.',
      );
    }
    final reps = baseReps >= _maxBodyweightReps ? baseReps : baseReps + 1;
    return ProgressionSuggestion(
      sets: baseSets,
      reps: reps,
      reason: reps == baseReps
          ? null
          : '${last.name} +1 rep — you hit every set last time.',
    );
  }

  static ProgressionSuggestion _weightedOf(
    WorkoutEntryEntity planned,
    List<WorkoutEntryEntity> history,
    double step,
    bool isDeload,
  ) {
    final last = history.first;
    final lastWeight = last.bestSetWeightKg ?? planned.targetWeightKg;
    if (lastWeight == null) {
      return ProgressionSuggestion(
        sets: planned.targetSets,
        reps: planned.targetReps,
        weightKg: planned.targetWeightKg,
      );
    }
    final sets = planned.targetSets;
    final reps = planned.targetReps;
    final label = WorkoutMetrics.weightLabel;

    if (isDeload) {
      final weight = _roundTo(lastWeight * _deloadFactor, step);
      return ProgressionSuggestion(
        sets: sets,
        reps: reps,
        weightKg: weight,
        reason: 'Deload: ${last.name} at ${label(weight)}kg to recover.',
      );
    }

    if (_hitTarget(last)) {
      if (!_hadReserve(last)) {
        return ProgressionSuggestion(
          sets: sets,
          reps: reps,
          weightKg: lastWeight,
          reason:
              '${last.name} stays at ${label(lastWeight)}kg — last session '
              'was close to failure.',
        );
      }
      final weight = lastWeight + step;
      return ProgressionSuggestion(
        sets: sets,
        reps: reps,
        weightKg: weight,
        reason:
            '${last.name} +${label(step)}kg — you hit '
            '${last.targetSets}×${last.targetReps} with reps to spare.',
      );
    }

    final previous = history.length > 1 ? history[1] : null;
    final previousWeight = previous?.bestSetWeightKg;
    if (previous != null &&
        !_hitTarget(previous) &&
        previousWeight != null &&
        previousWeight >= lastWeight) {
      final weight = _roundTo(lastWeight * _deloadFactor, step);
      return ProgressionSuggestion(
        sets: sets,
        reps: reps,
        weightKg: weight,
        reason:
            '${last.name} drops to ${label(weight)}kg after two tough '
            'sessions — rebuild from here.',
      );
    }

    return ProgressionSuggestion(
      sets: sets,
      reps: reps,
      weightKg: lastWeight,
      reason:
          'Repeat ${last.name} at ${label(lastWeight)}kg and chase every rep.',
    );
  }

  static bool _hitTarget(WorkoutEntryEntity entry) {
    final working = entry.workingSets;
    if (working.length < entry.targetSets) return false;
    for (final set in working) {
      final value = entry.isTimed ? set.durationSeconds ?? 0 : set.reps;
      if (value < entry.targetReps) return false;
    }
    return true;
  }

  static bool _hadReserve(WorkoutEntryEntity entry) {
    for (final set in entry.workingSets) {
      final reserve = set.repsInReserve;
      if (reserve != null && reserve < entry.repsInReserve) return false;
    }
    return true;
  }

  static double _roundTo(double value, double step) {
    if (step <= 0) return value;
    final rounded = (value / step).round() * step;
    return rounded < step ? step : rounded;
  }
}
