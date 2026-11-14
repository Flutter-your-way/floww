import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/program_row_card.dart';
import 'package:floww/core/workout/widgets/program_section_heading.dart';
import 'package:floww/core/workout/widgets/workout_photo_card.dart';

class ChallengeBoardSection extends StatelessWidget {
  const ChallengeBoardSection({
    super.key,
    required this.board,
    required this.onOpen,
  });

  static const double _weeklyAspectRatio = 1.5;

  final ChallengeBoardItem board;
  final ValueChanged<String> onOpen;

  void _open(String id) {
    HapticManager.light();
    onOpen(id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final weekly = board.weekly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: ProgramSectionHeading(label: 'This week\'s challenge'),
            ),
            Text(
              board.progressLabel,
              style: AppTypography.captionSemiBold.copyWith(
                color: colors.primaryAlt,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        AspectRatio(
          aspectRatio: _weeklyAspectRatio,
          child: WorkoutPhotoCard(
            imageUrl: weekly.imageUrl,
            onTap: () => _open(weekly.id),
            topTrailing: weekly.isDone ? const _DoneBadge() : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weekly.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppTypography.photoCardTitle.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  weekly.metaLabel,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLargeRegular.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          board.rewardLabel,
          style: AppTypography.bodySmallRegularTight.copyWith(
            color: colors.textSecondary,
          ),
        ),
        if (board.others.isNotEmpty) ...[
          SizedBox(height: AppSpacing.xl3),
          const ProgramSectionHeading(label: 'More challenges'),
          SizedBox(height: AppSpacing.lg),
        ],
        for (var i = 0; i < board.others.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.lg),
          ProgramRowCard(
            program: board.others[i],
            onTap: () => _open(board.others[i].id),
          ),
        ],
      ],
    );
  }
}

class _DoneBadge extends StatelessWidget {
  const _DoneBadge();

  static const String _label = 'DONE';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: AppShapes.decoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_rounded,
            size: AppSizes.s12,
            color: colors.backgroundPrimary,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            _label,
            style: AppTypography.captionSemiBold.copyWith(
              color: colors.backgroundPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
