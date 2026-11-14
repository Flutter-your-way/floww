import 'package:flutter/widgets.dart';

import 'package:floww/core/workout/view_models/workout_view_model.dart';

class ProgramListArgs {
  const ProgramListArgs({required this.viewModel, required this.onOpenProgram});

  final WorkoutViewModel viewModel;
  final void Function(BuildContext context, String programId) onOpenProgram;
}
