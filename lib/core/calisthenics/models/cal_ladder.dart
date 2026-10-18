class CalLadderStep {
  const CalLadderStep(
    this.moveId,
    this.level, {
    this.sets,
    this.value,
    this.isTimed = false,
    this.isPerSide = false,
  });

  final String moveId;
  final int level;
  final int? sets;
  final int? value;
  final bool isTimed;
  final bool isPerSide;

  bool get hasStandard => sets != null && value != null;

  String get standard {
    final count = sets;
    final target = value;
    if (count == null || target == null) return 'Skill goal';
    final unit = isTimed ? 's' : '';
    return '$count×$target$unit${isPerSide ? '/side' : ''}';
  }
}

class CalLadder {
  const CalLadder({required this.id, required this.name, required this.steps});

  final String id;
  final String name;
  final List<CalLadderStep> steps;

  int indexOf(String moveId) =>
      steps.indexWhere((step) => step.moveId == moveId);
}
