class ProgramStartSetup {
  const ProgramStartSetup({
    required this.programId,
    required this.name,
    required this.dayWeekdays,
    required this.weeks,
    this.lengthDays = 0,
  });

  final String programId;
  final String name;
  final List<int> dayWeekdays;
  final int weeks;
  final int lengthDays;

  bool get hasFixedLength => lengthDays > 0;

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
