import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/models/exercise.dart';
import 'package:floww/core/workout/models/exercise_view_data.dart';
import 'package:floww/core/workout/models/muscle_group_artwork.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/services/exercise_insights.dart';
import 'package:floww/core/workout/services/workout_catalog_data.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';
import 'package:floww/core/workout/services/workout_progression.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

class ExerciseLibraryViewModel extends ChangeNotifier {
  ExerciseLibraryViewModel(this._service, this._sessionService) {
    _start();
  }

  static const String _loadFailure = 'Could not load your exercise library.';
  static const int _secondsPerMinute = 60;
  static const double _primaryShare = 0.8;
  static const double _secondaryShare = 0.5;
  static const String _noValue = '—';

  final WorkoutCatalogService _service;
  final WorkoutSessionService _sessionService;

  StreamSubscription<List<ExerciseCatalogEntry>>? _subscription;
  StreamSubscription<List<WorkoutSessionEntity>>? _sessionSubscription;
  List<ExerciseCatalogEntry> _exercises = const [];
  List<WorkoutSessionEntity> _sessions = const [];
  Map<String, WorkoutEntryEntity> _lastEntries = const {};
  Map<String, ExerciseBest> _bests = const {};
  String _query = '';
  ExerciseScope _scope = ExerciseScope.all;
  Equipment? _equipment;
  MuscleGroup? _expandedGroup = MuscleGroup.chest;
  String? _detailId;
  String? _expandedSectionId = ExerciseInsights.personalBestId;
  bool _isLoading = true;
  bool _disposed = false;
  String? _errorMessage;

  String _draftName = '';
  MuscleGroup _draftGroup = MuscleGroup.chest;
  Equipment _draftEquipment = Equipment.barbell;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String get query => _query;

  String get searchHint => 'Search exercises...';

  String get hint =>
      'Tap an exercise for form tips and your history. Star the ones you '
      'use and they show first when you add or swap exercises.';

  MuscleGroup? get expandedGroup => _expandedGroup;

  String get draftName => _draftName;

  MuscleGroup get draftGroup => _draftGroup;

  Equipment get draftEquipment => _draftEquipment;

  bool get canSaveDraft => _draftName.trim().isNotEmpty;

  List<MuscleGroup> get muscleGroups => MuscleGroup.values;

  List<Equipment> get equipmentOptions => Equipment.values;

  int get _savedCount =>
      _exercises.where((exercise) => exercise.isAdded).length;

  List<ProgramFilterItem<ExerciseScope>> get scopeFilters => [
    for (final scope in ExerciseScope.values)
      ProgramFilterItem(
        value: scope,
        label: scope == ExerciseScope.saved && _savedCount > 0
            ? '${scope.label} · $_savedCount'
            : scope.label,
        isSelected: scope == _scope,
      ),
  ];

  List<ProgramFilterItem<Equipment?>> get equipmentFilters => [
    ProgramFilterItem(
      value: null,
      label: 'Any equipment',
      isSelected: _equipment == null,
    ),
    for (final equipment in Equipment.values)
      ProgramFilterItem(
        value: equipment,
        label: equipment.label,
        isSelected: equipment == _equipment,
      ),
  ];

  bool get _isFiltering =>
      _query.trim().isNotEmpty ||
      _scope != ExerciseScope.all ||
      _equipment != null;

  List<ExerciseCatalogEntry> get _visibleExercises {
    final query = _query.trim().toLowerCase();
    return [
      for (final exercise in _exercises)
        if ((exercise.isAvailable || _lastEntries.containsKey(exercise.id)) &&
            (query.isEmpty || exercise.name.toLowerCase().contains(query)) &&
            (_equipment == null || exercise.equipment == _equipment) &&
            _inScope(exercise))
          exercise,
    ];
  }

  bool _inScope(ExerciseCatalogEntry exercise) => switch (_scope) {
    ExerciseScope.all => true,
    ExerciseScope.saved => exercise.isAdded,
    ExerciseScope.trained => _lastEntries.containsKey(exercise.id),
    ExerciseScope.custom => exercise.isCustom,
  };

  String get countLabel {
    final count = _visibleExercises.length;
    return '$count ${count == 1 ? 'exercise' : 'exercises'}';
  }

  String get emptyMessage {
    if (_query.trim().isNotEmpty || _equipment != null) {
      return 'No exercises match these filters.';
    }
    return switch (_scope) {
      ExerciseScope.saved =>
        'Nothing saved yet. Tap the star on any exercise to add it to My '
            'Exercises.',
      ExerciseScope.trained =>
        'Exercises you log in a workout will show up here.',
      ExerciseScope.custom =>
        'Tap + to create an exercise that is not in the library.',
      ExerciseScope.all => 'No exercises in your library yet.',
    };
  }

