import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/text_field/smooth_input_border.dart';

class MealNameField extends StatelessWidget {
  const MealNameField({super.key, required this.initialValue, this.onChanged});

  static const int _maxLength = 80;

  final String initialValue;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    SmoothInputBorder border(Color color) => SmoothInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color),
    );

    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      maxLength: _maxLength,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      cursorColor: colors.primary,
      style: context.textTheme.bodyMedium,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: colors.backgroundPrimary,
        counterText: '',
        hintText: 'Meal name',
        hintStyle: context.textTheme.bodyMedium?.copyWith(
          color: colors.textTertiary,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSizes.s16,
        ),
        border: border(colors.borderSubtle),
        enabledBorder: border(colors.borderSubtle),
        focusedBorder: border(colors.borderAccent),
      ),
    );
  }
}
