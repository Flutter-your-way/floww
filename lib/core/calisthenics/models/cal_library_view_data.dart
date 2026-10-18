class CalLadderStepItem {
  const CalLadderStepItem({
    required this.moveId,
    required this.name,
    required this.levelLabel,
    required this.standard,
    required this.isYourLevel,
  });

  final String moveId;
  final String name;
  final String levelLabel;
  final String standard;
  final bool isYourLevel;
}

class CalLadderItem {
  const CalLadderItem({required this.name, required this.steps});

  final String name;
  final List<CalLadderStepItem> steps;
}

class CalRoutineItem {
  const CalRoutineItem({
    required this.moveId,
    required this.name,
    required this.detail,
  });

  final String moveId;
  final String name;
  final String detail;
}
