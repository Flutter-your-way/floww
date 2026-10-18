enum CalBlock {
  skill('Skill', isFresh: true),
  power('Power', isFresh: true),
  strength('Strength'),
  accessory('Accessory'),
  prehab('Prehab'),
  core('Core');

  const CalBlock(this.label, {this.isFresh = false});

  final String label;
  final bool isFresh;
}

enum CalPattern {
  push('Push'),
  pull('Pull'),
  legs('Legs'),
  core('Core'),
  skill('Skill'),
  prep('Prep');

  const CalPattern(this.label);

  final String label;

  bool get countsTowardVolume => this != skill && this != prep;
}

enum CalUnit {
  reps('reps'),
  repsPerSide('reps/side', isPerSide: true),
  seconds('s', isTimed: true),
  secondsPerSide('s/side', isTimed: true, isPerSide: true);

  const CalUnit(this.label, {this.isTimed = false, this.isPerSide = false});

  final String label;
  final bool isTimed;
  final bool isPerSide;
}

class CalEntryRule {
  const CalEntryRule({
    required this.testId,
    required this.below,
    required this.moveId,
  });

  final String testId;
  final double below;
  final String moveId;
}

class CalSlot {
  const CalSlot(
    this.moveId, {
    required this.block,
    required this.pattern,
    required this.sets,
    required this.min,
    required this.max,
    required this.unit,
    required this.rest,
    required this.intensity,
    required this.rule,
    this.ladderId,
    this.entryRule,
  });

  final String moveId;
  final CalBlock block;
  final CalPattern pattern;
  final int sets;
  final int min;
  final int max;
  final CalUnit unit;
  final int rest;
  final String intensity;
  final String rule;
  final String? ladderId;
  final CalEntryRule? entryRule;

  String get range => min == max ? '$min' : '$min–$max';

  String prescriptionFor(int sets) => '$sets × $range ${unit.label}';
}
