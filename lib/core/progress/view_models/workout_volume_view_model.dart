import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

class WorkoutVolumeViewModel extends ChangeNotifier {
  WorkoutVolumeViewModel(this._service) {
    _subscription = _service.watchRecentSessions().listen(
      _apply,
      onError: (Object error) {
        debugPrint('workout volume watch failed: $error');
        _isLoading = false;
        _errorMessage = 'Could not load your workout volume.';
        notifyListeners();
      },
    );
  }

  static const int _chartSessions = 6;

  final WorkoutSessionService _service;
  StreamSubscription<List<WorkoutSessionEntity>>? _subscription;
  List<WorkoutSessionEntity> _sessions = const [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _disposed = false;

  String get title => 'Workout Volume';

  String get chartTitle => 'Sets per session';

  String get chartRangeLabel => 'Last ${_chartPoints.length} sessions';

  String get historyTitle => 'Session history';

  String get emptyTitle => 'No workouts logged yet';

  String get emptyMessage =>
      'Finish a workout and its volume will show up here, session by session.';

  String get sessionsLabel => 'Sessions';

  String get setsLabel => 'Total Sets';

  String get liftedLabel => 'Lifted';

  String get statsCaption => 'Recent';

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasSessions => _sessions.isNotEmpty;

  String get sessionCountValue => '${_sessions.length}';

  String get totalSetsValue =>
      '${_sessions.fold<int>(0, (total, session) => total + session.totalSets)}';

  String get liftedValue =>
      '${_sessions.fold<double>(0, (total, session) => total + session.volumeKg).round()} kg';

  List<WorkoutSessionEntity> get _chartPoints =>
      _sessions.take(_chartSessions).toList().reversed.toList();

  List<ProgressBarPoint> get bars {
    final points = _chartPoints;
    final peak = points.fold<int>(
      0,
      (top, session) => math.max(top, session.totalSets),
    );
    return [
      for (final session in points)
        ProgressBarPoint(
          label: AppDateUtils.shortMonthDay(session.date),
          fraction: peak == 0 ? 0 : session.totalSets / peak,
          badgeLabel: session.totalSets > 0 ? '${session.totalSets}' : null,
        ),
    ];
  }

  List<VolumeSessionItem> get history => [
    for (final session in _sessions)
      VolumeSessionItem(
        id: session.id,
        title: session.name,
        dateLabel: AppDateUtils.relativeDay(session.date),
        setsLabel: '${session.totalSets} sets',
        volumeLabel: '${session.volumeKg.round()} kg',
      ),
  ];

  void _apply(List<WorkoutSessionEntity> sessions) {
    _sessions = [
      for (final session in sessions)
        if (session.isCompleted) session,
    ]..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
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
