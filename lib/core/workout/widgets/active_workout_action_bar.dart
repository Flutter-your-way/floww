import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';

class ActiveWorkoutActionBar extends StatelessWidget {
  const ActiveWorkoutActionBar({
    super.key,
    required this.label,
    required this.isResting,
    required this.isPaused,
    required this.onPrimary,
    required this.onTogglePause,
    required this.onSkip,
  });

  static const double _buttonSize = AppSizes.s56;

  final String label;
  final bool isResting;
  final bool isPaused;
  final VoidCallback onPrimary;
  final VoidCallback onTogglePause;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircularHeaderButton(
          icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          size: _buttonSize,
          iconColor: context.colors.textSecondary,
          backgroundColor: context.colors.surfaceTranslucent,
          borderColor: context.colors.borderMedium,
          onPressed: onTogglePause,
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: PillButton(
            variant: isResting
                ? PillButtonVariant.outline
                : PillButtonVariant.primary,
            height: _buttonSize,
            label: label,
            onPressed: onPrimary,
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        CircularHeaderButton(
          icon: Icons.skip_next_rounded,
          size: _buttonSize,
          iconColor: context.colors.textSecondary,
          backgroundColor: context.colors.surfaceTranslucent,
          borderColor: context.colors.borderMedium,
          onPressed: onSkip,
        ),
      ],
    );
  }
}
