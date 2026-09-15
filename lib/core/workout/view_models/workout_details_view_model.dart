import 'package:flutter/material.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/workout/models/add_exercise_view_data.dart';
import 'package:floww/core/workout/models/workout_detail.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/services/workout_service.dart';

class WorkoutDetailsViewModel extends ChangeNotifier {
  WorkoutDetailsViewModel(this._service, this._workoutId) {
    _detail = _service.detailFor(_workoutId);
    final sections = _detail?.sections;
    if (sections != null && sections.isNotEmpty) {
      _expandedSectionId = sections.first.id;
    }
  }

  static const int _secondsPerMinute = 60;

  final WorkoutService _service;
  final String _workoutId;

  WorkoutDetail? _detail;
  String? _expandedSectionId;
  String? _notes;
  final Map<String, List<WorkoutExercise>> _addedExercises = {};

  bool get hasDetail => _detail != null;

  String get title => 'Workout Details';

  List<AddExerciseSectionOption> get sectionOptions {
    final sections = _detail?.sections;
    if (sections == null) return const [];
    return [
      for (final section in sections)
        AddExerciseSectionOption(
          id: section.id,
          glyph: section.glyph,
          title: section.title,
        ),
    ];
  }

  String? get expandedSectionId => _expandedSectionId;

  WorkoutDetailItem? get detail {
    final detail = _detail;
    if (detail == null) return null;
    return WorkoutDetailItem(
      name: detail.name,
      dateLabel:
          '${AppDateUtils.monthDayYear(detail.performedAt)} at '
          '${AppDateUtils.time(detail.performedAt)}',
      statusLabel: detail.isCompleted ? 'Completed' : 'In Progress',
      isCompleted: detail.isCompleted,
      stats: [
        WorkoutStatItem(
          icon: Icons.schedule,
          title: 'DURATION',
          value: _durationLabel(detail.durationSeconds),
          unit: 'min',
        ),
        WorkoutStatItem(
          icon: Icons.bar_chart,
          title: 'VOLUME',
          value: NumberFormatter.grouped(detail.volumeKg + _addedVolumeKg),
          unit: 'kg',
        ),
        WorkoutStatItem(
          icon: Icons.local_fire_department,
          title: 'CALORIES',
          value: NumberFormatter.grouped(detail.calories),
          unit: 'kcal',
        ),
        WorkoutStatItem(
          icon: Icons.monitor_heart,
          title: 'AVG HEART RATE',
          value: '${detail.averageHeartRate}',
          unit: 'bpm',
        ),
      ],
      exerciseCountLabel: '${detail.exerciseCount + _addedCount} exercises',
      sections: [for (final section in detail.sections) _sectionOf(section)],
      insightTitle: 'WAVE Insight',
      insightMessage: detail.insight,
      notes: notes,
    );
  }

  String get notes => _notes ?? _detail?.notes ?? '';

  String get notesEmptyMessage => 'No notes for this session yet.';

  String get notesSheetTitle => 'Workout Notes';

  String get notesSheetSubtitle => 'Capture how this session felt';

  String get notesSheetHint =>
      'e.g. Felt strong today, increased weight on squats...';

  String get notesSheetSubmitLabel => 'Save Notes';

  int get _addedCount {
    var count = 0;
    for (final exercises in _addedExercises.values) {
      count += exercises.length;
    }
    return count;
  }

  int get _addedVolumeKg {
    var volume = 0;
    for (final exercises in _addedExercises.values) {
      for (final exercise in exercises) {
        volume += exercise.volumeKg;
      }
    }
    return volume;
  }

  WorkoutSectionItem _sectionOf(WorkoutSectionGroup section) {
    final exercises = [
      ...section.exercises,
      ...?_addedExercises[section.id],
    ];
    return WorkoutSectionItem(
      id: section.id,
      glyph: section.glyph,
      title: section.title,
      countLabel: '${exercises.length} exercises',
      status: section.status,
      isExpanded: section.id == _expandedSectionId,
      exercises: [for (final exercise in exercises) _exerciseOf(exercise)],
    );
  }

  WorkoutExerciseItem _exerciseOf(WorkoutExercise exercise) {
    return WorkoutExerciseItem(
      id: exercise.id,
      name: exercise.name,
      setsLabel: '${exercise.sets} sets x ${exercise.reps} reps',
      weightLabel: exercise.isBodyweight
          ? 'BW'
          : '${_weightLabel(exercise.weightKg!)} kg',
      restLabel: _durationLabel(exercise.restSeconds),
      volumeLabel: exercise.isBodyweight
          ? '—'
          : NumberFormatter.grouped(exercise.volumeKg),
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

  void updateNotes(String value) {
    _notes = value.trim();
    notifyListeners();
  }

  void addExercise(String sectionId, WorkoutExercise exercise) {
    _addedExercises.putIfAbsent(sectionId, () => []).add(exercise);
    _expandedSectionId = sectionId;
    notifyListeners();
  }
}
