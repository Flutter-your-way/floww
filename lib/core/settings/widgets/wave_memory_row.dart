import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';

class WaveMemoryRow extends StatelessWidget {
  const WaveMemoryRow({super.key, required this.text, required this.onDelete});

  final String text;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMediumMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        CircularHeaderButton(
          icon: Icons.delete_outline_rounded,
          size: AppSizes.s32,
          iconSize: AppSizes.s16,
          iconColor: colors.textSubtle,
          backgroundColor: colors.backgroundElevated,
          onPressed: onDelete,
        ),
      ],
    );
  }
}
