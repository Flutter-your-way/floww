import 'package:floww/core/wave/models/wave_card_data.dart';

sealed class WaveMessage {
  const WaveMessage({required this.id, required this.timestamp});

  final String id;
  final DateTime timestamp;
}

class WaveUserMessage extends WaveMessage {
  const WaveUserMessage({
    required super.id,
    required super.timestamp,
    required this.text,
  });

  final String text;
}

class WaveReplyMessage extends WaveMessage {
  const WaveReplyMessage({
    required super.id,
    required super.timestamp,
    required this.text,
  });

  final String text;
}

class WaveDailyBriefMessage extends WaveMessage {
  const WaveDailyBriefMessage({
    required super.id,
    required super.timestamp,
    required this.brief,
  });

  final WaveDailyBrief brief;
}

class WavePlanMessage extends WaveMessage {
  const WavePlanMessage({
    required super.id,
    required super.timestamp,
    required this.title,
    required this.items,
  });

  final String title;
  final List<WavePlanItem> items;
}

class WaveInjurySwapMessage extends WaveMessage {
  const WaveInjurySwapMessage({
    required super.id,
    required super.timestamp,
    required this.swap,
  });

  final WaveInjurySwap swap;
}

class WaveConfirmationMessage extends WaveMessage {
  const WaveConfirmationMessage({
    required super.id,
    required super.timestamp,
    required this.title,
    required this.detail,
  });

  final String title;
  final String detail;
}

class WaveCheckInMessage extends WaveMessage {
  const WaveCheckInMessage({
    required super.id,
    required super.timestamp,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

class WaveScoreReportMessage extends WaveMessage {
  const WaveScoreReportMessage({
    required super.id,
    required super.timestamp,
    required this.report,
  });

  final WaveScoreReport report;
}

class WaveMealLogMessage extends WaveMessage {
  const WaveMealLogMessage({
    required super.id,
    required super.timestamp,
    required this.title,
    required this.subtitle,
    required this.foods,
  });

  final String title;
  final String subtitle;
  final List<WaveQuickFood> foods;
}

class WaveDietPlanMessage extends WaveMessage {
  const WaveDietPlanMessage({
    required super.id,
    required super.timestamp,
    required this.plan,
  });

  final WaveDietPlan plan;
}
