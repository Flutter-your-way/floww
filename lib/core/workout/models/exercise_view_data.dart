import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/models/exercise.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';

enum ExerciseScope {
  all('All'),
  saved('My Exercises'),
  trained('Done Before'),
  custom('Custom');

  const ExerciseScope(this.label);

  final String label;
}

class ExerciseRowItem {
  const ExerciseRowItem({
    required this.id,
    required this.name,
    required this.detailLabel,
    required this.isCustom,
    required this.isSaved,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String detailLabel;
  final bool isCustom;
  final bool isSaved;
  final String? imageUrl;
}

class ExerciseGroupItem {
  const ExerciseGroupItem({
    required this.group,
    required this.title,
    required this.countLabel,
    required this.isExpanded,
    required this.exercises,
    this.imageUrl,
  });

  final MuscleGroup group;
  final String title;
  final String countLabel;
  final bool isExpanded;
  final List<ExerciseRowItem> exercises;
  final String? imageUrl;
}

class ExerciseDetailItem {
  const ExerciseDetailItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.stats,
    required this.targetLabel,
    required this.muscles,
    required this.sections,
    required this.isSaved,
    required this.isCustom,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String subtitle;
  final List<WorkoutStatItem> stats;
  final String targetLabel;
  final List<MuscleFocusEntry> muscles;
  final List<ExerciseInfoSectionItem> sections;
  final bool isSaved;
  final bool isCustom;
  final String? imageUrl;
}
