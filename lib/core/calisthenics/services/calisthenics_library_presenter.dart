import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/core/calisthenics/data/calisthenics_ladders_data.dart';
import 'package:floww/core/calisthenics/data/calisthenics_program_data.dart';
import 'package:floww/core/calisthenics/models/cal_level.dart';
import 'package:floww/core/calisthenics/models/cal_library_view_data.dart';
import 'package:floww/core/calisthenics/models/cal_slot.dart';
import 'package:floww/core/calisthenics/services/calisthenics_plan_mapper.dart';
import 'package:floww/core/workout/services/workout_catalog_data.dart';

class CalisthenicsLibraryPresenter {
  CalisthenicsLibraryPresenter._();

  static const Map<String, ExerciseCatalogEntry> _noCatalog = {};

  static const int _maxSearchQueries = 3;

  static const Map<String, List<String>> _searchFallbacks = {
    'pseudo-planche-push-up': ['Planche Push-Up', 'Pseudo Planche'],
    'planche-lean': ['Pseudo Planche', 'Planche'],
    'tuck-planche': ['Planche'],
    'adv-tuck-planche': ['Tuck Planche', 'Planche'],
    'straddle-planche': ['Planche'],
    'full-planche': ['Planche'],
    'tuck-front-lever': ['Front Lever'],
    'adv-tuck-front-lever': ['Tuck Front Lever', 'Front Lever'],
    'straddle-human-flag': ['Human Flag'],
    'assisted-pistol-squat': ['Pistol Squat', 'Box Pistol Squat'],
    'parallel-bar-dip': ['Dips', 'Chest Dip'],
    'straddle-front-lever': ['Front Lever'],
    'full-front-lever': ['Front Lever'],
    'tuck-back-lever': ['Back Lever'],
    'tuck-human-flag': ['Human Flag'],
    'wall-handstand': ['Wall Handstand', 'Handstand'],
    'freestanding-handstand': ['Handstand'],
    'wall-hspu': ['Handstand Push-Up'],
    'wall-hspu-negative': ['Handstand Push-Up'],
    'deficit-hspu': ['Handstand Push-Up'],
    'freestanding-hspu': ['Handstand Push-Up'],
    'elevated-pike-push-up': ['Pike Push-Up'],
    'dragon-flag-negative': ['Dragon Flag'],
    'nordic-curl-negative': ['Nordic Curl'],
    'weighted-nordic-curl': ['Nordic Curl'],
    'nordic-curl': ['Nordic Curl'],
    'tuck-l-sit': ['L-Sit'],
    'hollow-body-hold': ['Hollow Hold'],
    'tuck-hollow-hold': ['Hollow Hold'],
    'one-arm-chin-up': ['One-Arm Chin-Up', 'Chin-Up'],
    'dead-hang': ['Dead Hang'],
    'bent-knee-inverted-row': ['Inverted Row'],
    'feet-elevated-row': ['Inverted Row'],
    'incline-row': ['Inverted Row'],
    'dip-negative': ['Dip'],
    'weighted-dip': ['Dip'],
    'ring-dip': ['Dip'],
    'band-assisted-pull-up': ['Assisted Pull-Up', 'Pull-Up'],
    'negative-pull-up': ['Pull-Up'],
    'weighted-pull-up': ['Pull-Up'],
  };

  static List<String> searchQueriesOf(String moveId, {String? name}) => [
    name ?? nameOf(moveId),
    ...?_searchFallbacks[moveId],
  ].take(_maxSearchQueries).toList();

  static String nameOf(String moveId) =>
      CalisthenicsPlanMapper.exerciseOf(moveId, _noCatalog)?.name ?? moveId;

  static List<String> get ladderMoveIds => [
    for (final ladder in CalisthenicsLaddersData.all)
      for (final step in ladder.steps) step.moveId,
  ];

  static List<CalLadderItem> laddersOf(
    CalLevel level, {
    Map<String, String> thumbnails = const {},
    Set<String> loadingIds = const {},
  }) => [
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
              imageUrl:
                  thumbnails[step.moveId] ??
                  WorkoutCatalogData.imageFor(step.moveId),
              isImageLoading: loadingIds.contains(step.moveId),
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
  ];

  static List<String> get safety => CalisthenicsProgramData.safety;
}
