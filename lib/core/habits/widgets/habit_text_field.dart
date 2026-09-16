import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class HabitTextField extends StatelessWidget {
  const HabitTextField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
    this.isNumeric = false,
    this.trailing,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final bool isNumeric;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trailing = this.trailing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: context.textTheme.bodyLarge,
              cursorColor: colors.primary,
              keyboardType: isNumeric
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              inputFormatters: isNumeric
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                  : null,
              textCapitalization: isNumeric
                  ? TextCapitalization.none
                  : TextCapitalization.sentences,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                hintText: hint,
                hintStyle: context.textTheme.bodyLarge?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
          if (trailing != null) ...[SizedBox(width: AppSpacing.lg), trailing],
        ],
      ),
    );
  }
}
