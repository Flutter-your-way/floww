import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';
import 'package:floww/core/workout/view_models/active_workout_view_model.dart';
import 'package:floww/core/yoga/data/yoga_module_data.dart';
import 'package:floww/core/yoga/data/yoga_postures_data.dart';
import 'package:floww/core/yoga/models/surya_namaskar_step.dart';
import 'package:floww/core/yoga/models/yoga_class_section.dart';
import 'package:floww/core/yoga/models/yoga_class_view_data.dart';
import 'package:floww/core/yoga/models/yoga_posture.dart';
import 'package:floww/core/yoga/models/yoga_profile.dart';
import 'package:floww/core/yoga/services/yoga_course_service.dart';

class YogaClassViewModel extends ChangeNotifier {
  YogaClassViewModel(this._workout, this._courseService) {
    _workout.addListener(_onWorkoutChanged);
    _timer = Timer.periodic(_tick, (_) => _onTick());
    unawaited(_loadProfile());
    _sync();
  }

  static const Duration _tick = Duration(seconds: 1);
  static const int _minLoggedSeconds = 1;
  static const int _pairedSides = 2;

  final ActiveWorkoutViewModel _workout;
  final YogaCourseService _courseService;
  final StreamController<void> _holdEnded = StreamController<void>.broadcast();

  Timer? _timer;
  YogaProfile _profile = YogaProfile.standard;
  String? _holdKey;
  int _holdTotal = 0;
  int _holdRemaining = 0;
  bool _disposed = false;

  Stream<void> get holdEnded => _holdEnded.stream;

  YogaProfile get profile => _profile;

  List<SuryaNamaskarStep> get _suryaSteps => [
    for (final step in YogaModuleData.suryaSteps)
      if (!step.isSkippedFor(_profile.cautions)) step,
  ];

  Future<void> _loadProfile() async {
    _profile = await _courseService.loadProfile();
    notifyListeners();
  }

  void _onWorkoutChanged() {
    _sync();
    notifyListeners();
  }

  String? _keyOf(WorkoutEntryEntity? entry) =>
      entry == null ? null : '${entry.id}:${entry.sets.length}';

  void _sync() {
    final entry = _workout.currentEntry;
    final key = _keyOf(entry);
    if (key == _holdKey) return;
    _holdKey = key;
    _holdTotal = entry?.targetReps ?? 0;
    _holdRemaining = _holdTotal;
  }

  bool get _isRunning =>
      !_workout.isLoading &&
      !_workout.isFinishing &&
      !_workout.isFinished &&
      !_workout.isResting &&
      !_workout.isPaused &&
      _workout.currentEntry != null;

  void _onTick() {
    if (!_isRunning) return;
    _holdRemaining--;
    if (_holdRemaining <= 0) {
      _holdEnded.add(null);
      _completeHold();
      return;
    }
    notifyListeners();
  }

  void _completeHold() {
    final elapsed = math.max(_minLoggedSeconds, _holdTotal - _holdRemaining);
    _holdRemaining = 0;
    _workout.completeTimedSet(elapsed);
  }

  void next() {
    if (_workout.isResting) {
      _workout.skipRest();
      return;
    }
    if (_workout.currentEntry == null) return;
    _completeHold();
  }

  void togglePause() => _workout.togglePause();

  void skipPose() => _workout.skipExercise();

  YogaClassItem? get item {
    final entry = _workout.currentEntry;
    if (entry == null) return null;
    final posture = YogaPosturesData.byId(entry.exerciseId);
    if (posture == null) return null;
    final entries = _workout.entries;
    final section =
        YogaClassSection.ofEntryId(entry.id) ?? YogaClassSection.standing;
    final index = entries.indexOf(entry);
    final isTransition = _workout.isResting;
    final elapsed = _holdTotal - _holdRemaining;
    final step = _stepOf(entry, elapsed);

    return YogaClassItem(
      postureId: posture.id,
      sections: _chipsOf(entries, section),
      sectionTitle: section.title,
      sectionRange: section.rangeLabel,
      poseName: posture.name,
      sanskritName: posture.sanskritName,
      imageUrl: posture.imageUrl,
      cue: posture.alignmentCues.first,
      breathCue: posture.breathCues.first,
      repeatLabel: _repeatLabelOf(entry, posture, _currentSet(entry)),
      holdLabel: NumberFormatter.clock(math.max(0, _holdRemaining)),
      holdProgress: _holdTotal == 0 ? 0 : elapsed / _holdTotal,
      isTransition: isTransition,
      transitionLabel: NumberFormatter.clock(_workout.restRemaining),
      nextUpLabel: _nextUpLabelOf(entry, posture, entries, index, isTransition),
      progress: _progressOf(entries),
      poseCounterLabel: 'Pose ${index + 1} of ${entries.length}',
      sectionLabel: '${section.title} · ${section.rangeLabel}',
      primaryLabel: isTransition ? 'Begin Now' : 'Next',
      isPaused: _workout.isPaused,
      step: step,
      modificationNote: _modificationOf(posture),
    );
  }

