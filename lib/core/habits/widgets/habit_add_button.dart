import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';

class HabitAddButton extends StatefulWidget {
  const HabitAddButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  State<HabitAddButton> createState() => _HabitAddButtonState();
}

class _HabitAddButtonState extends State<HabitAddButton> {
  static const _pressDuration = Duration(milliseconds: 120);

  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed != null && value != _pressed) {
      setState(() => _pressed = value);
    }
  }

  void _press() {
    HapticManager.light();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed == null ? null : _press,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: _pressDuration,
        child: Container(
          width: AppSizes.s40,
          height: AppSizes.s40,
          alignment: Alignment.center,
          decoration: AppShapes.decoration(
            color: colors.backgroundElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: colors.borderMedium),
          ),
          child: Icon(
            Icons.add_rounded,
            size: AppSizes.s20,
            color: colors.primaryAlt,
          ),
        ),
      ),
    );
  }
}
