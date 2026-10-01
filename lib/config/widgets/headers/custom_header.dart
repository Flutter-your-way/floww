import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/constants/app_sizes.dart';
import '../buttons/custom_buttons/circular_header_button.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({
    super.key,
    this.title,
    this.onBackPressed,
    this.onClosePressed,
    this.onMorePressed,
    this.moreIcon = Icons.more_horiz,
    this.trailing,
  });

  final String? title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onClosePressed;
  final VoidCallback? onMorePressed;
  final IconData moreIcon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.s56,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (title != null)
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
            )
          else if (onMorePressed != null)
            Positioned(
              right: 0,
              child: CircularHeaderButton(
                icon: moreIcon,
                onPressed: onMorePressed,
              ),
            )
          else if (trailing != null)
            Positioned(right: 0, child: trailing!),
        ],
      ),
    );
  }
}
