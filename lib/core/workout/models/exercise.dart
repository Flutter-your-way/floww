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

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.group,
    required this.equipment,
    this.isCustom = false,
    this.isAdded = false,
  });

  final String id;
  final String name;
  final MuscleGroup group;
  final Equipment equipment;
  final bool isCustom;
  final bool isAdded;

  Exercise copyWith({bool? isAdded}) => Exercise(
    id: id,
    name: name,
    group: group,
    equipment: equipment,
    isCustom: isCustom,
    isAdded: isAdded ?? this.isAdded,
  );
}
