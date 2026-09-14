import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/theme/app_shapes.dart';

class FoodScanControls extends StatelessWidget {
  const FoodScanControls({
    super.key,
    required this.visible,
    required this.showShutter,
    this.message,
    this.onCapture,
    this.onPickPhoto,
  });

  static const _fadeDuration = Duration(milliseconds: 200);

  final bool visible;
  final bool showShutter;
  final String? message;
  final VoidCallback? onCapture;
  final VoidCallback? onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final message = this.message;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: _fadeDuration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message != null) _ScanMessage(message: message),
            if (message != null) SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: showShutter
                        ? Alignment.centerLeft
                        : Alignment.center,
                    child: CircularHeaderButton(
                      icon: Icons.photo_library_outlined,
                      size: AppSizes.s48,
                      iconSize: AppSizes.s24,
                      onPressed: onPickPhoto,
                    ),
                  ),
                ),
                if (showShutter) ...[
                  _ShutterButton(onPressed: onCapture),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanMessage extends StatelessWidget {
  const _ScanMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: context.colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}

class _ShutterButton extends StatefulWidget {
  const _ShutterButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  State<_ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<_ShutterButton> {
  static const _pressDuration = Duration(milliseconds: 120);

  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed != null && value != _pressed) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedOpacity(
        opacity: widget.onPressed == null ? 0.5 : 1.0,
        duration: _pressDuration,
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: _pressDuration,
          child: Container(
            width: AppSizes.s72,
            height: AppSizes.s72,
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: AppSizes.s4),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
