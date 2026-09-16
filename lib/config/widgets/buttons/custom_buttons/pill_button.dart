import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/effects/inner_glow.dart';

enum PillButtonVariant { accent, neutral, bright, primary, outline, glass }

class PillButton extends StatefulWidget {
  const PillButton({
    super.key,
    this.onPressed,
    this.variant = PillButtonVariant.accent,
    this.label,
    this.icon,
    this.iconColor,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.labelStyle,
    this.labelColor,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final PillButtonVariant variant;
  final String? label;
  final IconData? icon;
  final Color? iconColor;
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;
  final Color? labelColor;
  final bool isLoading;

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  static const _pressDuration = Duration(milliseconds: 120);
  static const double _borderWidth = 1.5;
  static const double _accentBorderWidth = 1;
  static const double _loaderStroke = 2;

  bool _pressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed(bool value) {
    if (_isEnabled && value != _pressed) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isAccent = widget.variant == PillButtonVariant.accent;
    final isPrimary = widget.variant == PillButtonVariant.primary;
    final Color? background;
    final Gradient? gradient;
    final Color foreground;
    final Color borderColor;
    final List<BoxShadow>? shadows;
    switch (widget.variant) {
      case PillButtonVariant.accent:
        background = colors.bgTinted;
        gradient = null;
        foreground = colors.primaryAlt;
        borderColor = colors.primary;
        shadows = null;
      case PillButtonVariant.neutral:
        background = colors.backgroundElevated;
        gradient = null;
        foreground = colors.textPrimary;
        borderColor = colors.borderMedium;
        shadows = null;
      case PillButtonVariant.glass:
        background = colors.borderSubtle;
        gradient = null;
        foreground = colors.primaryAlt;
        borderColor = colors.borderMedium;
        shadows = null;
      case PillButtonVariant.outline:
        background = Colors.transparent;
        gradient = null;
        foreground = colors.textPrimary;
        borderColor = colors.borderMedium;
        shadows = null;
      case PillButtonVariant.primary:
        background = null;
        gradient = context.gradients.primaryButton;
        foreground = colors.backgroundSecondary;
        borderColor = colors.surfaceTranslucent;
        shadows = [
          BoxShadow(
            color: colors.primary.withValues(
              alpha: AppOpacity.buttonGlowStrong,
            ),
            offset: const Offset(0, AppSizes.s12),
            blurRadius: AppSizes.s32,
            spreadRadius: -AppSizes.s8,
          ),
          BoxShadow(
            color: colors.primary.withValues(alpha: AppOpacity.buttonGlow),
            offset: const Offset(0, AppSizes.s4),
            blurRadius: AppSizes.s12,
            spreadRadius: -AppSizes.s4,
          ),
        ];
      case PillButtonVariant.bright:
        background = colors.surfaceBright;
        gradient = null;
        foreground = colors.bgWarm;
        borderColor = Colors.transparent;
        shadows = [
          BoxShadow(
            color: colors.primaryAlt.withValues(alpha: AppOpacity.softGlow),
            offset: const Offset(0, AppSizes.s10),
            blurRadius: AppSizes.s16,
            spreadRadius: -AppSizes.s4,
          ),
          BoxShadow(
            color: colors.primaryAlt.withValues(alpha: AppOpacity.softGlow),
            offset: const Offset(0, AppSizes.s4),
            blurRadius: AppSizes.s6,
            spreadRadius: -AppSizes.s4,
          ),
        ];
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: _isEnabled ? widget.onPressed : null,
      child: AnimatedOpacity(
        opacity: widget.onPressed == null ? 0.5 : 1.0,
        duration: _pressDuration,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: _pressDuration,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height:
                    widget.height ?? (isPrimary ? AppSizes.s56 : AppSizes.s48),
                width: widget.width,
                padding: widget.padding,
                alignment: Alignment.center,
                decoration: AppShapes.decoration(
                  color: background,
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  shadows: shadows,
                  side: borderColor == Colors.transparent
                      ? BorderSide.none
                      : BorderSide(
                          color: borderColor,
                          width: isAccent ? _accentBorderWidth : _borderWidth,
                        ),
                ),
                child: widget.isLoading
                    ? SizedBox.square(
                        dimension: AppSizes.s20,
                        child: CircularProgressIndicator(
                          strokeWidth: _loaderStroke,
                          color: foreground,
                        ),
                      )
                    : widget.child ??
                          _PillButtonLabel(
                            label: widget.label,
                            icon: widget.icon,
                            color: widget.labelColor ?? foreground,
                            iconColor: widget.iconColor,
                            labelStyle: widget.labelStyle,
                            defaultStyle: isPrimary
                                ? AppTypography.heading4SemiBold
                                : null,
                          ),
              ),
              if (isAccent)
                Positioned.fill(
                  child: InnerGlow(
                    color: colors.primaryAlt.withValues(
                      alpha: AppOpacity.buttonGlow,
                    ),
                    radius: AppRadius.full,
                  ),
                ),
              if (isPrimary)
                Positioned.fill(
                  child: InnerGlow(
                    color: colors.surfaceBright.withValues(
                      alpha: AppOpacity.buttonSheen,
                    ),
                    radius: AppRadius.full,
                    blur: AppSizes.s12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillButtonLabel extends StatelessWidget {
  const _PillButtonLabel({
    required this.color,
    this.label,
    this.icon,
    this.iconColor,
    this.labelStyle,
    this.defaultStyle,
  });

  final Color color;
  final String? label;
  final IconData? icon;
  final Color? iconColor;
  final TextStyle? labelStyle;
  final TextStyle? defaultStyle;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    final icon = this.icon;
    final labelStyle = this.labelStyle;
    final iconSize = labelStyle == null ? AppSizes.s20 : AppSizes.s16;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, color: iconColor ?? color, size: iconSize),
        if (icon != null && label != null)
          SizedBox(width: labelStyle == null ? AppSpacing.md : AppSpacing.xs),
        if (label != null)
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (labelStyle ??
                          defaultStyle ??
                          context.textTheme.titleMedium)
                      ?.copyWith(
                color: color,
              ),
            ),
          ),
      ],
    );
  }
}
