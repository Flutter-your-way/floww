import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/widgets/effects/bottom_action_scrim.dart';
import 'package:floww/config/widgets/effects/edge_fade_mask.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/config/widgets/images/image_precacher.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/widgets/active_workout_progress_header.dart';
import 'package:floww/core/workout/widgets/rest_end_listener.dart';
import 'package:floww/core/workout/widgets/workout_finish_overlay.dart';

class ActiveWorkoutShell extends StatelessWidget {
  const ActiveWorkoutShell({
    super.key,
    required this.imageUrls,
    required this.alertEvents,
    required this.onExit,
    required this.onClose,
    required this.progress,
    required this.exerciseLabel,
    required this.setLabel,
    required this.actionBar,
    required this.showsFinishOverlay,
    required this.isFinished,
    required this.finishSummary,
    required this.children,
  });

  static const double _headerBlockHeight = AppSizes.s40;
  static const double _actionBarHeight = AppSizes.s56;

  final List<String?> imageUrls;
  final Stream<void> alertEvents;
  final VoidCallback onExit;
  final VoidCallback onClose;
  final double progress;
  final String exerciseLabel;
  final String setLabel;
  final Widget actionBar;
  final bool showsFinishOverlay;
  final bool isFinished;
  final WorkoutFinishSummary finishSummary;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.sizes.screenHorizontalPadding;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final actionsBottom = viewPadding.bottom + AppSpacing.xl;
    final contentTop =
        viewPadding.top + kToolbarHeight + _headerBlockHeight + AppSpacing.xl;

    return RestEndListener(
      events: alertEvents,
      child: ImagePrecacher(
        urls: imageUrls,
        child: Scaffold(
          backgroundColor: context.colors.backgroundPrimary,
          body: AppBackground(
            mode: AppBackgroundMode.active(context),
            isInner: true,
            safeAreaTop: false,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: EdgeFadeMask(
                    topFadeEnd: contentTop,
                    child: ListView(
                      padding: EdgeInsets.only(
                        top: contentTop,
                        bottom:
                            actionsBottom + _actionBarHeight + AppSpacing.xl3,
                        left: horizontalPadding,
                        right: horizontalPadding,
                      ),
                      children: children,
                    ),
                  ),
                ),
                Positioned(
                  top: viewPadding.top,
                  left: horizontalPadding,
                  right: horizontalPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomHeader(
                        onBackPressed: onExit,
                        onClosePressed: onClose,
                      ),
                      ActiveWorkoutProgressHeader(
                        progress: progress,
                        exerciseLabel: exerciseLabel,
                        setLabel: setLabel,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomActionScrim(
                    height:
                        viewPadding.bottom +
                        AppSizes.s72 +
                        context.sizes.bottomScrimExtra,
                  ),
                ),
                Positioned(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: actionsBottom,
                  child: actionBar,
                ),
                if (showsFinishOverlay)
                  Positioned.fill(
                    child: WorkoutFinishOverlay(
                      isDone: isFinished,
                      summary: finishSummary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
