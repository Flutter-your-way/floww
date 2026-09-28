import 'package:floww/core/workout/models/add_exercise_view_data.dart';

class ProgramEditorExerciseItem {
  const ProgramEditorExerciseItem({
    required this.index,
    required this.glyph,
    required this.name,
    required this.targetLabel,
  });

  final int index;
  final String glyph;
  final String name;
  final String targetLabel;
}

class ProgramEditorDayItem {
  const ProgramEditorDayItem({
    required this.weekday,
    required this.weekdayLabel,
    required this.name,
    required this.summaryLabel,
    required this.exercises,
  });

  final int weekday;
  final String weekdayLabel;
  final String name;
  final String summaryLabel;
  final List<ProgramEditorExerciseItem> exercises;
}

class ProgramExerciseEditItem {
  const ProgramExerciseEditItem({
    required this.name,
    required this.sectionLabel,
    required this.setsTarget,
    required this.repsTarget,
  });

  final String name;
  final String sectionLabel;
  final AddExerciseTargetItem setsTarget;
  final AddExerciseTargetItem repsTarget;
}
