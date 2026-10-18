import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/calisthenics/models/cal_library_view_data.dart';

class CalLadderCard extends StatelessWidget {
  const CalLadderCard({super.key, required this.ladder, required this.onOpen});

  static const double _levelWidth = AppSizes.s28;

  final CalLadderItem ladder;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ladder.name,
            style: AppTypography.bodyLargeSemiBoldTight.copyWith(
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Easiest → hardest. Hit the standard, then move one step up.',
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: colors.textTertiary,
            ),
          ),
          for (final step in ladder.steps) ...[
            SizedBox(height: AppSpacing.md),
            PressScale(
              onTap: () => onOpen(step.moveId),
              child: Row(
                children: [
                  SizedBox(
                    width: _levelWidth,
                    child: Text(
                      step.levelLabel,
                      style: AppTypography.captionSemiBold.copyWith(
                        color: step.isYourLevel
                            ? colors.primary
                            : colors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step.name,
                      style: AppTypography.bodyMediumMedium.copyWith(
                        color: step.isYourLevel
                            ? colors.textPrimary
                            : colors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Text(
                    step.standard,
                    style: AppTypography.captionSemiBold.copyWith(
                      color: step.isYourLevel
                          ? colors.primary
                          : colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
