import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_glass.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/effects/liquid_glass.dart';
import 'package:floww/config/widgets/headers/screen_title.dart';

class ProfileTitleHeader extends StatelessWidget {
  const ProfileTitleHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.streakCount,
    this.avatarUrl,
    this.onAvatarTap,
    this.onStreakTap,
  });

  final String eyebrow;
  final String title;
  final int streakCount;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onStreakTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ScreenTitle(eyebrow: eyebrow, title: title),
        ),
        SizedBox(width: AppSpacing.lg),
        PressScale(
          onTap: onStreakTap,
          child: _StreakBadge(count: streakCount),
        ),
        SizedBox(width: AppSpacing.md),
        PressScale(
          onTap: onAvatarTap,
          child: _UserAvatar(avatarUrl: avatarUrl),
        ),
      ],
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(AppRadius.full),
      blurSigma: AppGlass.blurSigmaLight,
      refraction: AppGlass.refractionSoft,
      thickness: AppGlass.edgeThicknessTight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: SizedBox(
          height: AppSizes.s40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                color: context.colors.accentOrange,
                size: AppSizes.s20,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                '$count',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.backgroundPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({this.avatarUrl});

  static const double _borderWidth = 1.5;
  static const double _borderOpacity = 0.5;
  static const double _backgroundOpacity = 0.35;

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = this.avatarUrl;

    return Container(
      height: AppSizes.s40,
      width: AppSizes.s40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.backgroundPrimary.withValues(
          alpha: _backgroundOpacity,
        ),
        border: Border.all(
          color: context.colors.textPrimary.withValues(alpha: _borderOpacity),
          width: _borderWidth,
        ),
      ),
      child: ClipOval(
        child: avatarUrl == null
            ? const _AvatarFallback()
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                width: AppSizes.s40,
                height: AppSizes.s40,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const _AvatarFallback(),
                errorBuilder: (context, error, stackTrace) =>
                    const _AvatarFallback(),
              ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.person,
      color: context.colors.textPrimary,
      size: AppSizes.s24,
    );
  }
}
