class MuscleActivation {
  const MuscleActivation({required this.name, required this.share});

  final String name;
  final double share;
}

class PersonalRecord {
  const PersonalRecord({
    required this.glyph,
    required this.exercise,
    required this.improvement,
  });

  final String glyph;
  final String exercise;
  final String improvement;
}

class WorkoutHistoryEntry {
  const WorkoutHistoryEntry({
    required this.id,
    required this.name,
    required this.performedAt,
    required this.durationSeconds,
    required this.calories,
    required this.exerciseCount,
    required this.trainingEffect,
    required this.isCompleted,
  });

  final String id;
  final String name;
  final DateTime performedAt;
  final int durationSeconds;
  final int calories;
  final int exerciseCount;
  final double trainingEffect;
  final bool isCompleted;
}

class WorkoutSession {
  const WorkoutSession({
    required this.name,
    required this.exerciseCount,
    required this.flowPoints,
    required this.isCompleted,
    required this.durationSeconds,
    required this.volumeKg,
    required this.calories,
    required this.averageHeartRate,
    required this.peakHeartRate,
    required this.heartRateZone,
    required this.heartRateZoneCount,
    required this.heartRateSamples,
    required this.trainingEffect,
    required this.trainingEffectRating,
    required this.trainingEffectSummary,
    required this.trainingEffectScale,
    required this.recoveryHours,
    required this.muscleRecoveryMinHours,
    required this.muscleRecoveryMaxHours,
    required this.muscleActivation,
    required this.newPersonalRecords,
    required this.exercisesCompleted,
    required this.totalSets,
    required this.totalReps,
    required this.personalRecords,
  });

  final String name;
  final int exerciseCount;
  final int flowPoints;
  final bool isCompleted;
  final int durationSeconds;
  final int volumeKg;
  final int calories;
  final int averageHeartRate;
  final int peakHeartRate;
  final int heartRateZone;
  final int heartRateZoneCount;
  final List<int> heartRateSamples;
  final double trainingEffect;
  final String trainingEffectRating;
  final String trainingEffectSummary;
  final double trainingEffectScale;
  final int recoveryHours;
  final int muscleRecoveryMinHours;
  final int muscleRecoveryMaxHours;
  final List<MuscleActivation> muscleActivation;
  final int newPersonalRecords;
  final int exercisesCompleted;
  final int totalSets;
  final int totalReps;
  final List<PersonalRecord> personalRecords;
}
