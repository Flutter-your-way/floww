import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class WeightInputField extends StatelessWidget {
  const WeightInputField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
  });

  static const double _borderWidth = 1.5;

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.primary, width: _borderWidth),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        cursorColor: colors.primary,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: AppTypography.bodyLargeMedium.copyWith(
          color: colors.textPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          hintText: hint,
          hintStyle: AppTypography.bodyLargeMedium.copyWith(
            color: colors.textSecondary,
          ),
          suffixIcon: null,
          constraints: const BoxConstraints(minHeight: AppSizes.s32),
        ),
      ),
    );
  }
}
