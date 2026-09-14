import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/text_field/smooth_input_border.dart';

class CompactTextField extends StatelessWidget {
  const CompactTextField({
    super.key,
    required this.hintText,
    this.icon,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.autofocus = false,
  });

  final String hintText;
  final IconData? icon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = this.icon;

    SmoothInputBorder border(Color color) => SmoothInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color),
    );

    return TextField(
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      cursorColor: colors.primary,
      style: context.textTheme.bodyMedium,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: colors.backgroundPrimary,
        hintText: hintText,
        hintStyle: context.textTheme.bodyMedium?.copyWith(
          color: colors.textTertiary,
        ),
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: colors.textSecondary, size: AppSizes.s20),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        border: border(colors.borderSubtle),
        enabledBorder: border(colors.borderSubtle),
        focusedBorder: border(colors.borderAccent),
      ),
    );
  }
}
