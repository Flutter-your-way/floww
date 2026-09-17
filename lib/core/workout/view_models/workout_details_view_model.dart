import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/workout/models/add_exercise_view_data.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

class WorkoutDetailsViewModel extends ChangeNotifier {
  WorkoutDetailsViewModel(this._service, this._sessionId) {
    _start();
  }

  static const int _secondsPerMinute = 60;
  static const String _loadFailure = 'Could not load this workout.';

  final WorkoutSessionService _service;
  final String _sessionId;

  StreamSubscription<WorkoutSessionEntity?>? _subscription;
  WorkoutSessionEntity? _session;
  List<WorkoutSessionEntity> _history = const [];
  String? _expandedSectionId;
  bool _isLoading = true;
  bool _disposed = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasDetail => _session != null;

  String get title => 'Workout Details';

  void _start() {
    _subscription = _service.watchSession(_sessionId).listen((session) {
      _session = session;
      _isLoading = false;
      _errorMessage = null;
      _expandedSectionId ??= _sections.isEmpty ? null : _sections.first.id;
      notifyListeners();
    }, onError: _onError);
    unawaited(_loadHistory());
  }

  Future<void> _loadHistory() async {
    try {
      _history = await _service.loadRecentSessions();
      notifyListeners();
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  void _onError(Object error) {
    _isLoading = false;
    _errorMessage = error is WorkoutException ? error.message : _loadFailure;
    notifyListeners();
  }

  List<WorkoutSectionKind> get _sections {
    final session = _session;
    if (session == null) return const [];
    return [
      for (final kind in WorkoutSectionKind.values)
        if (session.exercises.any((entry) => entry.section == kind)) kind,
    ];
  }

  List<AddExerciseSectionOption> get sectionOptions => [
    for (final kind in WorkoutSectionKind.values)
      AddExerciseSectionOption(id: kind.id, glyph: kind.glyph, title: kind.title),
  ];

  String? get expandedSectionId => _expandedSectionId;

  WorkoutDetailItem? get detail {
    final session = _session;
    if (session == null) return null;
    return WorkoutDetailItem(
      name: session.name,
      dateLabel:
          '${AppDateUtils.monthDayYear(session.startedAt)} at '
          '${AppDateUtils.time(session.startedAt)}',
      statusLabel: session.isCompleted ? 'Completed' : 'In Progress',
      isCompleted: session.isCompleted,
      stats: [
        WorkoutStatItem(
          icon: Icons.schedule,
          title: 'DURATION',
          value: _durationLabel(session.durationSeconds),
          unit: 'min',
        ),
        WorkoutStatItem(
          icon: Icons.bar_chart,
          title: 'VOLUME',
          value: NumberFormatter.grouped(session.volumeKg.round()),
          unit: 'kg',
        ),
        WorkoutStatItem(
          icon: Icons.local_fire_department,
          title: 'CALORIES',
          value: NumberFormatter.grouped(session.caloriesKcal),
          unit: 'kcal',
        ),
        WorkoutStatItem(
          icon: Icons.monitor_heart,
          title: 'AVG HEART RATE',
          value: session.averageHeartRate == null
              ? '—'
              : '${session.averageHeartRate}',
          unit: session.averageHeartRate == null ? '' : 'bpm',
        ),
      ],
      exerciseCountLabel: '${session.exercises.length} exercises',
      sections: [for (final kind in _sections) _sectionOf(kind, session)],
      insightTitle: 'WAVE Insight',
      insightMessage: _insightOf(session),
      notes: session.notes,
    );
  }

  String get notes => _session?.notes ?? '';

  String get notesEmptyMessage => 'No notes for this session yet.';

  String get notesSheetTitle => 'Workout Notes';

  String get notesSheetSubtitle => 'Capture how this session felt';

  String get notesSheetHint =>
      'e.g. Felt strong today, increased weight on squats...';

  String get notesSheetSubmitLabel => 'Save Notes';

  String _insightOf(WorkoutSessionEntity session) {
    final previous = _previousOf(session);
    if (previous == null) {
      return 'First ${session.name} logged. WAVE will compare your next one '
          'against this session.';
    }
    if (previous.volumeKg == 0) {
      return 'You logged ${NumberFormatter.grouped(session.volumeKg.round())} '
          'kg of volume across ${session.totalSets} sets.';
    }
    final change =
        ((session.volumeKg - previous.volumeKg) / previous.volumeKg) * 100;
    if (change.abs() < 1) {
      return 'Volume held steady against your last ${session.name}. '
          'Consistency is progress.';
    }
    final direction = change > 0 ? 'increased' : 'dropped';
    return 'Your ${session.name} volume $direction '
        '${change.abs().round()}% against the previous session.';
  }

  WorkoutSessionEntity? _previousOf(WorkoutSessionEntity session) {
    for (final entry in _history) {
      if (entry.id == session.id) continue;
      if (!entry.isCompleted) continue;
      if (entry.name != session.name) continue;
      if (entry.startedAt.isBefore(session.startedAt)) return entry;
    }
    return null;
  }

  WorkoutSectionItem _sectionOf(
    WorkoutSectionKind kind,
    WorkoutSessionEntity session,
  ) {
    final exercises = [
      for (final entry in session.exercises)
        if (entry.section == kind) entry,
    ];
    return WorkoutSectionItem(
      id: kind.id,
      glyph: kind.glyph,
      title: kind.title,
      countLabel: '${exercises.length} exercises',
      status: _statusOf(exercises),
      isExpanded: kind.id == _expandedSectionId,
      exercises: [for (final exercise in exercises) _exerciseOf(exercise)],
    );
  }

  WorkoutSectionStatus _statusOf(List<WorkoutEntryEntity> exercises) {
    if (exercises.every((exercise) => exercise.isComplete)) {
      return WorkoutSectionStatus.completed;
    }
    if (exercises.any((exercise) => exercise.sets.isNotEmpty)) {
      return WorkoutSectionStatus.active;
    }
    return WorkoutSectionStatus.pending;
  }

  WorkoutExerciseItem _exerciseOf(WorkoutEntryEntity exercise) {
    final logged = exercise.sets.length;
    return WorkoutExerciseItem(
      id: exercise.id,
      name: exercise.name,
      imageUrl: exercise.imageUrl,
      setsLabel:
          '$logged/${exercise.targetSets} sets x ${exercise.targetReps} reps',
      weightLabel: exercise.isBodyweight
          ? 'BW'
          : '${_weightLabel(exercise.targetWeightKg!)} kg',
      restLabel: _durationLabel(exercise.restSeconds),
      volumeLabel: exercise.completedVolumeKg == 0
          ? '—'
          : NumberFormatter.grouped(exercise.completedVolumeKg.round()),
    );
  }

  String _weightLabel(double value) {
    if (value % 1 == 0) return NumberFormatter.grouped(value.round());
    return value.toStringAsFixed(1);
  }

  String _durationLabel(int seconds) {
    final minutes = seconds ~/ _secondsPerMinute;
    final remainder = seconds % _secondsPerMinute;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }

  void toggleSection(String id) {
    _expandedSectionId = _expandedSectionId == id ? null : id;
    notifyListeners();
  }

  Future<void> updateNotes(String value) async {
    try {
      await _service.updateNotes(_sessionId, value.trim());
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  Future<void> addExercise(String sectionId, WorkoutEntryEntity entry) async {
    try {
      await _service.addExercise(_sessionId, entry);
      _expandedSectionId = sectionId;
      notifyListeners();
    } on WorkoutException catch (error) {
      _onError(error);
    }
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
