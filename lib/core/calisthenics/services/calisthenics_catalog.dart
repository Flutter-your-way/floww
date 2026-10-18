import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/core/calisthenics/data/calisthenics_moves_data.dart';
import 'package:floww/core/calisthenics/data/calisthenics_program_data.dart';
import 'package:floww/core/calisthenics/models/cal_gear.dart';
import 'package:floww/core/calisthenics/models/cal_level.dart';
import 'package:floww/core/calisthenics/models/cal_move.dart';
import 'package:floww/core/workout/models/exercise.dart';
import 'package:floww/core/workout/models/program_goal.dart';
import 'package:floww/core/workout/models/set_type.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';

class CalisthenicsCatalog {
  CalisthenicsCatalog._();

  static const int _defaultSets = 3;
  static const int _defaultReps = 8;
  static const int _defaultSeconds = 20;
  static const int _defaultRest = 90;
  static const int _defaultReserve = 2;

  static final List<ExerciseCatalogEntry> entries = [
    for (final move in CalisthenicsMovesData.all) _entryOf(move),
  ];

  static final Map<String, ExerciseCatalogEntry> _byId = {
    for (final entry in entries) entry.id: entry,
  };

  static ExerciseCatalogEntry? entryOf(String id) => _byId[id];

  static const Map<String, int> _weekdays = {
    'Mon': DateTime.monday,
    'Tue': DateTime.tuesday,
    'Wed': DateTime.wednesday,
    'Thu': DateTime.thursday,
    'Fri': DateTime.friday,
    'Sat': DateTime.saturday,
    'Sun': DateTime.sunday,
  };

  static final List<WorkoutProgramEntity> programs = [
    for (final level in CalLevel.values) programOf(level),
  ];

  static WorkoutProgramEntity programOf(CalLevel level) =>
      WorkoutProgramEntity(
        id: level.courseId,
        goal: ProgramGoal.home,
        name: 'Calisthenics ${level.fullTitle}',
        description:
            '${level.weeks} weeks · ${level.sessions} days/wk · '
            '${level.minuteRange}. ${level.goal}',
        level: level.experience,
        weeks: level.weeks,
        lengthDays: level.lengthDays,
        course: level.courseId,
        days: [
          for (final session in CalisthenicsProgramData.sessionsOf(level))
            ProgramDayEntry(
              weekday: _weekdays[session.day] ?? DateTime.monday,
              name: session.name,
              focus: session.focus,
              goal: session.goal,
              durationMinutes: level.minutes,
              exercises: [
                for (final slot in CalisthenicsProgramData.warmUp.take(1))
                  ProgramExerciseEntry(
                    exerciseId: slot.moveId,
                    section: WorkoutSectionKind.warmUp,
                  ),
                for (final slot in session.slots)
                  ProgramExerciseEntry(
                    exerciseId: slot.moveId,
                    section: WorkoutSectionKind.main,
                    sets: slot.sets,
                    reps: slot.min,
                    restSeconds: slot.rest,
                  ),
                for (final slot in CalisthenicsProgramData.coolDown.reversed
                    .take(1))
                  ProgramExerciseEntry(
                    exerciseId: slot.moveId,
                    section: WorkoutSectionKind.coolDown,
                  ),
              ],
            ),
        ],
      );

  static ExerciseCatalogEntry _entryOf(CalMove move) => ExerciseCatalogEntry(
    id: move.id,
    name: move.name,
    group: move.group,
    equipment: move.gear.length == 1 && move.gear.contains(CalGear.bands)
        ? Equipment.band
        : Equipment.bodyweight,
    met: move.met,
    muscleShares: move.shares,
    defaultSets: _defaultSets,
    defaultReps: move.isTimed ? _defaultSeconds : _defaultReps,
    defaultRestSeconds: _defaultRest,
    defaultRepsInReserve: _defaultReserve,
    trackingMode: move.isTimed ? TrackingMode.duration : TrackingMode.reps,
    isPool: true,
    mistakes: [for (final text in move.mistakes) ExerciseCueEntry(text: text)],
    guidelines: [
      for (final text in move.guidelines) ExerciseCueEntry(text: text),
    ],
    equipmentItems: [
      if (move.kit case final kit?) ExerciseCueEntry(label: 'Kit', text: kit),
    ],
  );
}
