enum MuscleEmphasis {
  primary,
  secondary;

  String get label => switch (this) {
    MuscleEmphasis.primary => 'Primary',
    MuscleEmphasis.secondary => 'Secondary',
  };
}
