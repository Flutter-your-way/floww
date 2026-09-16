import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.isEnabled = true,
  });

  static const double _trackWidth = AppSizes.s52;
  static const double _trackHeight = AppSizes.s28;
  static const double _thumbSize = AppSizes.s24;
  static const double _thumbInset = AppSizes.s2;

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onChanged = this.onChanged;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isEnabled && onChanged != null ? () => onChanged(!value) : null,
      child: AnimatedOpacity(
        opacity: isEnabled ? 1 : AppOpacity.disabled,
        duration: AppMotion.press,
        child: AnimatedContainer(
          duration: AppMotion.press,
          curve: AppMotion.expandCurve,
          height: _trackHeight,
          width: _trackWidth,
          padding: const EdgeInsets.all(_thumbInset),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: value ? colors.primary : colors.backgroundElevated,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Container(
            height: _thumbSize,
            width: _thumbSize,
            decoration: BoxDecoration(
              color: colors.brandLight,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
