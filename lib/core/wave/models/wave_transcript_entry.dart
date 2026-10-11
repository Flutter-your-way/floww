import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/wave/models/wave_action.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/models/wave_rating.dart';
import 'package:floww/core/wave/models/wave_undo.dart';

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
  actionPrompt,
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
    this.action,
    this.tone,
    this.pendingAction,
    this.undo,
    this.destination,
    this.promptVersion,
    this.aiModel,
    this.route,
    this.rating,
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
        action: WaveConfirmationAction.values.asNameMap()[json['action']],
        tone: WaveConfirmationTone.values.asNameMap()[json['tone']],
        pendingAction: json['pendingAction'] is Map
            ? WaveAction.fromJson(
                Map<String, dynamic>.from(json['pendingAction'] as Map),
              )
            : null,
        undo: WaveUndo.fromJson(json['undo']),
        destination: WaveDestination.values.asNameMap()[json['destination']],
        promptVersion: json['promptVersion'] as String?,
        aiModel: json['aiModel'] as String?,
        route: json['route'] as String?,
        rating: WaveRating.values.asNameMap()[json['rating']],
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
  final WaveConfirmationAction? action;
  final WaveConfirmationTone? tone;
  final WaveAction? pendingAction;
  final WaveUndo? undo;
  final WaveDestination? destination;
  final String? promptVersion;
  final String? aiModel;
  final String? route;
  final WaveRating? rating;

  bool get isRateable => kind == WaveMessageKind.reply && promptVersion != null;

  WaveTranscriptEntry copyWith({
    bool? isResolved,
    String? feeling,
    WaveRating? rating,
  }) => WaveTranscriptEntry(
    id: id,
    kind: kind,
    createdAt: createdAt,
    text: text,
    title: title,
    detail: detail,
    isResolved: isResolved ?? this.isResolved,
    feeling: feeling ?? this.feeling,
    swap: swap,
    action: action,
    tone: tone,
    pendingAction: pendingAction,
    undo: undo,
    destination: destination,
    promptVersion: promptVersion,
    aiModel: aiModel,
    route: route,
    rating: rating ?? this.rating,
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
    if (action != null) 'action': action!.name,
    if (tone != null) 'tone': tone!.name,
    if (pendingAction != null) 'pendingAction': pendingAction!.toJson(),
    if (undo != null) 'undo': undo!.toJson(),
    if (destination != null) 'destination': destination!.name,
    'promptVersion': ?promptVersion,
    'aiModel': ?aiModel,
    'route': ?route,
    if (rating != null) 'rating': rating!.name,
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
