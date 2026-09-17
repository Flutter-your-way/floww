import 'package:floww/core/recovery/models/muscle_body_side.dart';

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  quadriceps,
  glutes,
  hamstrings,
  calves,
  abdominals,
  adductors,
  traps;

  String get label => switch (this) {
    MuscleGroup.chest => 'Chest',
    MuscleGroup.back => 'Back',
    MuscleGroup.shoulders => 'Shoulders',
    MuscleGroup.biceps => 'Biceps',
    MuscleGroup.triceps => 'Triceps',
    MuscleGroup.quadriceps => 'Quadriceps',
    MuscleGroup.glutes => 'Glutes',
    MuscleGroup.hamstrings => 'Hamstrings',
    MuscleGroup.calves => 'Calves',
    MuscleGroup.abdominals => 'Abdominals',
    MuscleGroup.adductors => 'Adductors',
    MuscleGroup.traps => 'Traps',
  };

  MuscleBodySide get primarySide => switch (this) {
    MuscleGroup.chest ||
    MuscleGroup.biceps ||
    MuscleGroup.quadriceps ||
    MuscleGroup.abdominals ||
    MuscleGroup.adductors => MuscleBodySide.front,
    MuscleGroup.back ||
    MuscleGroup.shoulders ||
    MuscleGroup.triceps ||
    MuscleGroup.glutes ||
    MuscleGroup.hamstrings ||
    MuscleGroup.calves ||
    MuscleGroup.traps => MuscleBodySide.back,
  };
}
