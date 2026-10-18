import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/core/calisthenics/models/cal_level.dart';
import 'package:floww/core/calisthenics/services/calisthenics_plan_mapper.dart';
import 'package:floww/core/yoga/services/yoga_plan_mapper.dart';

enum WorkoutDiscipline {
  gym(
    'gym',
    startLabel: 'Start Workout',
    sessionNoun: 'workout',
    sessionsNoun: 'workouts',
    itemNoun: 'exercise',
    itemsNoun: 'exercises',
    icon: Icons.fitness_center,
  ),
  calisthenics(
    'calisthenics',
    startLabel: 'Start Session',
    sessionNoun: 'session',
    sessionsNoun: 'sessions',
    itemNoun: 'move',
    itemsNoun: 'moves',
    icon: Icons.sports_gymnastics,
  ),
  yoga(
    'yoga',
    startLabel: 'Start Class',
    sessionNoun: 'class',
    sessionsNoun: 'classes',
    itemNoun: 'pose',
    itemsNoun: 'poses',
    icon: Icons.self_improvement,
  );

  const WorkoutDiscipline(
    this.id, {
    required this.startLabel,
    required this.sessionNoun,
    required this.sessionsNoun,
    required this.itemNoun,
    required this.itemsNoun,
    required this.icon,
  });

  static const String _answerKey = 'training_type';

  final String id;
  final String startLabel;
  final String sessionNoun;
  final String sessionsNoun;
  final String itemNoun;
  final String itemsNoun;
  final IconData icon;

  String countLabel(int count) => '$count ${count == 1 ? itemNoun : itemsNoun}';

  bool matches(WorkoutProgramEntity program) => switch (this) {
    WorkoutDiscipline.yoga => YogaPlanMapper.isCourse(program.course),
    WorkoutDiscipline.calisthenics => CalLevel.fromCourse(program.course) != null,
    WorkoutDiscipline.gym => program.course == null,
  };

  static WorkoutDiscipline ofProgram(WorkoutProgramEntity program) {
    if (YogaPlanMapper.isCourse(program.course)) return WorkoutDiscipline.yoga;
    if (CalLevel.fromCourse(program.course) != null) {
      return WorkoutDiscipline.calisthenics;
    }
    return WorkoutDiscipline.gym;
  }

  static WorkoutDiscipline ofPlan(WorkoutPlanEntity plan) {
    if (YogaPlanMapper.isClassPlan(plan)) return WorkoutDiscipline.yoga;
    if (CalisthenicsPlanMapper.isPlan(plan)) {
      return WorkoutDiscipline.calisthenics;
    }
    return WorkoutDiscipline.gym;
  }

  static WorkoutDiscipline fromAnswers(Map<String, dynamic> answers) {
    final value = answers[_answerKey];
    final type = switch (value) {
      List(isNotEmpty: true) => value.first.toString(),
      String() => value,
      _ => '',
    }.trim().toLowerCase();
    for (final discipline in values) {
      if (discipline.id == type) return discipline;
    }
    return WorkoutDiscipline.gym;
  }
}
