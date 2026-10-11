import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/wave/models/wave_rating.dart';

class WaveRatingBar extends StatelessWidget {
  const WaveRatingBar({
    super.key,
    required this.selected,
    required this.onRated,
  });

  final WaveRating? selected;
  final ValueChanged<WaveRating> onRated;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RatingButton(
          icon: Icons.thumb_up_alt_outlined,
          selectedIcon: Icons.thumb_up_alt_rounded,
          tiltDirection: -1,
          isSelected: selected == WaveRating.up,
          onTap: () => onRated(WaveRating.up),
        ),
        SizedBox(width: AppSpacing.xs),
        _RatingButton(
          icon: Icons.thumb_down_alt_outlined,
          selectedIcon: Icons.thumb_down_alt_rounded,
          tiltDirection: 1,
          isSelected: selected == WaveRating.down,
          onTap: () => onRated(WaveRating.down),
        ),
      ],
    );
  }
}

class _RatingButton extends StatefulWidget {
  const _RatingButton({
    required this.icon,
    required this.selectedIcon,
    required this.tiltDirection,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final double tiltDirection;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_RatingButton> createState() => _RatingButtonState();
}

class _RatingButtonState extends State<_RatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.waveRatingPop,
    value: 1,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: AppMotion.waveRatingPeakScale,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: AppMotion.waveRatingPeakScale,
        end: AppMotion.waveRatingSettleScale,
      ).chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 25,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: AppMotion.waveRatingSettleScale,
        end: 1.0,
      ).chain(CurveTween(curve: AppMotion.pop)),
      weight: 45,
    ),
  ]).animate(_controller);

  late final Animation<double> _tilt = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0,
        end: AppMotion.waveRatingTilt * widget.tiltDirection,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: AppMotion.waveRatingTilt * widget.tiltDirection,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 70,
    ),
  ]).animate(_controller);

  late final Animation<double> _ring = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.waveRatingRing,
  );

  @override
  void didUpdateWidget(covariant _RatingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = widget.isSelected ? colors.primary : colors.textDim;

    return PressScale(
      onTap: widget.onTap,
      child: SizedBox.square(
        dimension: AppSizes.s28,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Stack(
            alignment: Alignment.center,
            children: [
              if (_controller.isAnimating)
                Opacity(
                  opacity: (1 - _ring.value) * AppMotion.waveRatingRingOpacity,
                  child: Transform.scale(
                    scale:
                        AppMotion.waveRatingRingStart +
                        (AppMotion.waveRatingRingEnd -
                                AppMotion.waveRatingRingStart) *
                            _ring.value,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.primary,
                          width: AppSizes.s1,
                        ),
                      ),
                      child: const SizedBox.square(dimension: AppSizes.s20),
                    ),
                  ),
                ),
              RotationTransition(
                turns: _tilt,
                child: ScaleTransition(scale: _scale, child: child),
              ),
            ],
          ),
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: color),
            duration: AppMotion.press,
            builder: (context, value, child) => Icon(
              widget.isSelected ? widget.selectedIcon : widget.icon,
              size: AppSizes.s14,
              color: value,
            ),
          ),
        ),
      ),
    );
  }
}
