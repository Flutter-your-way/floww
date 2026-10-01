import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/bright_action_button.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class HomeCardEmptyState extends StatelessWidget {
  const HomeCardEmptyState({
    super.key,
    required this.iconAsset,
    required this.message,
    required this.buttonText,
    this.buttonIcon,
    this.onPressed,
  });

  final String iconAsset;
  final String message;
  final String buttonText;
  final IconData? buttonIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          iconAsset,
          width: AppSizes.s40,
          height: AppSizes.s40,
          colorFilter: ColorFilter.mode(
            context.colors.textMuted,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        BrightActionButton(
          label: buttonText,
          icon: buttonIcon,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
