import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/animated_value_text.dart';
import 'package:floww/config/widgets/animations/rolling_text.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.valueText,
    required this.unitLabel,
    required this.onChanged,
    this.onIncrement,
    this.onDecrement,
  });

  final String valueText;
  final String unitLabel;
  final ValueChanged<String> onChanged;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        _StepButton(icon: Icons.remove_rounded, onStep: onDecrement),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: AppShapes.decoration(
              color: colors.backgroundPrimary,
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: colors.borderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EditableValue(valueText: valueText, onChanged: onChanged),
                AnimatedValueText(
                  value: unitLabel,
                  alignment: Alignment.center,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        _StepButton(icon: Icons.add_rounded, onStep: onIncrement),
      ],
    );
  }
}

class _EditableValue extends StatefulWidget {
  const _EditableValue({required this.valueText, required this.onChanged});

  final String valueText;
  final ValueChanged<String> onChanged;

  @override
  State<_EditableValue> createState() => _EditableValueState();
}

class _EditableValueState extends State<_EditableValue> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (!_focusNode.hasFocus && _isEditing) {
      setState(() => _isEditing = false);
    }
  }

  void _startEditing() {
    _controller.value = TextEditingValue(
      text: widget.valueText,
      selection: TextSelection(
        baseOffset: 0,
        extentOffset: widget.valueText.length,
      ),
    );
    setState(() => _isEditing = true);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    if (_isEditing) {
      return TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        onTapOutside: (_) => _focusNode.unfocus(),
        cursorColor: colors.primary,
        style: style,
        decoration: InputDecoration.collapsed(
          hintText: '0',
          hintStyle: style?.copyWith(color: colors.textTertiary),
        ),
      );
    }

    final isEmpty = widget.valueText.isEmpty;
    return GestureDetector(
      onTap: _startEditing,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: RollingText(
          text: isEmpty ? '0' : widget.valueText,
          style: isEmpty ? style?.copyWith(color: colors.textTertiary) : style,
        ),
      ),
    );
  }
}

class _StepButton extends StatefulWidget {
  const _StepButton({required this.icon, this.onStep});

  final IconData icon;
  final VoidCallback? onStep;

  @override
  State<_StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<_StepButton> {
  bool _isPressed = false;
  Timer? _repeatTimer;

  bool get _isEnabled => widget.onStep != null;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value && _isEnabled);
  }

  void _step() {
    final onStep = widget.onStep;
    if (onStep == null) {
      _stopRepeat();
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    HapticManager.selection();
    onStep();
  }

  void _startRepeat() {
    if (!_isEnabled) return;
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(AppMotion.stepperRepeat, (_) => _step());
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
    _setPressed(false);
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = _isEnabled;

    return GestureDetector(
      onTap: isEnabled ? _step : null,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onLongPressStart: (_) => _startRepeat(),
      onLongPressEnd: (_) => _stopRepeat(),
      onLongPressCancel: _stopRepeat,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? AppMotion.stepperPressScale : 1,
        duration: AppMotion.press,
        curve: AppMotion.stepperCurve,
        child: AnimatedContainer(
          duration: AppMotion.press,
          curve: AppMotion.expandCurve,
          width: AppSizes.s48,
          height: AppSizes.s48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isPressed ? colors.tint : colors.backgroundPrimary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            size: AppSizes.s24,
            color: isEnabled ? colors.primary : colors.textFaint,
          ),
        ),
      ),
    );
  }
}
