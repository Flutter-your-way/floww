import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';

class CustomModeCard extends StatefulWidget {
  final String iconPath;
  final String title;
  final String description;
  final Color color;
  final bool visible;
  final VoidCallback? onRevealed;

  const CustomModeCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.description,
    required this.color,
    this.visible = true,
    this.onRevealed,
  });

  @override
  State<CustomModeCard> createState() => _CustomModeCardState();
}

class _CustomModeCardState extends State<CustomModeCard> {
  static const _popDuration = Duration(milliseconds: 420);

  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    if (widget.visible) _scheduleReveal();
  }

  @override
  void didUpdateWidget(covariant CustomModeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.visible && widget.visible) _scheduleReveal();
  }

  void _scheduleReveal() {
    _revealTimer = Timer(_popDuration, () => widget.onRevealed?.call());
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.visible ? 1.0 : 0.7,
      duration: _popDuration,
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: widget.visible ? 1.0 : 0.0,
        duration: _popDuration,
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: AppShapes.decoration(
            color: widget.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(
              color: widget.color.withValues(alpha: 0.24),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    widget.iconPath,
                    width: AppSizes.s24,
                    height: AppSizes.s24,
                    colorFilter: ColorFilter.mode(
                      widget.color,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 22 / 16,
                        letterSpacing: -0.18,
                        color: widget.color,
                        fontFamily: 'plusJakartaSans',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.description,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'plusJakartaSans',
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                  letterSpacing: 0,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
