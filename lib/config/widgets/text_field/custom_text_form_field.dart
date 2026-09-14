import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';
import 'package:floww/config/widgets/text_field/smooth_input_border.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final VoidCallback? onTap;
  final bool enabled;
  final bool partiallyEnabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextStyle? style;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.enabled = true,
    this.partiallyEnabled = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.style,
    this.textInputAction,
    this.focusNode,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final textStyle =
        style ??
        TextStyle(
          color: Colors.white,
          fontFamily: 'PlusJakartaSans',
          fontSize: 18,
          height: 28 / 18,
          letterSpacing: 0,
        );

    final hintStyle = TextStyle(
      color: const Color(0xFF8F8F8F),
      fontSize: 18,
      fontFamily: 'PlusJakartaSans',
      fontWeight: FontWeight.w400,
      height: 28 / 18,
      letterSpacing: 0,
    );

    final enabledBorder = SmoothInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF0A0A0A), width: 0.5),
    );

    final focusedBorder = SmoothInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.primary, width: 0.5),
    );

    final errorBorder = SmoothInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.destructive, width: 0.5),
    );

    final disabledBorder = SmoothInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF0A0A0A), width: 0.5),
    );

    return SizedBox(
      height: maxLines == 1 ? 62 : null,
      child: TextFormField(
        onTapOutside: (event) => primaryFocus?.unfocus(),
        initialValue: initialValue,
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onChanged: onChanged,
        onSaved: onSaved,
        onTap: onTap,
        enabled: enabled || partiallyEnabled,
        readOnly: readOnly,
        maxLines: obscureText ? 1 : maxLines,
        minLines: minLines,
        maxLength: maxLength,
        textInputAction: textInputAction,
        autovalidateMode: autovalidateMode,
        textCapitalization: textCapitalization,
        autofillHints: autofillHints,
        cursorColor: colors.primary,
        cursorWidth: 1,
        cursorRadius: const Radius.circular(1),
        style: textStyle,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF1F1F1F),

          hintText: hintText,
          hintStyle: hintStyle,
          hintMaxLines: 1,

          floatingLabelBehavior: FloatingLabelBehavior.never,
          alignLabelWithHint: true,

          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,

          prefixIconConstraints: const BoxConstraints(
            minWidth: 52,
            minHeight: 62,
          ),

          suffixIconConstraints: const BoxConstraints(
            minWidth: 52,
            minHeight: 62,
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          isDense: true,

          border: enabledBorder,
          enabledBorder: enabledBorder,
          disabledBorder: disabledBorder,
          focusedBorder: focusedBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder,

          counterText: '',
          constraints: const BoxConstraints(minHeight: 62),
        ),
      ),
    );
  }
}
