enum MuscleBodySide {
  front,
  back;

  String get label => switch (this) {
    MuscleBodySide.front => 'Front',
    MuscleBodySide.back => 'Back',
  };
}
