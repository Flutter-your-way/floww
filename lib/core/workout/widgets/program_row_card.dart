import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_icon_tile.dart';

class ProgramRowCard extends StatelessWidget {
  const ProgramRowCard({super.key, required this.program, this.onStart});

  final ProgramItem program;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          const WorkoutIconTile(),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  program.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.headlineSmall,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  program.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          _StartProgramButton(onTap: onStart),
        ],
      ),
    );
  }
}

class _StartProgramButton extends StatelessWidget {
  const _StartProgramButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: AppSizes.s36,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: AppShapes.decoration(
          color: context.colors.backgroundElevated,
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: context.colors.borderMedium, width: 1),
        ),
        child: Text(
          'Start',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }
}
