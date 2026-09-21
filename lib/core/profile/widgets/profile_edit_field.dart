import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/text_field/max_length_notice.dart';

class ProfileEditField extends StatelessWidget {
  const ProfileEditField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.isNumeric = false,
    this.trailing,
    this.maxLength,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isNumeric;
  final Widget? trailing;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trailing = this.trailing;
    final maxLength = this.maxLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTypography.bodySmallMediumTight.copyWith(
            color: colors.textSubtle,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Container(
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
                  maxLength: maxLength,
                  keyboardType: isNumeric
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  inputFormatters: isNumeric
                      ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                      : null,
                  textCapitalization: isNumeric
                      ? TextCapitalization.none
                      : TextCapitalization.words,
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    hintText: hint,
                    hintStyle: context.textTheme.bodyLarge?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: AppSpacing.lg),
                trailing,
              ],
            ],
          ),
        ),
        if (maxLength != null)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) => MaxLengthNotice(
              length: value.text.length,
              maxLength: maxLength,
            ),
          ),
      ],
    );
  }
}
