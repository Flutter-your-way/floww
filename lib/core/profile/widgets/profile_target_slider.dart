import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';

class ProfileTargetSlider extends StatelessWidget {
  const ProfileTargetSlider({
    super.key,
    required this.spec,
    required this.valueLabel,
    required this.onChanged,
  });

  static const double _trackHeight = AppSizes.s8;
  static const Size _thumbSize = Size(AppSizes.s36, AppSizes.s24);

  final DailyTargetSpec spec;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                spec.title,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLargeBold,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              valueLabel,
              style: AppTypography.bodyLargeSemiBold.copyWith(
                color: colors.primary,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              spec.unit,
              style: AppTypography.bodySmallMediumTight.copyWith(
                color: colors.textSubtle,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: _trackHeight,
            padding: EdgeInsets.zero,
            activeTrackColor: colors.primary,
            inactiveTrackColor: colors.backgroundSurface,
            overlayColor: Colors.transparent,
            trackShape: const RoundedRectSliderTrackShape(),
            thumbShape: _PillSliderThumb(
              size: _thumbSize,
              color: colors.textPrimary,
            ),
            overlayShape: SliderComponentShape.noOverlay,
            tickMarkShape: SliderTickMarkShape.noTickMark,
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: Slider(
            value: spec.value.clamp(spec.min, spec.max),
            min: spec.min,
            max: spec.max,
            divisions: spec.divisions,
            thumbColor: colors.textPrimary,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _PillSliderThumb extends SliderComponentShape {
  const _PillSliderThumb({required this.size, required this.color});

  final Size size;
  final Color color;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => size;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final rect = Rect.fromCenter(
      center: Offset(center.dx + (0.5 - value) * size.width, center.dy),
      width: size.width,
      height: size.height,
    );
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2)),
      Paint()..color = color,
    );
  }
}
