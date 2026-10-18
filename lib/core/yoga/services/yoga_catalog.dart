import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/core/workout/models/exercise.dart';
import 'package:floww/core/workout/models/set_type.dart';
import 'package:floww/core/yoga/data/yoga_postures_data.dart';
import 'package:floww/core/yoga/models/yoga_posture.dart';

class YogaCatalog {
  YogaCatalog._();

  static const int _defaultSets = 1;
  static const int _transitionSeconds = 10;
  static const int _reserve = 4;

  static final List<ExerciseCatalogEntry> entries = [
    for (final posture in YogaPosturesData.all) _entryOf(posture),
  ];

  static final Map<String, ExerciseCatalogEntry> _byId = {
    for (final entry in entries) entry.id: entry,
  };

  static ExerciseCatalogEntry? entryOf(String id) => _byId[id];

  static ExerciseCatalogEntry _entryOf(YogaPosture posture) =>
      ExerciseCatalogEntry(
        id: posture.id,
        name: posture.name,
        group: MuscleGroup.other,
        equipment: Equipment.bodyweight,
        met: posture.met,
        muscleShares: posture.muscleShares,
        defaultSets: posture.isPerSide ? 2 : _defaultSets,
        defaultReps: posture.holdSeconds,
        defaultRestSeconds: _transitionSeconds,
        defaultRepsInReserve: _reserve,
        trackingMode: TrackingMode.duration,
        imageUrl: posture.imageUrl,
        isPool: true,
        mistakes: [for (final text in posture.avoid) ExerciseCueEntry(text: text)],
        guidelines: [
          for (final text in posture.alignmentCues) ExerciseCueEntry(text: text),
        ],
        equipmentItems: [
          for (final prop in posture.props)
            ExerciseCueEntry(label: prop.label, text: prop.text),
        ],
      );
}