  void _start() {
    _subscription?.cancel();
    _subscription = _service.watchExercises().listen((exercises) {
      _exercises = exercises;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: _onError);
    _sessionSubscription?.cancel();
    _sessionSubscription = _sessionService.watchRecentSessions().listen((
      sessions,
    ) {
      _sessions = [
        for (final session in sessions)
          if (session.isCompleted)
            session
          else if (session.isInProgress)
            session.copyWith(status: WorkoutSessionStatus.completed),
      ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      _lastEntries = _lastEntriesOf(_sessions);
      _bests = WorkoutMetrics.bestsOf(_sessions);
      notifyListeners();
    }, onError: (Object _) {});
  }

  static Map<String, WorkoutEntryEntity> _lastEntriesOf(
    List<WorkoutSessionEntity> sessions,
  ) {
    final result = <String, WorkoutEntryEntity>{};
    for (final session in sessions) {
      for (final entry in session.exercises) {
        if (entry.workingSetCount == 0) continue;
        result.putIfAbsent(entry.exerciseId, () => entry);
      }
    }
    return result;
  }

  void _onError(Object error) {
    _isLoading = false;
    _errorMessage = error is WorkoutException ? error.message : _loadFailure;
    notifyListeners();
  }

  Future<void> retry() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await _service.ensureSeeded();
    _start();
  }

  List<ExerciseGroupItem> get groups {
    final visible = _visibleExercises;
    final result = <ExerciseGroupItem>[];
    for (final group in MuscleGroup.values) {
      final matches = [
        for (final exercise in visible)
          if (exercise.group == group) exercise,
      ];
      if (matches.isEmpty) continue;
      result.add(
        ExerciseGroupItem(
          group: group,
          title: group.label,
          imageUrl: group.photo,
          countLabel:
              '${matches.length} '
              '${matches.length == 1 ? 'Exercise' : 'Exercises'}',
          isExpanded: _isFiltering || _expandedGroup == group,
          exercises: [for (final exercise in matches) _rowOf(exercise)],
        ),
      );
    }
    return result;
  }

  List<String?> get previewImageUrls => [
    for (final exercise in _visibleExercises)
      if (exercise.group == _expandedGroup) _imageOf(exercise),
  ];

  ExerciseRowItem _rowOf(ExerciseCatalogEntry exercise) {
    final last = _lastEntries[exercise.id];
    final history = last == null
        ? 'Not tried yet'
        : 'Last: ${ExerciseInsights.setsSummaryOf(last)}';
    return ExerciseRowItem(
      id: exercise.id,
      name: exercise.name,
      detailLabel: '${exercise.equipment.label} · $history',
      isCustom: exercise.isCustom,
      isSaved: exercise.isAdded,
      imageUrl: _imageOf(exercise),
    );
  }

  String? _imageOf(ExerciseCatalogEntry exercise) =>
      exercise.imageUrl ?? WorkoutCatalogData.imageFor(exercise.id);

  void search(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  void selectScope(ExerciseScope scope) {
    if (scope == _scope) return;
    _scope = scope;
    notifyListeners();
  }

  void selectEquipment(Equipment? equipment) {
    if (equipment == _equipment) return;
    _equipment = equipment;
    notifyListeners();
  }

  void toggleGroup(MuscleGroup group) {
    _expandedGroup = _expandedGroup == group ? null : group;
    notifyListeners();
  }

  Future<void> toggleSaved(String id) async {
    final exercise = _exerciseOf(id);
    if (exercise == null) return;
    try {
      await _service.setAdded(id, !exercise.isAdded);
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  ExerciseCatalogEntry? _exerciseOf(String? id) {
    if (id == null) return null;
    for (final exercise in _exercises) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }

  void openDetail(String id) {
    _detailId = id;
    _expandedSectionId = ExerciseInsights.personalBestId;
    notifyListeners();
  }

  void toggleSection(String id) {
    _expandedSectionId = _expandedSectionId == id ? null : id;
    notifyListeners();
  }

  ExerciseDetailItem? get detail {
    final exercise = _exerciseOf(_detailId);
    if (exercise == null) return null;
    final history = WorkoutProgression.historyOf(_sessions, exercise.id);
    final best = _bests[exercise.id];
    final trend = WorkoutMetrics.oneRepMaxTrendOf(_sessions, exercise.id);
    final sections = [
      ExerciseInsights.personalBestSectionOf(
        ExerciseInsights.recordItemsOf(
          history: history,
          best: best,
          trend: trend,
          isTimed: exercise.isTimed,
        ),
      ),
      ...ExerciseInsights.techniqueSectionsOf(
        mistakes: exercise.mistakes,
        guidelines: exercise.guidelines,
        equipmentItems: exercise.equipmentItems,
      ),
    ];
    return ExerciseDetailItem(
      id: exercise.id,
      name: exercise.name,
      subtitle: '${exercise.group.label} · ${exercise.equipment.label}',
      imageUrl: _imageOf(exercise),
      stats: _statsOf(exercise, best),
      targetLabel: _targetLabelOf(exercise),
      muscles: _musclesOf(exercise),
      sections: [
        for (final section in sections)
          ExerciseInfoSectionItem(
            id: section.id,
            icon: section.icon,
            title: section.title,
            tone: section.tone,
            items: section.items,
            emptyMessage: section.emptyMessage,
            isExpanded: section.id == _expandedSectionId,
          ),
      ],
      isSaved: exercise.isAdded,
      isCustom: exercise.isCustom,
    );
  }

  String saveLabelOf(ExerciseDetailItem detail) =>
      detail.isSaved ? 'Saved to My Exercises' : 'Save to My Exercises';

  List<WorkoutStatItem> _statsOf(
    ExerciseCatalogEntry exercise,
    ExerciseBest? best,
  ) {
    final sessions = _sessions
        .where(
          (session) => session.exercises.any(
            (entry) =>
                entry.exerciseId == exercise.id && entry.workingSetCount > 0,
          ),
        )
        .toList();
    final lastDate = sessions.isEmpty ? null : sessions.first.date;
    final (bestValue, bestUnit) = _bestOf(exercise, best);
    return [
      WorkoutStatItem(
        icon: Icons.event_repeat,
        title: 'SESSIONS',
        value: '${sessions.length}',
        unit: '',
      ),
      WorkoutStatItem(
        icon: Icons.emoji_events_outlined,
        title: 'BEST',
        value: bestValue,
        unit: bestUnit,
      ),
      WorkoutStatItem(
        icon: Icons.history,
        title: 'LAST DONE',
        value: lastDate == null ? _noValue : _dayLabelOf(lastDate),
        unit: '',
      ),
    ];
  }

  (String, String) _bestOf(ExerciseCatalogEntry exercise, ExerciseBest? best) {
    if (best == null) return (_noValue, '');
    if (exercise.isTimed) {
      return best.seconds > 0 ? ('${best.seconds}', 's') : (_noValue, '');
    }
    if (best.weightKg > 0) {
      return (WorkoutMetrics.weightLabel(best.weightKg), 'kg');
    }
    return best.reps > 0 ? ('${best.reps}', 'reps') : (_noValue, '');
  }

  String _dayLabelOf(DateTime date) {
    final days = AppDateUtils.daysBetween(date, DateTime.now());
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return AppDateUtils.dayMonth(date);
  }

  String _targetLabelOf(ExerciseCatalogEntry exercise) {
    final amount = exercise.isTimed
        ? '${exercise.defaultReps}s'
        : '${exercise.defaultReps} reps';
    final rest = exercise.defaultRestSeconds;
    final restLabel =
        '${rest ~/ _secondsPerMinute}:'
        '${(rest % _secondsPerMinute).toString().padLeft(2, '0')}';
    return '${exercise.defaultSets} sets × $amount · $restLabel rest';
  }

  List<MuscleFocusEntry> _musclesOf(ExerciseCatalogEntry exercise) {
    final shares = exercise.muscleShares.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final share in shares)
        MuscleFocusEntry(
          name: share.key,
          share: share.value.clamp(0.0, 1.0),
          shareLabel: share.value >= _primaryShare
              ? 'Primary'
              : share.value >= _secondaryShare
              ? 'Secondary'
              : 'Supporting',
        ),
    ];
  }

  void updateDraftName(String value) {
    if (value == _draftName) return;
    final wasSavable = canSaveDraft;
    _draftName = value;
    if (wasSavable != canSaveDraft) notifyListeners();
  }

  void selectDraftGroup(MuscleGroup group) {
    if (group == _draftGroup) return;
    _draftGroup = group;
    notifyListeners();
  }

  void selectDraftEquipment(Equipment equipment) {
    if (equipment == _draftEquipment) return;
    _draftEquipment = equipment;
    notifyListeners();
  }

  void resetDraft() {
    _draftName = '';
    _draftGroup = MuscleGroup.chest;
    _draftEquipment = Equipment.barbell;
  }

  Future<void> saveDraft() async {
    if (!canSaveDraft) return;
    final name = _draftName.trim();
    final group = _draftGroup;
    final equipment = _draftEquipment;
    _expandedGroup = group;
    resetDraft();
    notifyListeners();
    try {
      await _service.createCustomExercise(
        name: name,
        group: group,
        equipment: equipment,
      );
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
    _sessionSubscription?.cancel();
    super.dispose();
  }
}
