import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/theme/app_shapes.dart';

class AppEmptyStateCard extends StatelessWidget {
  const AppEmptyStateCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.calendar_today_rounded,
    this.iconAsset,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.glow,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizes.s64,
            height: AppSizes.s64,
            decoration: AppShapes.decoration(
              color: context.colors.bgTinted,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              side: BorderSide(color: context.colors.borderSubtle),
            ),
            alignment: Alignment.center,
            child: _EmptyStateIcon(icon: icon, iconAsset: iconAsset),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.heading4SemiBold.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  message,
                  style: AppTypography.labelSmallMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateIcon extends StatelessWidget {
  const _EmptyStateIcon({required this.icon, this.iconAsset});

  final IconData icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textSecondary;
    final asset = iconAsset;
    if (asset == null) {
      return Icon(icon, color: color, size: AppSizes.s28);
    }
    return SvgPicture.asset(
      asset,
      width: AppSizes.s28,
      height: AppSizes.s28,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
