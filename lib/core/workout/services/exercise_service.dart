import 'package:floww/core/workout/models/exercise.dart';

class ExerciseService {
  const ExerciseService();

  static const _catalog = [
    Exercise(
      id: 'barbell-bench-press',
      name: 'Barbell Bench Press',
      group: MuscleGroup.chest,
      equipment: Equipment.barbell,
      isAdded: true,
    ),
    Exercise(
      id: 'incline-db-press',
      name: 'Incline DB Press',
      group: MuscleGroup.chest,
      equipment: Equipment.dumbbell,
    ),
    Exercise(
      id: 'chest-flyes',
      name: 'Chest Flyes',
      group: MuscleGroup.chest,
      equipment: Equipment.cable,
      isCustom: true,
      isAdded: true,
    ),
    Exercise(
      id: 'pull-up',
      name: 'Pull Up',
      group: MuscleGroup.back,
      equipment: Equipment.bodyweight,
    ),
    Exercise(
      id: 'barbell-row',
      name: 'Barbell Row',
      group: MuscleGroup.back,
      equipment: Equipment.barbell,
    ),
    Exercise(
      id: 'lat-pulldown',
      name: 'Lat Pulldown',
      group: MuscleGroup.back,
      equipment: Equipment.cable,
    ),
    Exercise(
      id: 'seated-cable-row',
      name: 'Seated Cable Row',
      group: MuscleGroup.back,
      equipment: Equipment.cable,
    ),
    Exercise(
      id: 'face-pull',
      name: 'Face Pull',
      group: MuscleGroup.back,
      equipment: Equipment.cable,
    ),
    Exercise(
      id: 'back-squat',
      name: 'Back Squat',
      group: MuscleGroup.legs,
      equipment: Equipment.barbell,
    ),
    Exercise(
      id: 'romanian-deadlift',
      name: 'Romanian Deadlift',
      group: MuscleGroup.legs,
      equipment: Equipment.barbell,
    ),
    Exercise(
      id: 'leg-press',
      name: 'Leg Press',
      group: MuscleGroup.legs,
      equipment: Equipment.machine,
    ),
    Exercise(
      id: 'walking-lunge',
      name: 'Walking Lunge',
      group: MuscleGroup.legs,
      equipment: Equipment.dumbbell,
    ),
    Exercise(
      id: 'calf-raise',
      name: 'Calf Raise',
      group: MuscleGroup.legs,
      equipment: Equipment.machine,
    ),
    Exercise(
      id: 'overhead-press',
      name: 'Overhead Press',
      group: MuscleGroup.shoulders,
      equipment: Equipment.barbell,
    ),
    Exercise(
      id: 'lateral-raise',
      name: 'Lateral Raise',
      group: MuscleGroup.shoulders,
      equipment: Equipment.dumbbell,
    ),
    Exercise(
      id: 'barbell-curl',
      name: 'Barbell Curl',
      group: MuscleGroup.arms,
      equipment: Equipment.barbell,
    ),
    Exercise(
      id: 'triceps-pushdown',
      name: 'Triceps Pushdown',
      group: MuscleGroup.arms,
      equipment: Equipment.cable,
    ),
    Exercise(
      id: 'plank',
      name: 'Plank',
      group: MuscleGroup.core,
      equipment: Equipment.bodyweight,
    ),
    Exercise(
      id: 'hanging-leg-raise',
      name: 'Hanging Leg Raise',
      group: MuscleGroup.core,
      equipment: Equipment.bodyweight,
    ),
    Exercise(
      id: 'rowing-machine',
      name: 'Rowing Machine',
      group: MuscleGroup.cardio,
      equipment: Equipment.machine,
    ),
  ];

  List<Exercise> loadCatalog() => _catalog;
}
