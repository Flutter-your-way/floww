import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/models/muscle_recovery_status.dart';

class FlowScoreBoost {
  const FlowScoreBoost({
    required this.label,
    required this.points,
    required this.completed,
  });

  final String label;
  final int points;
  final bool completed;
}

class FlowScoreComponent {
  const FlowScoreComponent({
    required this.emoji,
    required this.title,
    required this.detail,
    required this.points,
    required this.maxPoints,
    required this.hintPoints,
    required this.hint,
  });

  final String emoji;
  final String title;
  final String detail;
  final int points;
  final int maxPoints;
  final int hintPoints;
  final String hint;

  bool get isComplete => points >= maxPoints;

  double get fraction => maxPoints == 0 ? 0 : points / maxPoints;
}

class FlowScoreBreakdown {
  const FlowScoreBreakdown({
    required this.weeklyAveragePercent,
    required this.components,
  });

  static const empty = FlowScoreBreakdown(
    weeklyAveragePercent: 0,
    components: [],
  );

  final int weeklyAveragePercent;
  final List<FlowScoreComponent> components;

  int get todayPercent =>
      components.fold(0, (total, component) => total + component.points);

  int get pointsLeftPercent => 100 - todayPercent;
}

class FlowModeDetail {
  const FlowModeDetail({
    required this.mode,
    required this.statusLabel,
    required this.reasons,
    required this.tips,
  });

  final AppThemeMode mode;
  final String statusLabel;
  final List<String> reasons;
  final List<String> tips;
}

enum RecoveryMetricAccent { sleep, hrv, energy }

class RecoveryMetric {
  const RecoveryMetric({
    required this.emoji,
    required this.label,
    required this.valueLabel,
    required this.percent,
    required this.accent,
  });

  final String emoji;
  final String label;
  final String valueLabel;
  final int percent;
  final RecoveryMetricAccent accent;
}

class RecoveryDetail {
  const RecoveryDetail({
    required this.percent,
    required this.levelLabel,
    required this.metrics,
  });

  static const empty = RecoveryDetail(
    percent: 0,
    levelLabel: 'Unknown',
    metrics: [],
  );

  final int percent;
  final String levelLabel;
  final List<RecoveryMetric> metrics;

  bool get hasData => metrics.isNotEmpty;
}

class HabitItem {
  const HabitItem({
    required this.id,
    required this.title,
    required this.valueLabel,
    required this.completed,
  });

  final String id;
  final String title;
  final String valueLabel;
  final bool completed;
}

class WorkoutRecommendation {
  const WorkoutRecommendation({
    required this.title,
    required this.durationLabel,
    required this.intensityLabel,
    required this.reasons,
  });

  final String title;
  final String durationLabel;
  final String intensityLabel;
  final List<String> reasons;
}

class NutritionSummary {
  const NutritionSummary({
    required this.totalCalories,
    required this.calorieGoal,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
  });

  final int totalCalories;
  final int calorieGoal;
  final int proteinG;
  final int carbsG;
  final int fatsG;
}

class ProgressItem {
  const ProgressItem({
    required this.label,
    required this.fraction,
    required this.isComplete,
  });

  final String label;
  final String fraction;
  final bool isComplete;
}

class TodayProgress {
  const TodayProgress({
    required this.completedCount,
    required this.totalCount,
    required this.items,
  });

  static const empty = TodayProgress(
    completedCount: 0,
    totalCount: 0,
    items: [],
  );

  final int completedCount;
  final int totalCount;
  final List<ProgressItem> items;

  int get percent =>
      totalCount == 0 ? 0 : ((completedCount / totalCount) * 100).round();
}

class MuscleRecoveryData {
  const MuscleRecoveryData({
    required this.daysSinceLastWorkout,
    required this.inRecoveryCount,
    required this.readyMusclesCount,
    required this.fatiguedMusclesCount,
    required this.statuses,
  });

  static const empty = MuscleRecoveryData(
    daysSinceLastWorkout: 0,
    inRecoveryCount: 0,
    readyMusclesCount: 0,
    fatiguedMusclesCount: 0,
    statuses: {},
  );

  final int daysSinceLastWorkout;
  final int inRecoveryCount;
  final int readyMusclesCount;
  final int fatiguedMusclesCount;
  final Map<MuscleGroup, MuscleRecoveryStatus> statuses;
}

class HomeSnapshot {
  const HomeSnapshot({
    required this.userName,
    required this.streakCount,
    required this.flowScorePercent,
    required this.flowScoreBreakdown,
    required this.flowScoreBoosts,
    required this.recovery,
    required this.flowMode,
    required this.habits,
    required this.workout,
    required this.nutrition,
    required this.todayProgress,
    required this.muscleRecovery,
    required this.waveInsight,
    required this.todayFlowEntry,
  });

  static const empty = HomeSnapshot(
    userName: '',
    streakCount: 0,
    flowScorePercent: 0,
    flowScoreBreakdown: FlowScoreBreakdown.empty,
    flowScoreBoosts: [],
    recovery: RecoveryDetail.empty,
    flowMode: null,
    habits: [],
    workout: null,
    nutrition: NutritionSummary(
      totalCalories: 0,
      calorieGoal: 0,
      proteinG: 0,
      carbsG: 0,
      fatsG: 0,
    ),
    todayProgress: TodayProgress.empty,
    muscleRecovery: MuscleRecoveryData.empty,
    waveInsight: null,
    todayFlowEntry: null,
  );

  final String userName;
  final int streakCount;
  final int flowScorePercent;
  final FlowScoreBreakdown flowScoreBreakdown;
  final List<FlowScoreBoost> flowScoreBoosts;
  final RecoveryDetail recovery;
  final FlowModeDetail? flowMode;
  final List<HabitItem> habits;
  final WorkoutRecommendation? workout;
  final NutritionSummary nutrition;
  final TodayProgress todayProgress;
  final MuscleRecoveryData muscleRecovery;
  final String? waveInsight;
  final DailyFlowEntry? todayFlowEntry;
}
