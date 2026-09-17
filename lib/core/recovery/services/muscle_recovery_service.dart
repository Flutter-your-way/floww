import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/models/muscle_recovery_item.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

class MuscleRecoverySnapshot {
  const MuscleRecoverySnapshot({
    required this.items,
    required this.lastWorkoutAt,
  });

  static const empty = MuscleRecoverySnapshot(items: [], lastWorkoutAt: null);

  final List<MuscleRecoveryItem> items;
  final DateTime? lastWorkoutAt;
}

class MuscleRecoveryService {
  MuscleRecoveryService({WorkoutSessionService? sessionService})
    : _sessionService = sessionService ?? WorkoutSessionService();

  static const int fullRecoveryPercent = 100;

  static const Map<String, MuscleGroup> _groupsByName = {
    'chest': MuscleGroup.chest,
    'back': MuscleGroup.back,
    'lats': MuscleGroup.back,
    'shoulders': MuscleGroup.shoulders,
    'delts': MuscleGroup.shoulders,
    'biceps': MuscleGroup.biceps,
    'triceps': MuscleGroup.triceps,
    'quadriceps': MuscleGroup.quadriceps,
    'quads': MuscleGroup.quadriceps,
    'glutes': MuscleGroup.glutes,
    'hamstrings': MuscleGroup.hamstrings,
    'calves': MuscleGroup.calves,
    'abdominals': MuscleGroup.abdominals,
    'abs': MuscleGroup.abdominals,
    'core': MuscleGroup.abdominals,
    'adductors': MuscleGroup.adductors,
    'traps': MuscleGroup.traps,
  };

  final WorkoutSessionService _sessionService;

  Stream<MuscleRecoverySnapshot> watch() =>
      _sessionService.watchRecentSessions().map(snapshotOf);

  MuscleRecoverySnapshot snapshotOf(
    List<WorkoutSessionEntity> sessions, {
    DateTime? now,
  }) {
    final moment = now ?? DateTime.now();
    final fatigue = <MuscleGroup, double>{};
    final lastTrained = <MuscleGroup, DateTime>{};
    DateTime? lastWorkoutAt;

    for (final session in sessions) {
      if (session.status != WorkoutSessionStatus.completed) continue;

      final completedAt = session.completedAt;
      if (completedAt.isAfter(moment)) continue;
      if (lastWorkoutAt == null || completedAt.isAfter(lastWorkoutAt)) {
        lastWorkoutAt = completedAt;
      }

      final window = Duration(
        hours: WorkoutMetrics.recoveryHoursOf(session.trainingEffect),
      );
      final elapsed = moment.difference(completedAt);
      final remaining = window.inMinutes == 0
          ? 0.0
          : (1 - elapsed.inMinutes / window.inMinutes).clamp(0.0, 1.0);

      for (final entry in session.muscleActivation) {
        final group = groupOf(entry.name);
        if (group == null || entry.share <= 0) continue;

        final previous = lastTrained[group];
        if (previous == null || completedAt.isAfter(previous)) {
          lastTrained[group] = completedAt;
        }

        if (remaining == 0) continue;
        fatigue[group] = (fatigue[group] ?? 0) + entry.share * remaining;
      }
    }

    return MuscleRecoverySnapshot(
      lastWorkoutAt: lastWorkoutAt,
      items: [
        for (final group in MuscleGroup.values)
          MuscleRecoveryItem(
            group: group,
            percent: _percentOf(fatigue[group] ?? 0),
            lastTrainedAt: lastTrained[group],
          ),
      ],
    );
  }

  static MuscleGroup? groupOf(String name) =>
      _groupsByName[name.trim().toLowerCase()];

  static int _percentOf(double fatigue) =>
      fullRecoveryPercent - (fatigue.clamp(0.0, 1.0) * fullRecoveryPercent).round();
}
