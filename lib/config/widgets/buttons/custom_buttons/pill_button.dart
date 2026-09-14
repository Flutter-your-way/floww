import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

enum PillButtonVariant { accent, neutral }

class PillButton extends StatefulWidget {
  const PillButton({
    super.key,
    this.onPressed,
    this.variant = PillButtonVariant.accent,
    this.label,
    this.icon,
    this.child,
    this.width,
    this.padding,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final PillButtonVariant variant;
  final String? label;
  final IconData? icon;
  final Widget? child;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  static const _pressDuration = Duration(milliseconds: 120);
  static const double _borderWidth = 1.5;
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
    final isAccent = widget.variant == PillButtonVariant.accent;
    final foreground = isAccent
        ? context.colors.primary
        : context.colors.textPrimary;

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
          child: Container(
            height: AppSizes.s48,
            width: widget.width,
            padding: widget.padding,
            alignment: Alignment.center,
            decoration: AppShapes.decoration(
              color: isAccent
                  ? context.colors.backgroundSecondary
                  : context.colors.backgroundElevated,
              borderRadius: BorderRadius.circular(AppRadius.full),
              side: BorderSide(
                color: isAccent
                    ? context.colors.primary
                    : context.colors.borderMedium,
                width: _borderWidth,
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
                        color: foreground,
                      ),
          ),
        ),
      ),
    );
  }
}

class _PillButtonLabel extends StatelessWidget {
  const _PillButtonLabel({required this.color, this.label, this.icon});

  final Color color;
  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    final icon = this.icon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, color: color, size: AppSizes.s20),
        if (icon != null && label != null) SizedBox(width: AppSpacing.md),
        if (label != null)
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleMedium?.copyWith(color: color),
            ),
          ),
      ],
    );
  }
}
