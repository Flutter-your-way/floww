import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/theme/app_shapes.dart';

class CustomProgressWidget extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final String mainText;
  final String? suffixText;
  final TextStyle? mainTextStyle;
  final TextStyle? suffixTextStyle;

  const CustomProgressWidget({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onDecrease,
    required this.onIncrease,
    required this.mainText,
    this.suffixText,
    this.mainTextStyle,
    this.suffixTextStyle,
  });

  @override
  State<CustomProgressWidget> createState() => _CustomProgressWidgetState();
}

class _CustomProgressWidgetState extends State<CustomProgressWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildValueDisplay(),
        const SizedBox(height: 32),
        Row(
          children: [
            CircularHeaderButton(
              icon: Icons.remove,
              onPressed: widget.value > widget.min ? widget.onDecrease : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomPillSlider(
                value: widget.value,
                min: widget.min,
                max: widget.max,
                onChanged: widget.onChanged,
              ),
            ),
            const SizedBox(width: 16),
            CircularHeaderButton(
              icon: Icons.add,
              onPressed: widget.value < widget.max ? widget.onIncrease : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValueDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          widget.mainText,
          style: widget.mainTextStyle?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ) ??
              const TextStyle(
                fontSize: 64,
                height: 1.0,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'PlusJakartaSans',
                fontFeatures: [FontFeature.tabularFigures()],
              ),
        ),
        if (widget.suffixText != null) ...[
          const SizedBox(width: 8),
          Text(
            widget.suffixText!,
            style: widget.suffixTextStyle ??
                const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF919191),
                  fontFamily: 'HankenGrotesk',
                ),
          ),
        ],
      ],
    );
  }
}

class CustomPillSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const CustomPillSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<CustomPillSlider> createState() => _CustomPillSliderState();
}

class _CustomPillSliderState extends State<CustomPillSlider> {
  void _updateValue(double localPosition, double trackWidth) {
    final double thumbWidth = 35.0;
    // We calculate the fraction based on the center of the thumb.
    // The thumb can move from (thumbWidth / 2) to (trackWidth - thumbWidth / 2).
    final double maxThumbX = trackWidth - thumbWidth;
    final double relativeX = localPosition - (thumbWidth / 2);
    final double fraction = (relativeX / maxThumbX).clamp(0.0, 1.0);
    final double newValue = widget.min + fraction * (widget.max - widget.min);
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final fraction = ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
    final themeColors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackWidth = constraints.maxWidth;
        const double thumbWidth = 35.0;
        const double thumbHeight = 24.0;
        const double trackHeight = 6.0;

        final double maxThumbX = trackWidth - thumbWidth;
        final double thumbX = maxThumbX * fraction;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            _updateValue(details.localPosition.dx, trackWidth);
          },
          onTapDown: (details) {
            _updateValue(details.localPosition.dx, trackWidth);
          },
          child: SizedBox(
            height: thumbHeight,
            width: trackWidth,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Inactive track
                Container(
                  height: trackHeight,
                  width: trackWidth,
                  decoration: AppShapes.decoration(
                    color: const Color(0xFF23221A),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Active track (gradient)
                Container(
                  height: trackHeight,
                  width: thumbX + (thumbWidth / 2),
                  decoration: AppShapes.decoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF84CC16),
                        themeColors.primary,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Thumb
                Positioned(
                  left: thumbX,
                  child: Container(
                    width: thumbWidth,
                    height: thumbHeight,
                    decoration: AppShapes.decoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

