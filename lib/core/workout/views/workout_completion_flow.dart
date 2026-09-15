import 'package:flutter/material.dart';

import 'package:floww/core/workout/view_models/workout_completion_view_model.dart';
import 'package:floww/core/workout/views/recovery_check_in_sheet.dart';
import 'package:floww/core/workout/views/workout_complete_sheet.dart';
import 'package:floww/core/workout/views/workout_share_sheet.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class WorkoutCompletionFlow {
  WorkoutCompletionFlow._();

  static Future<void> start({
    required BuildContext context,
    required WorkoutCompletionViewModel viewModel,
  }) async {
    try {
      final action = await WorkoutCompleteSheet.show(
        context: context,
        viewModel: viewModel,
      );
      if (context.mounted && action == WorkoutCompleteAction.share) {
        await WorkoutShareSheet.show(context: context, viewModel: viewModel);
      }
      if (context.mounted) NavigationService.instance.pop();
      final exitContext = NavigationService.navigatorKey.currentContext;
      if (exitContext == null || !exitContext.mounted) return;
      await RecoveryCheckInSheet.show(
        context: exitContext,
        viewModel: viewModel,
      );
    } finally {
      viewModel.dispose();
    }
  }
}
