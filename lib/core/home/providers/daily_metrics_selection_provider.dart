import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:floww/core/health/models/health_metric_kind.dart';

class DailyMetricsSelectionProvider extends ChangeNotifier {
  static const String selectionKey = 'daily_metrics_selection';
  static const String selectionVersionKey = 'daily_metrics_selection_version';
  static const int selectionVersion = 2;

  List<HealthMetricKind>? _selected;

  bool get isCustomized => _selected != null;

  List<HealthMetricKind> visibleOf(Set<HealthMetricKind> available) {
    final selected = _selected;
    if (available.isEmpty) return HealthMetricKindX.defaultDaily;
    final picked = [
      for (final kind in HealthMetricKindX.daily)
        if (available.contains(kind) &&
            (selected?.contains(kind) ??
                HealthMetricKindX.defaultDaily.contains(kind)))
          kind,
    ];
    if (picked.isNotEmpty) return picked;
    return [
      for (final kind in HealthMetricKindX.daily)
        if (available.contains(kind)) kind,
    ].take(HealthMetricKindX.defaultDaily.length).toList();
  }

  bool isSelected(HealthMetricKind kind, Set<HealthMetricKind> available) =>
      visibleOf(available).contains(kind);

  bool canToggleOff(HealthMetricKind kind, Set<HealthMetricKind> available) {
    final visible = visibleOf(available);
    return !visible.contains(kind) || visible.length > 1;
  }

  Future<void> toggle(
    HealthMetricKind kind,
    Set<HealthMetricKind> available,
  ) async {
    if (!available.contains(kind)) return;
    final next = visibleOf(available).toSet();
    if (next.contains(kind)) {
      if (next.length <= 1) return;
      next.remove(kind);
    } else {
      next.add(kind);
    }
    _selected = [
      for (final item in HealthMetricKindX.daily)
        if (next.contains(item)) item,
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final names = prefs.getStringList(selectionKey);
      if (names == null) return;
      final version = prefs.getInt(selectionVersionKey) ?? 1;
      final upgrade = version < selectionVersion;
      _selected = [
        for (final kind in HealthMetricKindX.daily)
          if (names.contains(kind.name) ||
              (upgrade && HealthMetricKindX.addedInV2.contains(kind)))
            kind,
      ];
      notifyListeners();
      if (upgrade) await _persist();
    } catch (e, stackTrace) {
      debugPrint('restore daily metrics selection failed: $e\n$stackTrace');
    }
  }

  Future<void> _persist() async {
    final selected = _selected;
    if (selected == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(selectionKey, [
        for (final kind in selected) kind.name,
      ]);
      await prefs.setInt(selectionVersionKey, selectionVersion);
    } catch (e, stackTrace) {
      debugPrint('persist daily metrics selection failed: $e\n$stackTrace');
    }
  }
}
