import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/core/workout/models/workout_completion_view_data.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/view_models/workout_completion_view_model.dart';
import 'package:floww/core/workout/widgets/completion_stat_box.dart';
import 'package:floww/core/workout/widgets/workout_flow_score_card.dart';

enum WorkoutCompleteAction { share, done }

class WorkoutCompleteSheet extends StatelessWidget {
  const WorkoutCompleteSheet({super.key});

  static const double _glyphCircle = AppSizes.s96;

  static Future<WorkoutCompleteAction?> show({
    required BuildContext context,
    required WorkoutCompletionViewModel viewModel,
  }) {
    return showAppFloatingSheet<WorkoutCompleteAction>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const WorkoutCompleteSheet(),
      ),
    );
  }

  void _close(BuildContext context, WorkoutCompleteAction action) {
    HapticManager.light();
    Navigator.of(context).pop(action);
  }

  @override
  Widget build(BuildContext context) {
    final summary = context
        .select<WorkoutCompletionViewModel, WorkoutCompleteItem>(
          (viewModel) => viewModel.summary,
        );
    final colors = context.colors;

    return AppFloatingSheet(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CircularHeaderButton(
                icon: Icons.close_rounded,
                size: AppSizes.s40,
                iconSize: AppSizes.s20,
                backgroundColor: colors.backgroundPrimary,
                onPressed: () => _close(context, WorkoutCompleteAction.done),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Center(
              child: Container(
                width: _glyphCircle,
                height: _glyphCircle,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.bgTinted,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.borderGlow,
                    width: AppSizes.s1,
                  ),
                ),
                child: Text(summary.glyph, style: AppTypography.heading1),
              ),
            ),
            SizedBox(height: AppSpacing.xl2),
            Text(
              summary.title,
              textAlign: TextAlign.center,
              style: AppTypography.heading1.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              summary.message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLargeMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xl2),
            WorkoutFlowScoreCard(summary: summary),
            SizedBox(height: AppSpacing.lg),
            _CompletionStatsRow(stats: summary.stats),
            SizedBox(height: AppSpacing.xl2),
            _CompletionActions(
              summary: summary,
              onShare: () => _close(context, WorkoutCompleteAction.share),
              onDone: () => _close(context, WorkoutCompleteAction.done),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionStatsRow extends StatelessWidget {
  const _CompletionStatsRow({required this.stats});

  final List<WorkoutStatItem> stats;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) SizedBox(width: AppSpacing.lg),
            Expanded(child: CompletionStatBox(stat: stats[i])),
          ],
        ],
      ),
    );
  }
}

class _CompletionActions extends StatelessWidget {
  const _CompletionActions({
    required this.summary,
    required this.onShare,
    required this.onDone,
  });

  static const int _shareFlex = 2;
  static const int _doneFlex = 3;

  final WorkoutCompleteItem summary;
  final VoidCallback onShare;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: _shareFlex,
          child: PillButton(
            variant: PillButtonVariant.neutral,
            label: summary.shareLabel,
            icon: Icons.ios_share_rounded,
            onPressed: onShare,
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          flex: _doneFlex,
          child: PillButton(label: summary.doneLabel, onPressed: onDone),
        ),
      ],
    );
  }
}
