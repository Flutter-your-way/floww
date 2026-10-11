import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/wave/models/wave_action.dart';
import 'package:floww/core/wave/models/wave_premium_feature.dart';
import 'package:floww/core/wave/models/wave_quota.dart';
import 'package:floww/core/wave/models/wave_rejected_action.dart';

enum WaveCardKind {
  none,
  plan,
  mealLog,
  dietPlan,
  scoreReport,
  checkIn,
  injurySwap,
}

class WaveReply {
  const WaveReply({
    required this.text,
    required this.card,
    required this.injuryArea,
    this.actions = const [],
    this.memorySaved = const [],
    this.memoryForgotten = const [],
    this.rejected = const [],
    this.locked = const [],
    this.quota,
    this.route,
    this.aiModel,
    this.promptVersion,
  });

  factory WaveReply.fromJson(Map<String, dynamic> json) {
    final card =
        WaveCardKind.values.asNameMap()[json['card']] ?? WaveCardKind.none;
    return WaveReply(
      text: (json['reply'] as String? ?? '').trim(),
      card: card,
      injuryArea: card == WaveCardKind.injurySwap
          ? MuscleGroup.values.asNameMap()[json['injuryArea']]
          : null,
      actions: WaveAction.listOf(json['actions']),
      memorySaved: _textsOf(json['memorySaved']),
      memoryForgotten: _textsOf(json['memoryForgotten']),
      rejected: WaveRejectedAction.listOf(json['rejected']),
      locked: WavePremiumFeature.listOf(json['locked']),
      quota: WaveQuota.fromJson(json['quota']),
      route: _textOf(json['route']),
      aiModel: _textOf(json['aiModel']),
      promptVersion: _textOf(json['promptVersion']),
    );
  }

  static String? _textOf(Object? value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;

  static List<String> _textsOf(Object? value) => value is List
      ? [
          for (final item in value)
            if (item is String && item.trim().isNotEmpty) item.trim(),
        ]
      : const [];

  final String text;
  final WaveCardKind card;
  final MuscleGroup? injuryArea;
  final List<WaveAction> actions;
  final List<String> memorySaved;
  final List<String> memoryForgotten;
  final List<WaveRejectedAction> rejected;
  final List<WavePremiumFeature> locked;
  final WaveQuota? quota;
  final String? route;
  final String? aiModel;
  final String? promptVersion;
}
