import 'dart:math' as math;

import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/core/recovery/models/muscle_emphasis.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/services/muscle_recovery_service.dart';

class MuscleTargets {
  const MuscleTargets(this.emphasis);

  static const empty = MuscleTargets({});

  final Map<MuscleGroup, MuscleEmphasis> emphasis;

  bool get isEmpty => emphasis.isEmpty;

  List<MuscleGroup> groupsOf(MuscleEmphasis level) => [
    for (final entry in emphasis.entries)
      if (entry.value == level) entry.key,
  ];

  String? labelOf(MuscleEmphasis level) {
    final groups = groupsOf(level);
    if (groups.isEmpty) return null;
    return groups.map((group) => group.label).join(', ');
  }
}

class MuscleTargeting {
  MuscleTargeting._();

  static const double primaryRatio = 0.8;

  static MuscleTargets ofShares(Map<String, double> shares) {
    final load = <MuscleGroup, double>{};
    shares.forEach((name, share) {
      final group = MuscleRecoveryService.groupOf(name);
      if (group == null || share <= 0) return;
      load[group] = math.max(load[group] ?? 0, share);
    });
    return _classify(load);
  }

  static MuscleTargets ofEntries(Iterable<WorkoutEntryEntity> entries) {
    final load = <MuscleGroup, double>{};
    for (final entry in entries) {
      final sets = math.max(entry.targetSets, 1);
      entry.muscleShares.forEach((name, share) {
        final group = MuscleRecoveryService.groupOf(name);
        if (group == null || share <= 0) return;
        load[group] = (load[group] ?? 0) + share * sets;
      });
    }
    return _classify(load);
  }

  static MuscleTargets _classify(Map<MuscleGroup, double> load) {
    if (load.isEmpty) return MuscleTargets.empty;
    final peak = load.values.reduce(math.max);
    final ranked = load.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return MuscleTargets({
      for (final entry in ranked)
        entry.key: entry.value >= peak * primaryRatio
            ? MuscleEmphasis.primary
            : MuscleEmphasis.secondary,
    });
  }
}
