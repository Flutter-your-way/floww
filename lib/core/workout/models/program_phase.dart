enum ProgramPhase {
  foundation('Foundation', reserveDelta: 1),
  build('Build'),
  peak('Peak', setDelta: 1),
  deload('Deload', isDeload: true);

  const ProgramPhase(
    this.label, {
    this.setDelta = 0,
    this.reserveDelta = 0,
    this.isDeload = false,
  });

  static const int _peakWeek = 4;
  static const int _deloadFromWeeks = 5;
  static const int peakLifts = 2;

  final String label;
  final int setDelta;
  final int reserveDelta;
  final bool isDeload;

  static ProgramPhase of(int week, int totalWeeks) {
    if (totalWeeks >= _deloadFromWeeks && week >= totalWeeks) return deload;
    if (week <= 1) return foundation;
    if (week >= _peakWeek) return peak;
    return build;
  }

  String insightOf({
    required String programName,
    required String dayName,
    required String focus,
    required int day,
    required int totalDays,
  }) => switch (this) {
    ProgramPhase.foundation =>
      'Day $day of $totalDays — Foundation week of $programName. $dayName '
          'keeps an extra rep in reserve so you can lock in technique on '
          '${focus.toLowerCase()} before the load climbs.',
    ProgramPhase.build =>
      'Day $day of $totalDays — Build phase. Beat last week on $dayName by a '
          'rep or a small jump in weight while keeping the target reps in '
          'reserve.',
    ProgramPhase.peak =>
      'Day $day of $totalDays — Peak week. WAVE added a set to your first '
          'two main lifts. Push hard, but stop each set with clean form.',
    ProgramPhase.deload =>
      'Day $day of $totalDays — Deload to finish your 30 days. Volume drops '
          'to about 60% so your body absorbs the block. Move well and leave '
          'fresh.',
  };
}
