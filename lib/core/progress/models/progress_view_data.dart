import 'package:flutter/widgets.dart';

enum ProgressTone { primary, accent, neutral }

class ProgressOverviewStat {
  const ProgressOverviewStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final ProgressTone tone;
}

class FlowScoreDay {
  const FlowScoreDay({required this.label, required this.percent});

  final String label;
  final int percent;

  bool get hasScore => percent > 0;
}

class FlowScoreSummary {
  const FlowScoreSummary({
    required this.score,
    required this.weeklyDelta,
    required this.bestScore,
    required this.bestDay,
    required this.worstScore,
    required this.worstDay,
    required this.averageScore,
    required this.days,
  });

  const FlowScoreSummary.empty()
    : score = 0,
      weeklyDelta = 0,
      bestScore = 0,
      bestDay = '',
      worstScore = 0,
      worstDay = '',
      averageScore = 0,
      days = const [];

  final int score;
  final int weeklyDelta;
  final int bestScore;
  final String bestDay;
  final int worstScore;
  final String worstDay;
  final int averageScore;
  final List<FlowScoreDay> days;

  bool get hasScores =>
      score > 0 || averageScore > 0 || days.any((day) => day.hasScore);
}

class WaveInsights {
  const WaveInsights({required this.improvement, required this.weakness});

  final String improvement;
  final String weakness;
}

class WeightEntry {
  const WeightEntry({required this.date, required this.weight});

  final DateTime date;
  final double weight;
}

class WeightTracking {
  const WeightTracking({
    required this.entries,
    required this.targetWeight,
    required this.startWeight,
    required this.weeklyChange,
  });

  final List<WeightEntry> entries;
  final double targetWeight;
  final double startWeight;
  final double weeklyChange;

  WeightTracking copyWith({
    List<WeightEntry>? entries,
    double? targetWeight,
    double? startWeight,
    double? weeklyChange,
  }) => WeightTracking(
    entries: entries ?? this.entries,
    targetWeight: targetWeight ?? this.targetWeight,
    startWeight: startWeight ?? this.startWeight,
    weeklyChange: weeklyChange ?? this.weeklyChange,
  );

  bool get hasEntries => entries.isNotEmpty;

  double get currentWeight => entries.isEmpty ? 0 : entries.last.weight;

  double get totalChange =>
      entries.isEmpty ? 0 : entries.last.weight - startWeight;
}

class VolumeDay {
  const VolumeDay({required this.label, required this.sets});

  final String label;
  final int sets;
}

class WorkoutVolume {
  const WorkoutVolume({required this.days});

  const WorkoutVolume.empty() : days = const [];

  final List<VolumeDay> days;

  bool get hasVolume => days.any((day) => day.sets > 0);

  int get sessionCount => days.where((day) => day.sets > 0).length;

  int get totalSets => days.fold<int>(0, (total, day) => total + day.sets);
}

class HabitConsistencyItem {
  const HabitConsistencyItem({
    required this.label,
    required this.completedDays,
    required this.targetDays,
  });

  final String label;
  final int completedDays;
  final int targetDays;

  double get progress =>
      targetDays == 0 ? 0 : (completedDays / targetDays).clamp(0.0, 1.0);
}

class PersonalRecord {
  const PersonalRecord({
    required this.label,
    required this.value,
    required this.caption,
    required this.tone,
  });

  final String label;
  final String value;
  final String caption;
  final ProgressTone tone;
}

class ProgressChecklistItem {
  const ProgressChecklistItem({
    required this.id,
    required this.label,
    required this.isCompleted,
  });

  final String id;
  final String label;
  final bool isCompleted;

  ProgressChecklistItem copyWith({bool? isCompleted}) => ProgressChecklistItem(
    id: id,
    label: label,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}

class ProgressSnapshot {
  const ProgressSnapshot({
    required this.averageFlow,
    required this.streakDays,
    required this.completedWorkouts,
    required this.flowScore,
    required this.insights,
    required this.weight,
    required this.volume,
    required this.habits,
    required this.records,
    required this.checklist,
  });

  static const empty = ProgressSnapshot(
    averageFlow: 0,
    streakDays: 0,
    completedWorkouts: 0,
    flowScore: FlowScoreSummary.empty(),
    insights: null,
    weight: WeightTracking(
      entries: [],
      targetWeight: 0,
      startWeight: 0,
      weeklyChange: 0,
    ),
    volume: WorkoutVolume.empty(),
    habits: [],
    records: [],
    checklist: [],
  );

  final int averageFlow;
  final int streakDays;
  final int completedWorkouts;
  final FlowScoreSummary flowScore;
  final WaveInsights? insights;
  final WeightTracking weight;
  final WorkoutVolume volume;
  final List<HabitConsistencyItem> habits;
  final List<PersonalRecord> records;
  final List<ProgressChecklistItem> checklist;
}
