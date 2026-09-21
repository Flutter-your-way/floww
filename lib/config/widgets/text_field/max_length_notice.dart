import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class MaxLengthNotice extends StatelessWidget {
  const MaxLengthNotice({
    super.key,
    required this.length,
    required this.maxLength,
  });

  final int length;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    if (length < maxLength) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.md),
      child: Text(
        'You can only use $maxLength characters.',
        style: AppTypography.bodySmallMediumTight.copyWith(
          color: context.colors.warning,
        ),
      ),
    );
  }
}
