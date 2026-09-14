import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/constants/app_sizes.dart';

class CircularHeaderButton extends StatefulWidget {
  const CircularHeaderButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = AppSizes.s40,
    this.iconSize = AppSizes.s20,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;

  @override
  State<CircularHeaderButton> createState() => _CircularHeaderButtonState();
}

class _CircularHeaderButtonState extends State<CircularHeaderButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed != null && value != _pressed) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double targetOpacity = widget.onPressed == null
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
      onTap: widget.onPressed,
      child: AnimatedOpacity(
        opacity: targetOpacity,
        duration: const Duration(milliseconds: 120),
        child: AnimatedScale(
          scale: targetScale,
          duration: const Duration(milliseconds: 120),
          child: Container(
            height: widget.size,
            width: widget.size,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? context.colors.backgroundSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: widget.iconColor ?? context.colors.textPrimary,
                size: widget.iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
