import 'package:flutter/material.dart';

enum WorkoutCourseAction { openYogaCourse, openLibrary }

enum WorkoutCourseSegmentState { done, current, upcoming }

class WorkoutCourseFact {
  const WorkoutCourseFact({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class WorkoutCourseItem {
  const WorkoutCourseItem({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.segments,
    required this.facts,
    required this.actionLabel,
    required this.action,
    this.badgeLabel,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<WorkoutCourseSegmentState> segments;
  final List<WorkoutCourseFact> facts;
  final String actionLabel;
  final WorkoutCourseAction action;
  final String? badgeLabel;
}
