import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';

class WaveComposer extends StatelessWidget {
  const WaveComposer({
    super.key,
    required this.controller,
    required this.hintText,
    required this.canSend,
    required this.onSubmit,
    this.onVoiceInput,
  });

  final TextEditingController controller;
  final String hintText;
  final bool canSend;
  final VoidCallback onSubmit;
  final VoidCallback? onVoiceInput;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: Row(
        children: [
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSubmit(),
              onTapOutside: (_) => primaryFocus?.unfocus(),
              textInputAction: TextInputAction.send,
              cursorColor: colors.primary,
              style: context.textTheme.bodyMedium,
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textDim,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          CircularHeaderButton(
            icon: Icons.mic_none_rounded,
            size: AppSizes.s36,
            iconSize: AppSizes.s18,
            iconColor: colors.textSubtle,
            backgroundColor: colors.backgroundElevated,
            onPressed: onVoiceInput,
          ),
          SizedBox(width: AppSpacing.md),
          CircularHeaderButton(
            icon: Icons.send_rounded,
            size: AppSizes.s36,
            iconSize: AppSizes.s18,
            iconColor: canSend ? colors.primary : colors.textSubtle,
            backgroundColor: colors.backgroundElevated,
            onPressed: canSend ? onSubmit : null,
          ),
        ],
      ),
    );
  }
}
