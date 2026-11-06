import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/core/home/services/recovery_calculator.dart';

class RecoveryInfo {
  const RecoveryInfo({required this.title, required this.message});

  final String title;
  final String message;
}

class RecoveryExplainer {
  const RecoveryExplainer._();

  static const String howItWorksTitle = 'How Recovery is calculated';

  static String get summary =>
      'Recovery estimates how ready your body is to train today, on a '
      '0–100% scale, using data from your wearable.';

  static List<String> get points => [
    'Sleep (${_share(RecoveryCalculator.sleepWeight)}): last night\'s sleep '
        'compared with your sleep goal '
        '(${RecoveryCalculator.defaultSleepTargetHours.round()}h by default).',
    'HRV (${_share(RecoveryCalculator.hrvWeight)}): today\'s heart rate '
        'variability compared with your '
        '${RecoveryCalculator.baselineWindowDays}-day average. Higher than '
        'usual means your body has bounced back.',
    'Energy (${_share(RecoveryCalculator.energyWeight)}): your resting heart '
        'rate compared with your normal, plus today\'s steps compared with '
        'your step goal.',
    'If a metric is missing, it is skipped and the others are re-weighted.',
  ];

  static String get levelsNote =>
      '${RecoveryCalculator.highFloor}%+ is High, '
      '${RecoveryCalculator.moderateFloor}–${RecoveryCalculator.highFloor - 1}% '
      'is Moderate, below ${RecoveryCalculator.moderateFloor}% is Low.';

  static RecoveryInfo? infoFor(RecoveryMetricAccent accent) {
    return switch (accent) {
      RecoveryMetricAccent.energy => energy,
      RecoveryMetricAccent.sleep || RecoveryMetricAccent.hrv => null,
    };
  }

  static RecoveryInfo get energy => RecoveryInfo(
    title: 'What is Energy?',
    message:
        'Energy shows how charged your body is today. It blends two '
        'signals from your wearable:\n\n'
        '• Resting heart rate vs your '
        '${RecoveryCalculator.baselineWindowDays}-day normal. A lower resting '
        'heart rate than usual means less strain on your body.\n'
        '• Steps vs your daily step goal '
        '(${_steps(RecoveryCalculator.defaultStepsTarget)} by default).\n\n'
        'The number is a 0–100% score. ${RecoveryCalculator.highFloor}%+ is '
        'High, ${RecoveryCalculator.moderateFloor}–'
        '${RecoveryCalculator.highFloor - 1}% is Moderate, below '
        '${RecoveryCalculator.moderateFloor}% is Low. Your resting heart rate '
        'baseline needs ${RecoveryCalculator.minimumBaselineDays} days of '
        'data before it counts.\n\n'
        'To improve it: get a full night\'s sleep, stay hydrated, go easy on '
        'alcohol and late caffeine, take rest days after hard sessions, and '
        'keep moving through the day to hit your step goal.',
  );

  static String _share(double weight) => '${(weight * 100).round()}%';

  static String _steps(double steps) {
    final value = steps.round();
    if (value < 1000) return '$value';
    final thousands = value ~/ 1000;
    final rest = (value % 1000).toString().padLeft(3, '0');
    return '$thousands,$rest';
  }
}
