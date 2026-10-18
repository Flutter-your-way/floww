import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/core/workout/view_models/active_workout_view_model.dart';
import 'package:floww/core/workout/widgets/active_workout_action_bar.dart';
import 'package:floww/core/workout/widgets/active_workout_shell.dart';
import 'package:floww/core/workout/widgets/rest_end_listener.dart';
import 'package:floww/core/workout/widgets/rest_timer_card.dart';
import 'package:floww/core/yoga/models/yoga_class_view_data.dart';
import 'package:floww/core/yoga/view_models/yoga_class_view_model.dart';
import 'package:floww/core/yoga/views/yoga_pose_lesson_sheet.dart';
import 'package:floww/core/yoga/widgets/yoga_hold_card.dart';
import 'package:floww/core/yoga/widgets/yoga_pose_hero_card.dart';
import 'package:floww/core/yoga/widgets/yoga_section_timeline.dart';

class YogaClassView extends StatelessWidget {
  const YogaClassView({
    super.key,
    required this.onExit,
    required this.onCancel,
    required this.onFinishEarly,
  });

  final VoidCallback onExit;
  final VoidCallback onCancel;
  final VoidCallback onFinishEarly;

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<ActiveWorkoutViewModel>();

    return Consumer<YogaClassViewModel>(
      builder: (context, viewModel, child) {
        final item = viewModel.item;

        return RestEndListener(
          events: viewModel.holdEnded,
          child: ActiveWorkoutShell(
            imageUrls: workout.imageUrls,
            alertEvents: workout.restEnded,
            onExit: onExit,
            onClose: onCancel,
            progress: item?.progress ?? 1,
            exerciseLabel: item?.poseCounterLabel ?? '',
            setLabel: item?.sectionLabel ?? '',
            showsFinishOverlay: workout.showsFinishOverlay,
            isFinished: workout.isFinished,
            finishSummary: workout.finishSummary,
            actionBar: ActiveWorkoutActionBar(
              label: item?.primaryLabel ?? 'Next',
              isResting: item?.isTransition ?? false,
              isPaused: item?.isPaused ?? false,
              onPrimary: () {
                HapticManager.medium();
                viewModel.next();
              },
              onTogglePause: () {
                HapticManager.light();
                viewModel.togglePause();
              },
              onSkip: () {
                HapticManager.light();
                viewModel.skipPose();
              },
            ),
            children: [
              if (item == null)
                const AppSectionLoader()
              else
                _YogaClassContent(
                  item: item,
                  onAdjustTransition: (steps) {
                    HapticManager.selection();
                    workout.adjustRest(steps);
                  },
                  onSkipTransition: workout.skipRest,
                  onOpenLesson: () => YogaPoseLessonSheet.show(
                    context: context,
                    postureId: item.postureId,
                    profile: viewModel.profile,
                  ),
                  onFinishEarly: workout.canFinishEarly ? onFinishEarly : null,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _YogaClassContent extends StatelessWidget {
  const _YogaClassContent({
    required this.item,
    required this.onAdjustTransition,
    required this.onSkipTransition,
    required this.onOpenLesson,
    required this.onFinishEarly,
  });

  final YogaClassItem item;
  final ValueChanged<int> onAdjustTransition;
  final VoidCallback onSkipTransition;
  final VoidCallback onOpenLesson;
  final VoidCallback? onFinishEarly;

  @override
  Widget build(BuildContext context) {
    final modificationNote = item.modificationNote;
    final onFinishEarly = this.onFinishEarly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YogaSectionTimeline(sections: item.sections),
        SizedBox(height: AppSpacing.xl),
        if (item.isTransition)
          RestTimerCard(
            title: 'TRANSITION',
            secondsLabel: item.transitionLabel,
            nextUpLabel: item.nextUpLabel,
            canShorten: true,
            onSkip: onSkipTransition,
            onAdjust: onAdjustTransition,
          )
        else ...[
          YogaPoseHeroCard(
            name: item.poseName,
            sanskritName: item.sanskritName,
            imageUrl: item.imageUrl,
            sectionLabel: item.sectionTitle,
            badgeLabel: item.repeatLabel,
            onInfo: onOpenLesson,
          ),
          SizedBox(height: AppSpacing.xl),
          YogaHoldCard(
            holdLabel: item.holdLabel,
            progress: item.holdProgress,
            isPaused: item.isPaused,
            breathCue: item.breathCue,
            step: item.step,
          ),
          SizedBox(height: AppSpacing.lg),
          TipCard.inline(
            title: 'Cue',
            message: item.cue,
            icon: Icons.accessibility_new_rounded,
          ),
          if (modificationNote != null) ...[
            SizedBox(height: AppSpacing.lg),
            TipCard.inline(
              title: 'Your modification',
              message: modificationNote,
              icon: Icons.health_and_safety_outlined,
            ),
          ],
          SizedBox(height: AppSpacing.lg),
          TipCard.note(title: item.nextUpLabel, icon: Icons.east_rounded),
        ],
        SizedBox(height: AppSpacing.xl),
        PillButton(
          variant: PillButtonVariant.outline,
          label: 'Lesson & modifications',
          icon: Icons.menu_book_rounded,
          onPressed: onOpenLesson,
        ),
        if (onFinishEarly != null) ...[
          SizedBox(height: AppSpacing.lg),
          PillButton(
            variant: PillButtonVariant.neutral,
            label: 'End class early',
            icon: Icons.flag_outlined,
            onPressed: onFinishEarly,
          ),
        ],
      ],
    );
  }
}
