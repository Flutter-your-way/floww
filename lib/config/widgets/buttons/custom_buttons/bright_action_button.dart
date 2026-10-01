import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';

class BrightActionButton extends StatelessWidget {
  const BrightActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  static const double height = AppSizes.s36;

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return PillButton(
      variant: PillButtonVariant.bright,
      width: double.infinity,
      height: height,
      label: label,
      icon: icon,
      iconColor: context.colors.primaryDeep,
      labelStyle: AppTypography.labelSmallSemiBold,
      isLoading: isLoading,
      onPressed: onPressed,
    );
  }
}
