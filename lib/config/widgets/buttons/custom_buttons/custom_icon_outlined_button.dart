import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class CustomIconOutlinedButton extends StatefulWidget {
  const CustomIconOutlinedButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isDestructive = false,
    this.width,
  });

  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool isDestructive;
  final double? width;

  @override
  State<CustomIconOutlinedButton> createState() =>
      _CustomIconOutlinedButtonState();
}

class _CustomIconOutlinedButtonState extends State<CustomIconOutlinedButton> {
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
    final double targetOpacity = !_isEnabled
        ? 0.5
        : _pressed
        ? 0.85
        : 1.0;

    final double targetScale = _pressed ? 0.98 : 1.0;

    final Color contentColor = widget.isDestructive
        ? context.colors.destructive
        : context.colors.textPrimary;
    final Color borderColor = widget.isDestructive
        ? context.colors.destructiveBorder
        : context.colors.borderMedium;

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
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(27.5),
              side: BorderSide(color: borderColor, width: 1.5),
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(contentColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon, color: contentColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.text,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: contentColor,
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
