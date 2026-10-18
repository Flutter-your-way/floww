import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/core/calisthenics/data/calisthenics_ladders_data.dart';
import 'package:floww/core/calisthenics/data/calisthenics_program_data.dart';
import 'package:floww/core/calisthenics/models/cal_level.dart';
import 'package:floww/core/calisthenics/models/cal_library_view_data.dart';
import 'package:floww/core/calisthenics/models/cal_slot.dart';
import 'package:floww/core/calisthenics/services/calisthenics_plan_mapper.dart';

class CalisthenicsLibraryPresenter {
  CalisthenicsLibraryPresenter._();

  static const Map<String, ExerciseCatalogEntry> _noCatalog = {};

  static String nameOf(String moveId) =>
      CalisthenicsPlanMapper.exerciseOf(moveId, _noCatalog)?.name ?? moveId;

  static List<CalLadderItem> laddersOf(CalLevel level) => [
    for (final ladder in CalisthenicsLaddersData.all)
      CalLadderItem(
        name: ladder.name,
        steps: [
          for (final step in ladder.steps)
            CalLadderStepItem(
              moveId: step.moveId,
              name: nameOf(step.moveId),
              levelLabel: 'L${step.level}',
              standard: step.standard,
              isYourLevel: step.level == level.number,
            ),
        ],
      ),
  ];

  static List<CalRoutineItem> routineOf(List<CalSlot> slots) => [
    for (final slot in slots)
      CalRoutineItem(
        moveId: slot.moveId,
        name: nameOf(slot.moveId),
        detail: '${slot.intensity}. ${slot.rule}',
      ),
  ];

  static List<CalRoutineItem> get warmUp =>
      routineOf(CalisthenicsProgramData.warmUp);

  static List<CalRoutineItem> get coolDown =>
      routineOf(CalisthenicsProgramData.coolDown);

  static List<String> get principles => [
    CalisthenicsProgramData.freshNote,
    CalisthenicsProgramData.ramp,
    CalisthenicsProgramData.skillPrimer,
    ...CalisthenicsProgramData.safety,
  ];
}
