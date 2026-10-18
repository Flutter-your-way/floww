import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/core/calisthenics/data/calisthenics_gates_data.dart';
import 'package:floww/core/calisthenics/data/calisthenics_program_data.dart';
import 'package:floww/core/calisthenics/models/cal_level.dart';
import 'package:floww/core/calisthenics/models/cal_slot.dart';
import 'package:floww/core/calisthenics/services/calisthenics_course_service.dart';
import 'package:floww/core/calisthenics/services/calisthenics_placement.dart';
import 'package:floww/core/workout/models/workout_course_view_data.dart';
import 'package:floww/core/yoga/data/yoga_module_data.dart';
import 'package:floww/core/yoga/services/yoga_course_service.dart';

class WorkoutCoursePresenter {
  WorkoutCoursePresenter._();

  static const int _percent = 100;

  static WorkoutCourseItem yoga({
    required ActiveProgramEntry active,
    required DateTime date,
    required Map<String, dynamic> answers,
  }) {
    final profile = YogaCourseService.profileOf(answers);
    final week = YogaCourseService.weekOf(active, date, profile);
    final courseWeek = YogaModuleData.weekAt(week);
    final total = YogaModuleData.weeks.length;
    return WorkoutCourseItem(
      eyebrow: '${YogaModuleData.brand} HATHA COURSE',
      title: 'Week $week of $total · ${courseWeek.title}',
      subtitle: courseWeek.summary,
      segments: _segmentsOf(week, total),
      facts: [
        const WorkoutCourseFact(
          icon: Icons.self_improvement,
          text: YogaModuleData.motto,
        ),
        for (final caution in profile.cautions)
          if (YogaModuleData.cautionNotes[caution] case final note?)
            WorkoutCourseFact(icon: Icons.health_and_safety_outlined, text: note),
        if (week >= total)
          const WorkoutCourseFact(
            icon: Icons.schedule_rounded,
            text: YogaModuleData.teachingNote,
          ),
      ],
      actionLabel: 'Course & asana library',
      action: WorkoutCourseAction.openYogaCourse,
    );
  }

  static WorkoutCourseItem calisthenics({
    required CalLevel level,
    required ActiveProgramEntry active,
    required DateTime date,
    required Map<String, dynamic> answers,
  }) {
    final weekNumber = active.weekAt(date).clamp(1, level.weeks);
    final week = CalisthenicsProgramData.weekOf(level, weekNumber);
    final results = CalisthenicsCourseService.profileOf(answers).results;
    final next = level.next;
    return WorkoutCourseItem(
      eyebrow: 'CALISTHENICS · ${level.label.toUpperCase()}',
      title: '${level.title} · ${level.focus}',
      subtitle:
          'Week $weekNumber of ${level.weeks} · ${week.phase} · '
          '${week.effort}. ${week.note}',
      badgeLabel: week.isRetest
          ? 'Retest week'
          : week.isDeload
          ? 'Deload week'
          : null,
      segments: _segmentsOf(weekNumber, level.weeks),
      facts: [
        WorkoutCourseFact(
          icon: Icons.trending_up_rounded,
          text: next == null
              ? 'Top level. Rotate skill priorities each 12-week block.'
              : _gateTextOf(next, results),
        ),
        WorkoutCourseFact(
          icon: Icons.bar_chart_rounded,
          text: 'Weekly working sets (${week.percent}% volume): '
              '${_volumeOf(level, week.setsFor)}',
        ),
        WorkoutCourseFact(icon: Icons.flag_outlined, text: level.goal),
        WorkoutCourseFact(
          icon: Icons.bedtime_outlined,
          text: level.restGuidance,
        ),
      ],
      actionLabel: 'Progressions & moves',
      action: WorkoutCourseAction.openLibrary,
    );
  }

  static String _gateTextOf(CalLevel next, Map<String, double> results) {
    final score = CalisthenicsPlacement.scoreOf(next, results);
    final needed =
        (score.counted * CalisthenicsGatesData.passThreshold).ceil();
    return '${next.label} gates: ${score.passed} of ${score.counted} cleared '
        '(${(CalisthenicsGatesData.passThreshold * _percent).round()}% = '
        '$needed to move up). Update your tests in retest week.';
  }

  static String _volumeOf(CalLevel level, int Function(int sets) setsFor) {
    final totals = <CalPattern, int>{};
    for (final session in CalisthenicsProgramData.sessionsOf(level)) {
      for (final slot in session.slots) {
        if (!slot.pattern.countsTowardVolume) continue;
        totals[slot.pattern] = (totals[slot.pattern] ?? 0) + setsFor(slot.sets);
      }
    }
    return [
      for (final pattern in CalPattern.values)
        if (totals[pattern] case final sets?) '${pattern.label} $sets',
    ].join(' · ');
  }

  static List<WorkoutCourseSegmentState> _segmentsOf(int current, int total) => [
    for (var week = 1; week <= total; week++)
      week < current
          ? WorkoutCourseSegmentState.done
          : week == current
          ? WorkoutCourseSegmentState.current
          : WorkoutCourseSegmentState.upcoming,
  ];
}
