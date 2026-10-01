import 'package:floww/config/theme/app_mode.dart';

class OnboardingInsight {
  const OnboardingInsight({required this.title, required this.body});

  final String title;
  final String body;

  factory OnboardingInsight.fromJson(Map<String, dynamic> json) =>
      OnboardingInsight(
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );
}

class OnboardingTargets {
  const OnboardingTargets({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.waterMl,
  });

  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatsG;
  final int waterMl;

  factory OnboardingTargets.fromJson(Map<String, dynamic> json) =>
      OnboardingTargets(
        calories: (json['calories'] as num? ?? 0).round(),
        proteinG: (json['proteinG'] as num? ?? 0).round(),
        carbsG: (json['carbsG'] as num? ?? 0).round(),
        fatsG: (json['fatsG'] as num? ?? 0).round(),
        waterMl: (json['waterMl'] as num? ?? 0).round(),
      );
}

class OnboardingBlueprint {
  const OnboardingBlueprint({
    required this.flowScore,
    required this.flowScoreReason,
    required this.workoutSplit,
    required this.sleepHours,
  });

  final int flowScore;
  final String flowScoreReason;
  final String workoutSplit;
  final double sleepHours;

  AppThemeMode get mode => AppThemeMode.fromFlowScore(flowScore);

  factory OnboardingBlueprint.fromJson(Map<String, dynamic> json) =>
      OnboardingBlueprint(
        flowScore: (json['flowScore'] as num? ?? 0).round().clamp(0, 100),
        flowScoreReason: json['flowScoreReason'] as String? ?? '',
        workoutSplit: json['workoutSplit'] as String? ?? 'Full Body',
        sleepHours: (json['sleepHours'] as num? ?? 8).toDouble(),
      );
}

class OnboardingAnalysis {
  const OnboardingAnalysis({
    required this.headline,
    required this.summary,
    required this.insights,
    required this.targets,
    required this.blueprint,
  });

  final String headline;
  final String summary;
  final List<OnboardingInsight> insights;
  final OnboardingTargets targets;
  final OnboardingBlueprint blueprint;

  factory OnboardingAnalysis.fromJson(Map<String, dynamic> json) =>
      OnboardingAnalysis(
        headline: json['headline'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        insights: (json['insights'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(OnboardingInsight.fromJson)
            .where((insight) => insight.title.isNotEmpty)
            .toList(),
        targets: OnboardingTargets.fromJson(
          json['targets'] as Map<String, dynamic>? ?? const {},
        ),
        blueprint: OnboardingBlueprint.fromJson(
          json['blueprint'] as Map<String, dynamic>? ?? const {},
        ),
      );
}
