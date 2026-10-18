class CalWeek {
  const CalWeek(
    this.number,
    this.phase,
    this.multiplier,
    this.effort,
    this.reserve,
    this.note, {
    this.isDeload = false,
    this.isRetest = false,
  });

  static const int _minSets = 1;

  final int number;
  final String phase;
  final double multiplier;
  final String effort;
  final int reserve;
  final String note;
  final bool isDeload;
  final bool isRetest;

  int setsFor(int sets) {
    final scaled = (sets * multiplier).round();
    return scaled < _minSets ? _minSets : scaled;
  }

  int get percent => (multiplier * 100).round();
}
