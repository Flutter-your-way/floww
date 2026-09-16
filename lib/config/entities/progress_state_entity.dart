class ProgressState {
  const ProgressState({
    required this.completedChecklistIds,
    required this.isChecklistDismissed,
  });

  static const empty = ProgressState(
    completedChecklistIds: {},
    isChecklistDismissed: false,
  );

  factory ProgressState.fromJson(Map<String, dynamic> json) => ProgressState(
    completedChecklistIds: {
      for (final id in (json['completedChecklistIds'] as List? ?? const []))
        id as String,
    },
    isChecklistDismissed: json['isChecklistDismissed'] as bool? ?? false,
  );

  final Set<String> completedChecklistIds;
  final bool isChecklistDismissed;

  Map<String, dynamic> toJson() => {
    'completedChecklistIds': completedChecklistIds.toList(),
    'isChecklistDismissed': isChecklistDismissed,
  };
}
