import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/images/wave_avatar_badge.dart';

class WaveChatHeader extends StatelessWidget {
  const WaveChatHeader({
    super.key,
    required this.title,
    required this.status,
    this.isLive = true,
    this.onClose,
    this.onHistory,
  });

  final String title;
  final String status;
  final bool isLive;
  final VoidCallback? onClose;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: AppSpacing.md),
          const _WaveGrabber(),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const WaveAvatarBadge(),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: context.textTheme.titleLarge),
                    SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        RepaintBoundary(child: _WaveLiveDot(isLive: isLive)),
                        SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: AnimatedSwitcher(
                            duration: AppMotion.waveThinkingSwap,
                            child: Text(
                              status,
                              key: ValueKey(status),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: colors.textDim,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              _WaveHeaderAction(
                icon: Icons.history_rounded,
                onPressed: onHistory,
              ),
              SizedBox(width: AppSpacing.md),
              _WaveHeaderAction(icon: Icons.close_rounded, onPressed: onClose),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaveHeaderAction extends StatelessWidget {
  const _WaveHeaderAction({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return const SizedBox.shrink();
    }

    return CircularHeaderButton(
      icon: icon,
      size: AppSizes.s36,
      iconSize: AppSizes.s18,
      iconColor: context.colors.textSubtle,
      backgroundColor: context.colors.backgroundElevated,
      onPressed: onPressed,
    );
  }
}

class _WaveGrabber extends StatelessWidget {
  const _WaveGrabber();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.s36,
      height: AppSizes.s4,
      decoration: AppShapes.decoration(
        color: context.colors.borderMedium,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }
}

class _WaveLiveDot extends StatefulWidget {
  const _WaveLiveDot({required this.isLive});

  final bool isLive;

  @override
  State<_WaveLiveDot> createState() => _WaveLiveDotState();
}

class _WaveLiveDotState extends State<_WaveLiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.waveThinkingBreath,
  )..repeat(reverse: true);

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.waveThinkingBreathCurve,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isLive
        ? context.colors.primary
        : context.colors.warning;

    return SizedBox.square(
      dimension: AppSizes.s12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: ReverseAnimation(_curve),
            child: ScaleTransition(
              scale: _curve,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: AppMotion.waveVoiceRippleOpacity,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: AppMotion.expand,
            width: AppSizes.s6,
            height: AppSizes.s6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
