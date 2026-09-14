import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.leading,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final Widget? leading;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _pressed = false;

  bool get _isEnabled =>
      widget.onPressed != null && !widget.isLoading && !widget.isDisabled;

  void _setPressed(bool value) {
    if (_isEnabled && value != _pressed) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor = widget.foregroundColor ?? context.scheme.onPrimary;
    final double targetOpacity = !_isEnabled
        ? 0.5
        : _pressed
        ? 0.85
        : 1.0;

    final double targetScale = _pressed ? 0.98 : 1.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: _isEnabled ? widget.onPressed : null,
      child: AnimatedOpacity(
        opacity: targetOpacity,
        duration: const Duration(milliseconds: 120),
        child: AnimatedScale(
          scale: targetScale,
          duration: const Duration(milliseconds: 120),
          child: Container(
            height: 55,
            width: widget.width ?? double.infinity,
            decoration: AppShapes.decoration(
              color: widget.backgroundColor,
              gradient: widget.backgroundColor == null
                  ? LinearGradient(
                      colors: [
                        context.gradients.primary.colors[0],
                        context.gradients.primary.colors[0],
                        context.gradients.primary.colors[1],
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.5, 0.9],
                    )
                  : null,
              borderRadius: BorderRadius.circular(27.5),
              side: BorderSide(
                color: context.scheme.onPrimary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          foregroundColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.leading != null) ...[
                          widget.leading!,
                          const SizedBox(width: 8),
                        ] else if (widget.icon != null) ...[
                          Icon(widget.icon, color: foregroundColor, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: foregroundColor,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
