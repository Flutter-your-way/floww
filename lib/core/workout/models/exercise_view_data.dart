import 'package:floww/core/workout/models/exercise.dart';

class ExerciseRowItem {
  const ExerciseRowItem({
    required this.id,
    required this.name,
    required this.isCustom,
    required this.isAdded,
  });

  final String id;
  final String name;
  final bool isCustom;
  final bool isAdded;
}

class ExerciseGroupItem {
  const ExerciseGroupItem({
    required this.group,
    required this.title,
    required this.countLabel,
    required this.isExpanded,
    required this.exercises,
  });

  final MuscleGroup group;
  final String title;
  final String countLabel;
  final bool isExpanded;
  final List<ExerciseRowItem> exercises;
}
