enum WaveUndoKind {
  deleteWaterLogs,
  deleteFoodLogs,
  deleteCustomFood,
  reopenHabits,
  completeHabits,
  deleteHabit,
  restoreHabit,
  restoreHabitEdit,
  deleteWeightLog,
  restoreSleep,
  restorePlanDays,
  restoreProgram,
  unshiftPlan,
  removeSet,
  restoreFlowMode,
  restoreReminder,
  restoreTargets,
}

class WaveUndo {
  const WaveUndo(this.kind, [this.data = const {}]);

  static WaveUndo? fromJson(Object? value) {
    if (value is! Map) return null;
    final kind = WaveUndoKind.values.asNameMap()[value['kind']];
    if (kind == null) return null;
    final data = value['data'];
    return WaveUndo(
      kind,
      data is Map ? Map<String, dynamic>.from(data) : const {},
    );
  }

  final WaveUndoKind kind;
  final Map<String, dynamic> data;

  List<String> stringsOf(String key) {
    final value = data[key];
    return value is List ? [for (final item in value) '$item'] : const [];
  }

  String? stringOf(String key) {
    final value = data[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  Map<String, dynamic>? mapOf(String key) {
    final value = data[key];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  double? numberOf(String key) => (data[key] as num?)?.toDouble();

  Map<String, dynamic> toJson() => {'kind': kind.name, 'data': data};
}
