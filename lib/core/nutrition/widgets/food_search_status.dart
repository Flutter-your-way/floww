import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/placeholders/app_spinner.dart';

class FoodSearchStatus extends StatelessWidget {
  const FoodSearchStatus({
    super.key,
    required this.message,
    this.isLoading = false,
  });

  final String message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            AppSpinner(size: AppSizes.s16, color: colors.primary),
            SizedBox(width: AppSpacing.md),
          ],
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
