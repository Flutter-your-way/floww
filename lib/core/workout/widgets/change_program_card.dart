import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/core/workout/widgets/wave_logo_tile.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';

class ChangeProgramCard extends StatelessWidget {
  const ChangeProgramCard({
    super.key,
    required this.icon,
    required this.programName,
    required this.actionLabel,
    required this.onTap,
    this.isWave = false,
  });

  final IconData icon;
  final bool isWave;
  final String programName;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            if (isWave)
              const WaveLogoTile()
            else
              AppIconTile(
                icon: icon,
                backgroundColor: colors.bgTinted,
                iconColor: colors.primaryAlt,
              ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current program',
                    style: AppTypography.captionSemiBold.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    programName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLargeSemiBoldTight.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            WorkoutChip(
              label: actionLabel,
              icon: Icons.swap_horiz_rounded,
              tone: WorkoutChipTone.accent,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
