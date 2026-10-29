import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/core/calisthenics/data/calisthenics_ladders_data.dart';
import 'package:floww/core/calisthenics/models/cal_entry_key.dart';
import 'package:floww/core/calisthenics/models/cal_ladder.dart';
import 'package:floww/core/calisthenics/models/cal_slot.dart';
import 'package:floww/core/calisthenics/models/calisthenics_profile.dart';
import 'package:floww/core/calisthenics/services/calisthenics_plan_mapper.dart';
import 'package:floww/core/workout/services/workout_readiness_service.dart';

class CalSlotHistory {
  const CalSlotHistory(this.entries);

  final List<WorkoutEntryEntity> entries;

  String? get lastMoveId => entries.isEmpty ? null : entries.first.exerciseId;

  List<WorkoutEntryEntity> of(String moveId) => [
    for (final entry in entries)
      if (entry.exerciseId == moveId) entry,
  ];
}

enum CalLadderChange { none, advanced, regressed }

class CalisthenicsProgression {
  CalisthenicsProgression._();

  static const int _repStep = 1;
  static const int _timedSteps = 4;
  static const int _minSets = 1;
  static const int _maxReasons = 3;

  static CalSlotHistory slotHistoryOf(
    List<WorkoutSessionEntity> sessions,
    CalEntryKey key,
  ) {
    final prefix = key.idFor('');
    final sorted = [
      for (final session in sessions)
        if (session.isCompleted) session,
    ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return CalSlotHistory([
      for (final session in sorted)
        for (final entry in session.exercises)
          if (entry.id.startsWith(prefix) && entry.workingSetCount > 0) entry,
    ]);
  }

  static int valueOf(WorkoutEntryEntity entry, LoggedSetEntry set) =>
      entry.isTimed ? set.durationSeconds ?? 0 : set.reps;

  static bool hitTarget(WorkoutEntryEntity entry) {
    final working = entry.workingSets;
    if (working.length < entry.targetSets) return false;
    return working.every((set) => valueOf(entry, set) >= entry.targetReps);
  }

  static bool meetsStandard(WorkoutEntryEntity entry, CalLadderStep step) {
    final sets = step.sets;
    final value = step.value;
    if (sets == null || value == null) return false;
    final hits = entry.workingSets
        .where((set) => valueOf(entry, set) >= value)
        .length;
    return hits >= sets;
  }

  static bool fellShort(WorkoutEntryEntity entry, int min) {
    var best = 0;
    for (final set in entry.workingSets) {
      final value = valueOf(entry, set);
      if (value > best) best = value;
    }
    return best < min;
  }

  static WorkoutPlanEntity adapt(
    WorkoutPlanEntity plan, {
    required List<WorkoutSessionEntity> history,
    required Map<String, ExerciseCatalogEntry> catalog,
    required CalisthenicsProfile profile,
    required WorkoutReadiness readiness,
  }) {
    final reasons = <String>[];
    final used = <String>{
      for (final entry in plan.exercises)
        if (CalEntryKey.parse(entry.id)?.kind == CalEntryKind.main)
          entry.exerciseId,
    };
    final exercises = <WorkoutEntryEntity>[];
    for (final entry in plan.exercises) {
      final key = CalEntryKey.parse(entry.id);
      final slot = key?.slot;
      if (key == null || slot == null || key.kind != CalEntryKind.main) {
        exercises.add(entry);
        continue;
      }
      final slotHistory = slotHistoryOf(history, key);
      final (moveId, change) = _moveOf(
        entry,
        slot,
        key,
        slotHistory,
        profile,
        used,
      );
      if (moveId != entry.exerciseId) {
        used
          ..remove(entry.exerciseId)
          ..add(moveId);
      }
      final adapted = _entryOf(
        entry,
        moveId,
        change,
        slot,
        key,
        slotHistory,
        catalog,
        reasons,
      );
      exercises.add(_withReadiness(adapted, readiness));
    }

    final notes = <String>[
      if (readiness.isLow)
        'Readiness is low (${readiness.reasons.join(', ')}), so WAVE trimmed '
            'a set from each main exercise and added a rep in reserve.',
      if (readiness.isHigh)
        'Readiness is high (${readiness.reasons.join(', ')}): a good day to '
            'chase the top of your ranges.',
      ...reasons.take(_maxReasons),
    ];
    return plan.copyWith(
      exercises: exercises,
      isAdapted: true,
      insight: notes.isEmpty
          ? plan.insight
          : '${plan.insight}\n\n${notes.join('\n')}',
    );
  }

  static (String, CalLadderChange) _moveOf(
    WorkoutEntryEntity entry,
    CalSlot slot,
    CalEntryKey key,
    CalSlotHistory slotHistory,
    CalisthenicsProfile profile,
    Set<String> used,
  ) {
    final last = slotHistory.lastMoveId;
    final state =
        last != null &&
            CalisthenicsPlanMapper.resolveMove(last, profile.gear) == last
        ? last
        : entry.exerciseId;
    const hold = CalLadderChange.none;
    final ladder = CalisthenicsLaddersData.byId(slot.ladderId);
    if (ladder == null) return (state, hold);
    final index = ladder.indexOf(state);
    if (index < 0) return (state, hold);

    bool eligible(int target) {
      if (target < 0 || target >= ladder.steps.length) return false;
      final step = ladder.steps[target];
      if (step.level > key.level.number) return false;
      if (step.isTimed != slot.unit.isTimed) return false;
      if (!step.hasStandard && slot.block != CalBlock.skill) return false;
      if (step.moveId != state && used.contains(step.moveId)) return false;
      return CalisthenicsPlanMapper.resolveMove(step.moveId, profile.gear) ==
          step.moveId;
    }

    final recent = slotHistory
        .of(state)
        .take(CalisthenicsLaddersData.consecutiveSessions)
        .toList();
    if (recent.length < CalisthenicsLaddersData.consecutiveSessions) {
      return (state, hold);
    }
    final step = ladder.steps[index];
    if (recent.every((item) => meetsStandard(item, step)) &&
        eligible(index + 1)) {
      return (ladder.steps[index + 1].moveId, CalLadderChange.advanced);
    }
    if (recent.every((item) => fellShort(item, slot.min)) &&
        eligible(index - 1)) {
      return (ladder.steps[index - 1].moveId, CalLadderChange.regressed);
    }
    return (state, hold);
  }

  static WorkoutEntryEntity _entryOf(
    WorkoutEntryEntity entry,
    String moveId,
    CalLadderChange change,
    CalSlot slot,
    CalEntryKey key,
    CalSlotHistory slotHistory,
    Map<String, ExerciseCatalogEntry> catalog,
    List<String> reasons,
  ) {
    final exercise = CalisthenicsPlanMapper.exerciseOf(moveId, catalog);
    if (exercise == null) return entry;
    final swapped = moveId != entry.exerciseId;
    switch (change) {
      case CalLadderChange.advanced:
        reasons.add(
          'Level up: ${exercise.name} is your new variation — you met the '
          'standard two sessions in a row.',
        );
      case CalLadderChange.regressed:
        reasons.add(
          'Stepping back to ${exercise.name} for now — build the base range, '
          'then move up again.',
        );
      case CalLadderChange.none:
        break;
    }
    final target = _targetOf(slot, exercise, slotHistory.of(moveId));
    if (!swapped && target > entry.targetReps) {
      reasons.add(
        '${exercise.name}: aim for $target ${slot.unit.label} — you hit '
        'every set last time.',
      );
    }
    final base = swapped
        ? WorkoutEntryEntity.fromCatalog(
            exercise,
            id: key.idFor(moveId),
            section: entry.section,
            sets: entry.targetSets,
            reps: target,
            restSeconds: entry.restSeconds,
            repsInReserve: entry.repsInReserve,
          )
        : entry.copyWith(targetReps: target);
    return swapped
        ? base.copyWith(
            guidelines: [
              for (final cue in entry.guidelines)
                if (cue.label != null) cue,
              ...exercise.guidelines,
            ],
          )
        : base;
  }

  static int _targetOf(
    CalSlot slot,
    ExerciseCatalogEntry exercise,
    List<WorkoutEntryEntity> moveHistory,
  ) {
    final start = CalisthenicsPlanMapper.targetOf(slot, exercise);
    if (slot.unit.isTimed != exercise.isTimed || moveHistory.isEmpty) {
      return start;
    }
    final last = moveHistory.first;
    final base = last.targetReps.clamp(slot.min, slot.max);
    if (!hitTarget(last)) return base;
    final step = slot.unit.isTimed
        ? ((slot.max - slot.min) / _timedSteps).round().clamp(1, slot.max)
        : _repStep;
    return (base + step).clamp(slot.min, slot.max);
  }

  static WorkoutEntryEntity _withReadiness(
    WorkoutEntryEntity entry,
    WorkoutReadiness readiness,
  ) {
    if (!readiness.isLow) return entry;
    return entry.copyWith(
      targetSets: entry.targetSets > _minSets
          ? entry.targetSets - 1
          : entry.targetSets,
      repsInReserve: entry.repsInReserve + 1,
    );
  }
}
