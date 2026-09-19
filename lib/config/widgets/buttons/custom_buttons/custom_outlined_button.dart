import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class CustomOutlinedButton extends StatefulWidget {
  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.leading,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final Widget? leading;

  @override
  State<CustomOutlinedButton> createState() => _CustomOutlinedButtonState();
}

class _CustomOutlinedButtonState extends State<CustomOutlinedButton> {
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
              side: BorderSide(color: context.colors.borderMedium, width: 1.5),
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colors.textPrimary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.leading != null) ...[
                          widget.leading!,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: context.colors.textPrimary,
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
