import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/workout/view_models/active_workout_view_model.dart';
import 'package:floww/core/workout/widgets/workout_queue_row.dart';

class WorkoutQueueSheet extends StatelessWidget {
  const WorkoutQueueSheet({super.key});

  static const double _listMaxHeight = AppSizes.s160 * 2;

  static Future<void> show(
    BuildContext context,
    ActiveWorkoutViewModel viewModel,
  ) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const WorkoutQueueSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveWorkoutViewModel>(
      builder: (context, viewModel, child) {
        final queue = viewModel.queue;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: viewModel.queueTitle,
            subtitle: viewModel.queueSubtitle,
            onClose: () => Navigator.of(context).maybePop(),
            body: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: _listMaxHeight),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                itemCount: queue.length,
                onReorderItem: (oldIndex, newIndex) {
                  HapticManager.selection();
                  viewModel.reorder(oldIndex, newIndex);
                },
                itemBuilder: (context, index) => Padding(
                  key: ValueKey(queue[index].id),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: WorkoutQueueRow(
                    item: queue[index],
                    dragHandle: ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_handle_rounded,
                        size: AppSizes.s20,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    onTap: () {
                      HapticManager.selection();
                      viewModel.jumpTo(queue[index].id);
                      Navigator.of(context).maybePop();
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
