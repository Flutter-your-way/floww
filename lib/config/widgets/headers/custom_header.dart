import 'package:floww/config/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/constants/app_sizes.dart';
import '../buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/theme/app_shapes.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({
    super.key,
    this.title,
    this.timeText,
    this.isTimerMode = false,
    this.onBackPressed,
    this.onClosePressed,
  });

  final String? title;
  final String? timeText;
  final bool isTimerMode;
  final VoidCallback? onBackPressed;
  final VoidCallback? onClosePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.s56,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isTimerMode && timeText != null)
            Container(
              height: AppSizes.s36,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
              decoration: AppShapes.decoration(
                color: context.colors.backgroundSurface,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    color: context.colors.textPrimary,
                    size: AppSizes.s16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    timeText!,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 20 / 14,
                    ),
                  ),
                ],
              ),
            )
          else if (title != null)
            Text(
              title!,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 24 / 16,
              ),
            ),
          if (onBackPressed != null)
            Positioned(
              left: 0,
              child: CircularHeaderButton(
                icon: Icons.chevron_left,
                onPressed: onBackPressed,
              ),
            ),
          if (onClosePressed != null)
            Positioned(
              right: 0,
              child: CircularHeaderButton(
                icon: Icons.close,
                iconColor: context.colors.destructive,
                onPressed: onClosePressed,
              ),
            ),
        ],
      ),
    );
  }
}
