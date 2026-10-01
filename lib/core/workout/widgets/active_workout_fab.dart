import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';

class ActiveWorkoutFab extends StatelessWidget {
  const ActiveWorkoutFab({
    super.key,
    required this.statusLabel,
    required this.progressLabel,
    required this.isPaused,
    required this.onOpen,
    required this.onTogglePause,
  });

  final String statusLabel;
  final String progressLabel;
  final bool isPaused;
  final VoidCallback onOpen;
  final VoidCallback onTogglePause;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PillButton(
          height: AppSizes.s56,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
          onPressed: onOpen,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LiveDot(
                color: isPaused ? colors.warning : colors.success,
                isPulsing: !isPaused,
              ),
              SizedBox(width: AppSpacing.lg),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusLabel,
                    style: AppTypography.captionSemiBold.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  Text(
                    progressLabel,
                    style: AppTypography.bodyLargeBold.copyWith(
                      color: colors.primaryAlt,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppSpacing.md),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.primaryAlt,
                size: AppSizes.s20,
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.md),
        PillButton(
          width: AppSizes.s56,
          height: AppSizes.s56,
          icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          onPressed: onTogglePause,
        ),
      ],
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot({required this.color, required this.isPulsing});

  final Color color;
  final bool isPulsing;

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  static const double _minOpacity = 0.35;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
    lowerBound: _minOpacity,
    value: 1,
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _LiveDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPulsing != widget.isPulsing) _sync();
  }

  void _sync() {
    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    } else {
      _controller
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: AppSizes.s8,
        height: AppSizes.s8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
