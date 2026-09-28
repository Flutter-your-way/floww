class ProgramStartSetup {
  const ProgramStartSetup({
    required this.programId,
    required this.name,
    required this.dayWeekdays,
    required this.weeks,
  });

  final String programId;
  final String name;
  final List<int> dayWeekdays;
  final int weeks;

  int get sessionsPerWeek => dayWeekdays.length;
}

class ProgramStartConfig {
  const ProgramStartConfig({
    required this.weekdays,
    required this.weeks,
    required this.startDate,
  });

  final List<int> weekdays;
  final int weeks;
  final DateTime startDate;
}

class ProgramEditorArgs {
  const ProgramEditorArgs({this.programId, this.editExisting = false});

  final String? programId;
  final bool editExisting;
}
