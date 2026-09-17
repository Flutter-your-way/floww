import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/core/achievements/models/achievement.dart';
import 'package:floww/core/achievements/models/achievement_category.dart';
import 'package:floww/core/achievements/services/achievements_service.dart';

class AchievementsViewModel extends ChangeNotifier {
  AchievementsViewModel(this._service) {
    _watch();
  }

  final AchievementsService _service;

  List<Achievement> _achievements = const [];
  StreamSubscription<AchievementsRecords>? _subscription;
  AchievementCategory? _filter;
  bool _isReady = false;
  bool _disposed = false;

  bool get isReady => _isReady;

  AchievementCategory? get filter => _filter;

  List<AchievementCategory?> get filters => [
    null,
    ...AchievementCategory.values,
  ];

  List<Achievement> get achievements => _achievements;

  List<Achievement> get filteredAchievements {
    final filter = _filter;
    if (filter == null) return _achievements;
    return _achievements
        .where((achievement) => achievement.category == filter)
        .toList();
  }

  int get unlockedCount =>
      _achievements.where((achievement) => achievement.isUnlocked).length;

  int get totalCount => _achievements.length;

  int get totalXp => _achievements
      .where((achievement) => achievement.isUnlocked)
      .fold(0, (total, achievement) => total + achievement.xp);

  String get unlockedLabel => '$unlockedCount of $totalCount unlocked';

  String labelOf(AchievementCategory? category) => category?.label ?? 'All';

  void setFilter(AchievementCategory? filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void _watch() {
    _subscription = _service.watchRecords().listen(
      (records) {
        _achievements = _service.achievementsOf(records);
        _isReady = true;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('achievements watch failed: $error');
        _achievements = _service.achievementsOf(AchievementsRecords.empty);
        _isReady = true;
        notifyListeners();
      },
    );
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
