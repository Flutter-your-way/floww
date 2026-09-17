import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';

enum WaveMessageKind {
  user,
  reply,
  dailyBrief,
  plan,
  injurySwap,
  confirmation,
  checkIn,
  scoreReport,
  mealLog,
  dietPlan,
}

class WaveTranscriptEntry {
  const WaveTranscriptEntry({
    required this.id,
    required this.kind,
    required this.createdAt,
    this.text,
    this.title,
    this.detail,
    this.isResolved = false,
    this.feeling,
    this.swap,
  });

  factory WaveTranscriptEntry.fromJson(Map<String, dynamic> json) =>
      WaveTranscriptEntry(
        id: json['id'] as String,
        kind:
            WaveMessageKind.values.asNameMap()[json['kind']] ??
            WaveMessageKind.reply,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        text: json['text'] as String?,
        title: json['title'] as String?,
        detail: json['detail'] as String?,
        isResolved: json['isResolved'] as bool? ?? false,
        feeling: json['feeling'] as String?,
        swap: _swapOf(json['swap']),
      );

  final String id;
  final WaveMessageKind kind;
  final DateTime createdAt;
  final String? text;
  final String? title;
  final String? detail;
  final bool isResolved;
  final String? feeling;
  final WaveInjurySwap? swap;

  WaveTranscriptEntry copyWith({bool? isResolved, String? feeling}) =>
      WaveTranscriptEntry(
        id: id,
        kind: kind,
        createdAt: createdAt,
        text: text,
        title: title,
        detail: detail,
        isResolved: isResolved ?? this.isResolved,
        feeling: feeling ?? this.feeling,
        swap: swap,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'createdAt': AppDateUtils.isoKey(createdAt),
    if (text != null) 'text': text,
    if (title != null) 'title': title,
    if (detail != null) 'detail': detail,
    'isResolved': isResolved,
    if (feeling != null) 'feeling': feeling,
    if (swap != null) 'swap': _swapJson(swap!),
  };

  static WaveInjurySwap? _swapOf(Object? value) {
    if (value is! Map) return null;
    final data = Map<String, dynamic>.from(value);
    return WaveInjurySwap(
      title: data['title'] as String? ?? '',
      removing: data['removing'] as String? ?? '',
      adding: data['adding'] as String? ?? '',
      rationale: data['rationale'] as String? ?? '',
      removingEntryId: data['removingEntryId'] as String?,
      addingExerciseId: data['addingExerciseId'] as String?,
    );
  }

  static Map<String, dynamic> _swapJson(WaveInjurySwap swap) => {
    'title': swap.title,
    'removing': swap.removing,
    'adding': swap.adding,
    'rationale': swap.rationale,
    if (swap.removingEntryId != null) 'removingEntryId': swap.removingEntryId,
    if (swap.addingExerciseId != null)
      'addingExerciseId': swap.addingExerciseId,
  };
}
