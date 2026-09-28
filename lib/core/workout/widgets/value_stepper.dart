import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/workout/models/add_exercise_view_data.dart';

class ValueStepper extends StatefulWidget {
  const ValueStepper({super.key, required this.target, this.onAdjust});

  final AddExerciseTargetItem target;
  final ValueChanged<int>? onAdjust;

  @override
  State<ValueStepper> createState() => _ValueStepperState();
}

class _ValueStepperState extends State<ValueStepper> {
  int _direction = 1;

  void _adjust(int delta) {
    HapticManager.selection();
    if (_direction != delta) setState(() => _direction = delta);
    widget.onAdjust?.call(delta);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onAdjust = widget.onAdjust;
    final target = widget.target;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
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
          SizedBox(height: AppSpacing.sm),
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
                    _StepperValue(value: target.value, direction: _direction),
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

class _StepperValue extends StatelessWidget {
  const _StepperValue({required this.value, required this.direction});

  final String value;
  final int direction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRect(
      child: AnimatedSwitcher(
        duration: AppMotion.stepper,
        switchInCurve: AppMotion.stepperCurve,
        switchOutCurve: AppMotion.stepperExitCurve,
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: Alignment.center,
          children: [...previousChildren, ?currentChild],
        ),
        transitionBuilder: (child, animation) {
          final isIncoming = (child.key as ValueKey<String>).value == value;
          final offset =
              (isIncoming ? direction : -direction) * AppMotion.stepperSlide;

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, offset),
                end: Offset.zero,
              ).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: AppMotion.stepperScale,
                  end: 1,
                ).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: Text(
          value,
          key: ValueKey<String>(value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelMediumSemiBold.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatefulWidget {
  const _StepperButton({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!widget.isEnabled || _isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = widget.isEnabled;

    return GestureDetector(
      onTap: isEnabled ? widget.onTap : null,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? AppMotion.stepperPressScale : 1,
        duration: AppMotion.press,
        curve: AppMotion.stepperCurve,
        child: AnimatedContainer(
          duration: AppMotion.press,
          curve: AppMotion.expandCurve,
          width: AppSizes.s24,
          height: AppSizes.s24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: !isEnabled
                ? colors.backgroundElevated
                : _isPressed
                ? colors.tint
                : colors.bgTinted,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            size: AppSizes.s16,
            color: isEnabled ? colors.primaryAlt : colors.textFaint,
          ),
        ),
      ),
    );
  }
}
