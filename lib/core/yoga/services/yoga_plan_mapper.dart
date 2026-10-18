import 'dart:math' as math;

import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/core/yoga/data/yoga_module_data.dart';
import 'package:floww/core/yoga/data/yoga_postures_data.dart';
import 'package:floww/core/yoga/models/yoga_class_block.dart';
import 'package:floww/core/yoga/models/yoga_class_section.dart';
import 'package:floww/core/yoga/services/yoga_catalog.dart';

class YogaPlanMapper {
  YogaPlanMapper._();

  static const double _gentleHoldScale = 0.85;
  static const int _holdStep = 5;
  static const int _minHold = 15;
  static const int _gentleSuryaRounds = 2;

  static bool isCourse(String? course) => course == YogaModuleData.courseId;

  static List<WorkoutEntryEntity> entriesOf(
    YogaClassPlan plan,
    Map<String, ExerciseCatalogEntry> catalog,
  ) {
    final entries = <WorkoutEntryEntity>[];
    for (var index = 0; index < plan.blocks.length; index++) {
      final block = plan.blocks[index];
      final exercise =
          catalog[block.postureId] ?? YogaCatalog.entryOf(block.postureId);
      if (exercise == null) continue;
      entries.add(
        WorkoutEntryEntity.fromCatalog(
          exercise,
          id: block.section.entryIdFor(block.postureId, index),
          section: block.section.workoutSection,
          sets: block.repeats,
          reps: block.holdSeconds,
          restSeconds: block.transitionSeconds,
        ),
      );
    }
    return entries;
  }

  static bool isClass(List<WorkoutEntryEntity> entries) =>
      entries.isNotEmpty &&
      entries.every(
        (entry) =>
            YogaClassSection.ofEntryId(entry.id) != null &&
            YogaPosturesData.contains(entry.exerciseId),
      );

  static bool isClassPlan(WorkoutPlanEntity plan) => isClass(plan.exercises);

  static List<WorkoutEntryEntity> gentle(List<WorkoutEntryEntity> entries) => [
    for (final entry in entries)
      entry.copyWith(
        targetSets: entry.exerciseId == YogaPosturesData.suryaNamaskarId
            ? math.min(entry.targetSets, _gentleSuryaRounds)
            : entry.targetSets,
        targetReps: _isResting(entry)
            ? entry.targetReps
            : math.max(
                _minHold,
                (entry.targetReps * _gentleHoldScale / _holdStep).round() *
                    _holdStep,
              ),
      ),
  ];

  static bool _isResting(WorkoutEntryEntity entry) {
    final section = YogaClassSection.ofEntryId(entry.id);
    return section == YogaClassSection.arrival ||
        section == YogaClassSection.relaxation;
  }
}
