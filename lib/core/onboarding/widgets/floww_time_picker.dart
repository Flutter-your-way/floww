import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_glass.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class FlowwTimePicker {
  FlowwTimePicker._();

  static Future<TimeOfDay?> show(
    BuildContext context, {
    required TimeOfDay initialTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: 'SELECT TIME',
      barrierColor: context.colors.scrim,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
        child: Stack(
          children: [
            const Positioned.fill(child: _FrostedBackdrop()),
            Theme(data: _theme(ctx), child: child!),
          ],
        ),
      ),
    );
  }

  static ThemeData _theme(BuildContext context) {
    final colors = context.colors;
    final base = Theme.of(context);
    final glassTile = colors.textPrimary.withValues(
      alpha: AppOpacity.frostedTile,
    );
    final digits = AppTypography.displayNumericSmall.copyWith(
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    WidgetStateColor selectable(Color selected, Color idle) =>
        WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected) ? selected : idle,
        );

    final buttonStyle = TextButton.styleFrom(
      foregroundColor: colors.primary,
      textStyle: AppTypography.bodyLargeSemiBold,
    );

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: colors.primary,
        onPrimary: colors.backgroundPrimary,
        surface: colors.backgroundSurface,
        onSurface: colors.textPrimary,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colors.backgroundSecondary.withValues(
          alpha: AppOpacity.frostedDialog,
        ),
        elevation: 0,
        shape: AppShapes.border(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: colors.borderGlow),
        ),
        helpTextStyle: AppTypography.bodySmallSemiBold.copyWith(
          color: colors.textSecondary,
          letterSpacing: AppSizes.s2,
        ),
        hourMinuteShape: AppShapes.border(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        hourMinuteColor: selectable(colors.tintStrong, glassTile),
        hourMinuteTextColor: selectable(colors.primary, colors.textPrimary),
        hourMinuteTextStyle: digits,
        timeSelectorSeparatorColor: WidgetStatePropertyAll(
          colors.textSecondary,
        ),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        dayPeriodBorderSide: BorderSide(color: colors.borderMedium),
        dayPeriodColor: selectable(colors.tintStrong, glassTile),
        dayPeriodTextColor: selectable(colors.primary, colors.textSecondary),
        dayPeriodTextStyle: AppTypography.bodyLargeSemiBold,
        dialBackgroundColor: glassTile,
        dialHandColor: colors.primary,
        dialTextColor: selectable(colors.backgroundPrimary, colors.textPrimary),
        dialTextStyle: AppTypography.bodyLargeMedium,
        entryModeIconColor: colors.textSecondary,
        cancelButtonStyle: buttonStyle.copyWith(
          foregroundColor: WidgetStatePropertyAll(colors.textSecondary),
        ),
        confirmButtonStyle: buttonStyle,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          contentPadding: EdgeInsets.zero,
          hintStyle: digits.copyWith(color: colors.textTertiary),
          errorStyle: const TextStyle(fontSize: 0, height: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: colors.primary, width: AppSizes.s2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(
              color: colors.destructive,
              width: AppSizes.s2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(
              color: colors.destructive,
              width: AppSizes.s2,
            ),
          ),
        ),
      ),
    );
  }
}

class _FrostedBackdrop extends StatelessWidget {
  const _FrostedBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppGlass.blurSigmaLight,
          sigmaY: AppGlass.blurSigmaLight,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
