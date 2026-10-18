import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/calisthenics/data/calisthenics_moves_data.dart';
import 'package:floww/core/calisthenics/data/calisthenics_program_data.dart';
import 'package:floww/core/calisthenics/models/cal_entry_key.dart';
import 'package:floww/core/calisthenics/models/cal_gear.dart';
import 'package:floww/core/calisthenics/models/cal_level.dart';
import 'package:floww/core/calisthenics/models/cal_session.dart';
import 'package:floww/core/calisthenics/models/cal_slot.dart';
import 'package:floww/core/calisthenics/models/cal_week.dart';
import 'package:floww/core/calisthenics/models/calisthenics_profile.dart';
import 'package:floww/core/calisthenics/services/calisthenics_catalog.dart';
import 'package:floww/core/workout/services/workout_catalog_data.dart';

class CalisthenicsPlanMapper {
  CalisthenicsPlanMapper._();

  static const int _prepReserve = 4;
  static const int _maxSwapNotes = 3;

  static final Map<String, ExerciseCatalogEntry> _builtIn = {
    for (final exercise in WorkoutCatalogData.exercises) exercise.id: exercise,
  };

  static bool isCourse(String? course) => CalLevel.fromCourse(course) != null;

  static bool isPlan(WorkoutPlanEntity plan) =>
      plan.exercises.isNotEmpty &&
      plan.exercises.every((entry) => CalEntryKey.parse(entry.id) != null);

  static ExerciseCatalogEntry? exerciseOf(
    String id,
    Map<String, ExerciseCatalogEntry> catalog,
  ) => catalog[id] ?? CalisthenicsCatalog.entryOf(id) ?? _builtIn[id];

  static String? resolveMove(String moveId, Set<CalGear> gear) {
    final visited = <String>{};
    String? current = moveId;
    while (current != null) {
      if (!visited.add(current)) return null;
      final rule = CalisthenicsMovesData.ruleOf(current);
      if (rule.isMetBy(gear)) return current;
      current = rule.fallbackId;
    }
    return null;
  }

  static String startMoveOf(CalSlot slot, CalisthenicsProfile profile) {
    final entry = slot.entryRule;
    if (entry != null) {
      final result = profile.results[entry.testId];
      if (result != null && result < entry.below) return entry.moveId;
    }
    return slot.moveId;
  }

  static int targetOf(CalSlot slot, ExerciseCatalogEntry exercise) =>
      slot.unit.isTimed == exercise.isTimed ? slot.min : exercise.defaultReps;

  static int sessionIndexOf(
    WorkoutProgramEntity program,
    ProgramDayEntry day,
    CalLevel level,
  ) {
    final sessions = CalisthenicsProgramData.sessionsOf(level);
    final byName = sessions.indexWhere((session) => session.name == day.name);
    if (byName >= 0) return byName;
    final position = program.days.indexOf(day);
    return (position < 0 ? 0 : position) % sessions.length;
  }

  static List<ExerciseCueEntry> cuesOf(
    CalSlot slot,
    int sets,
    CalEntryKind kind,
    CalWeek week,
  ) {
    if (kind != CalEntryKind.main) {
      return [
        ExerciseCueEntry(
          label: kind == CalEntryKind.warmUp ? 'Warm-up' : 'Cooldown',
          text: '${slot.intensity} · ${slot.rule}',
        ),
      ];
    }
    return [
      ExerciseCueEntry(
        label: slot.block.label,
        text: '${slot.prescriptionFor(sets)} · rest ${slot.rest} s',
      ),
      ExerciseCueEntry(
        label: 'Effort',
        text: '${week.effort} this week · ${slot.intensity}',
      ),
      ExerciseCueEntry(label: 'Move up', text: slot.rule),
      if (slot.block.isFresh)
        const ExerciseCueEntry(
          label: 'Fresh',
          text: 'Do this early and stop before your form breaks.',
        ),
    ];
  }

