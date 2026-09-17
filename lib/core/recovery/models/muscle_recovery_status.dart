enum MuscleRecoveryStatus {
  ready,
  recovering,
  fatigued;

  static const int _readyFloor = 75;
  static const int _recoveringFloor = 35;

  static MuscleRecoveryStatus fromPercent(int percent) {
    if (percent >= _readyFloor) return MuscleRecoveryStatus.ready;
    if (percent >= _recoveringFloor) return MuscleRecoveryStatus.recovering;
    return MuscleRecoveryStatus.fatigued;
  }

  String get label => switch (this) {
    MuscleRecoveryStatus.ready => 'Ready',
    MuscleRecoveryStatus.recovering => 'In Recovery',
    MuscleRecoveryStatus.fatigued => 'Fatigued',
  };

  String get summaryLabel => switch (this) {
    MuscleRecoveryStatus.ready => 'Ready Muscles',
    MuscleRecoveryStatus.recovering => 'In Recovery',
    MuscleRecoveryStatus.fatigued => 'Fatigued',
  };
}
