class WorkoutProgram {
  const WorkoutProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.weeks,
    required this.sessionsPerWeek,
  });

  final String id;
  final String name;
  final String description;
  final String level;
  final int weeks;
  final int sessionsPerWeek;
}

class ActiveProgram {
  const ActiveProgram({
    required this.id,
    required this.name,
    required this.level,
    required this.currentWeek,
    required this.totalWeeks,
    required this.daysPerWeek,
  });

  final String id;
  final String name;
  final String level;
  final int currentWeek;
  final int totalWeeks;
  final int daysPerWeek;
}
