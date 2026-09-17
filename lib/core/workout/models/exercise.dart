enum MuscleGroup {
  chest('Chest'),
  back('Back'),
  legs('Legs'),
  shoulders('Shoulders'),
  arms('Arms'),
  core('Core'),
  cardio('Cardio'),
  other('Other');

  const MuscleGroup(this.label);

  final String label;
}

enum Equipment {
  barbell('Barbell'),
  dumbbell('Dumbbell'),
  machine('Machine'),
  cable('Cable'),
  bodyweight('Bodyweight'),
  kettlebell('Kettlebell'),
  band('Band');

  const Equipment(this.label);

  final String label;
}