  static WorkoutEntryEntity entryOf({
    required ExerciseCatalogEntry exercise,
    required CalEntryKey key,
    required CalSlot slot,
    required CalWeek week,
    int? target,
  }) {
    final sets = key.kind == CalEntryKind.main
        ? week.setsFor(slot.sets)
        : slot.sets;
    final entry = WorkoutEntryEntity.fromCatalog(
      exercise,
      id: key.idFor(exercise.id),
      section: key.kind.section,
      sets: sets,
      reps: target ?? targetOf(slot, exercise),
      restSeconds: slot.rest,
      repsInReserve: key.kind == CalEntryKind.main
          ? week.reserve
          : _prepReserve,
    );
    return entry.copyWith(
      guidelines: [
        ...cuesOf(slot, sets, key.kind, week),
        ...exercise.guidelines,
      ],
    );
  }

  static WorkoutPlanEntity? planOf({
    required DateTime date,
    required ProgramDayEntry day,
    required WorkoutProgramEntity program,
    required ActiveProgramEntry activeProgram,
    required Map<String, ExerciseCatalogEntry> catalog,
    required CalisthenicsProfile profile,
  }) {
    final level = CalLevel.fromCourse(program.course);
    if (level == null) return null;
    final sessionIndex = sessionIndexOf(program, day, level);
    final session = CalisthenicsProgramData.sessionsOf(level)[sessionIndex];
    final weekNumber = activeProgram.weekAt(date).clamp(1, level.weeks);
    final week = CalisthenicsProgramData.weekOf(level, weekNumber);
    final swaps = <String>[];
    final entries = <WorkoutEntryEntity>[];

    void addAll(CalEntryKind kind, List<CalSlot> slots) {
      final used = <String>{};
      for (var index = 0; index < slots.length; index++) {
        final slot = slots[index];
        final wanted = startMoveOf(slot, profile);
        final moveId = resolveMove(wanted, profile.gear);
        if (moveId == null || used.contains(moveId)) continue;
        final exercise = exerciseOf(moveId, catalog);
        if (exercise == null) continue;
        used.add(moveId);
        if (moveId != wanted && kind == CalEntryKind.main) {
          final from = exerciseOf(wanted, catalog)?.name ?? wanted;
          swaps.add('$from → ${exercise.name}');
        }
        entries.add(
          entryOf(
            exercise: exercise,
            key: CalEntryKey(
              level: level,
              session: sessionIndex,
              kind: kind,
              index: index,
            ),
            slot: slot,
            week: week,
          ),
        );
      }
    }

    addAll(CalEntryKind.warmUp, CalisthenicsProgramData.warmUp);
    addAll(CalEntryKind.main, session.slots);
    addAll(CalEntryKind.coolDown, CalisthenicsProgramData.coolDown);
    if (!entries.any((entry) => CalEntryKey.parse(entry.id)?.kind ==
        CalEntryKind.main)) {
      return null;
    }

    return WorkoutPlanEntity(
      id: '${program.id}-${AppDateUtils.dateKey(date)}',
      date: AppDateUtils.dateOnly(date),
      name: session.name,
      focus: session.focus,
      goal: session.goal,
      insight: insightOf(level, week, session, swaps),
      durationMinutes: level.minutes,
      exercises: entries,
      programId: program.id,
      programLabel:
          '${level.fullTitle} · Week ${week.number} of ${level.weeks} · '
          '${week.phase}',
      isDeload: week.isDeload,
    );
  }

  static String insightOf(
    CalLevel level,
    CalWeek week,
    CalSession session,
    List<String> swaps,
  ) {
    final next = level.next;
    return [
      'Week ${week.number} of ${level.weeks} — ${week.phase} '
          '(${week.effort}, ${week.percent}% volume). ${week.note}',
      if (session.slots.any((slot) => slot.block.isFresh))
        CalisthenicsProgramData.freshNote,
      CalisthenicsProgramData.ramp,
      if (session.isSkillDay) CalisthenicsProgramData.skillPrimer,
      if (week.isRetest)
        next == null
            ? 'Retest week: retake your placement test at the end of the '
                  'week, then rotate your skill priorities for the next block.'
            : 'Retest week: retake your placement test at the end of the '
                  'week. Clear 80% of the ${next.label} gates to move up.',
      if (swaps.isNotEmpty)
        'Matched to your equipment: ${swaps.take(_maxSwapNotes).join(', ')}.',
    ].join('\n\n');
  }
}
