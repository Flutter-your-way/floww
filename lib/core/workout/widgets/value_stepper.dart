import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/workout/models/add_exercise_view_data.dart';

class ValueStepper extends StatelessWidget {
  const ValueStepper({super.key, required this.target, this.onAdjust});

  final AddExerciseTargetItem target;
  final ValueChanged<int>? onAdjust;

  void _adjust(int delta) {
    HapticManager.selection();
    onAdjust?.call(delta);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onAdjust = this.onAdjust;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            target.label.toUpperCase(),
            style: AppTypography.captionSemiBold.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepperButton(
                icon: Icons.remove,
                isEnabled: onAdjust != null && target.canDecrease,
                onTap: () => _adjust(-1),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      target.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLargeSemiBoldTight.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    if (target.unit.isNotEmpty)
                      Text(
                        target.unit,
                        style: AppTypography.captionMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              _StepperButton(
                icon: Icons.add,
                isEnabled: onAdjust != null && target.canIncrease,
                onTap: () => _adjust(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: AppSizes.s28,
        height: AppSizes.s28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isEnabled ? colors.bgTinted : colors.backgroundElevated,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: AppSizes.s16,
          color: isEnabled ? colors.primaryAlt : colors.textFaint,
        ),
      ),
    );
  }
}
