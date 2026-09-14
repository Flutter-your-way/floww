import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';

class FoodSheetActions extends StatelessWidget {
  const FoodSheetActions({
    super.key,
    required this.secondaryLabel,
    required this.secondaryIcon,
    required this.primaryLabel,
    required this.primaryIcon,
    this.onSecondary,
    this.onPrimary,
    this.isLoading = false,
    this.errorMessage,
  });

  final String secondaryLabel;
  final IconData secondaryIcon;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback? onSecondary;
  final VoidCallback? onPrimary;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final errorMessage = this.errorMessage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (errorMessage != null) ...[
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.destructiveBorder,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
        ],
        Row(
          children: [
            Expanded(
              child: PillButton(
                variant: PillButtonVariant.neutral,
                label: secondaryLabel,
                icon: secondaryIcon,
                onPressed: isLoading ? null : onSecondary,
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: PillButton(
                label: primaryLabel,
                icon: primaryIcon,
                isLoading: isLoading,
                onPressed: onPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