  List<YogaSectionChipItem> _chipsOf(
    List<WorkoutEntryEntity> entries,
    YogaClassSection current,
  ) {
    final order = <YogaClassSection>[];
    final done = <YogaClassSection, bool>{};
    for (final entry in entries) {
      final section = YogaClassSection.ofEntryId(entry.id);
      if (section == null) continue;
      if (!order.contains(section)) order.add(section);
      done[section] = (done[section] ?? true) && entry.isDone;
    }
    return [
      for (final section in order)
        YogaSectionChipItem(
          label: section.title,
          status: section == current
              ? WorkoutSectionStatus.active
              : done[section] == true
              ? WorkoutSectionStatus.completed
              : WorkoutSectionStatus.pending,
        ),
    ];
  }

  YogaStepItem? _stepOf(WorkoutEntryEntity entry, int elapsed) {
    if (entry.exerciseId != YogaPosturesData.suryaNamaskarId) return null;
    final steps = _suryaSteps;
    if (steps.isEmpty || _holdTotal == 0) return null;
    final index = math.min(
      steps.length - 1,
      elapsed * steps.length ~/ _holdTotal,
    );
    final step = steps[index];
    return YogaStepItem(
      counterLabel: 'Step ${index + 1} of ${steps.length}',
      title: step.title,
      instruction: step.instruction,
    );
  }

  int _currentSet(WorkoutEntryEntity entry) =>
      math.min(entry.workingSetCount + 1, entry.targetSets);

  String _repeatLabelOf(WorkoutEntryEntity entry, YogaPosture posture, int set) {
    if (posture.isPerSide) {
      final side = set.isOdd ? 'Right side' : 'Left side';
      final pairs = entry.targetSets ~/ _pairedSides;
      return pairs > 1 ? '$side · ${(set + 1) ~/ _pairedSides} of $pairs' : side;
    }
    if (entry.targetSets > 1) return 'Round $set of ${entry.targetSets}';
    return 'Hold';
  }

  String _nextUpLabelOf(
    WorkoutEntryEntity entry,
    YogaPosture posture,
    List<WorkoutEntryEntity> entries,
    int index,
    bool isTransition,
  ) {
    final current = _currentSet(entry);
    if (isTransition) {
      return 'Up next: ${posture.name} · '
          '${_repeatLabelOf(entry, posture, current)}';
    }
    if (current < entry.targetSets) {
      return 'Up next: ${posture.name} · '
          '${_repeatLabelOf(entry, posture, current + 1)}';
    }
    for (var next = index + 1; next < entries.length; next++) {
      final candidate = entries[next];
      if (candidate.isDone) continue;
      final nextPosture = YogaPosturesData.byId(candidate.exerciseId);
      return 'Up next: ${nextPosture?.name ?? candidate.name}';
    }
    return 'Final pose';
  }

  double _progressOf(List<WorkoutEntryEntity> entries) {
    var planned = 0;
    var logged = 0;
    for (final entry in entries) {
      planned += entry.targetSets;
      logged += entry.isSkipped
          ? entry.targetSets
          : math.min(entry.workingSetCount, entry.targetSets);
    }
    return planned == 0 ? 0 : logged / planned;
  }

  String? _modificationOf(YogaPosture posture) {
    for (final modification in posture.modifications) {
      final caution = modification.caution;
      if (caution != null && _profile.cautions.contains(caution)) {
        return modification.text;
      }
    }
    return null;
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _workout.removeListener(_onWorkoutChanged);
    _holdEnded.close();
    super.dispose();
  }
}
