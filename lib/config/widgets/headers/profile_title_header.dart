import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/headers/screen_title.dart';
import 'package:smooth_corner/smooth_corner.dart';

class ProfileTitleHeader extends StatelessWidget {
  const ProfileTitleHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.streakCount,
    this.avatarUrl,
    this.onAvatarTap,
  });

  final String eyebrow;
  final String title;
  final int streakCount;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: ScreenTitle(eyebrow: eyebrow, title: title)),
        SizedBox(width: AppSpacing.lg),
        _StreakBadge(count: streakCount),
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

  static const double _blurSigma = AppSizes.s12;
  static const double _backgroundOpacity = 0.15;
  static const double _borderOpacity = 0.3;

  final int count;

  @override
  Widget build(BuildContext context) {
    return SmoothClipRRect(
      smoothness: AppShapes.smoothness,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: Container(
          height: AppSizes.s40,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: AppShapes.decoration(
            color: context.colors.textPrimary.withValues(
              alpha: _backgroundOpacity,
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
            side: BorderSide(
              color: context.colors.textPrimary.withValues(
                alpha: _borderOpacity,
              ),
              width: AppSizes.s1,
            ),
          ),
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
            ? Icon(
                Icons.person,
                color: context.colors.textPrimary,
                size: AppSizes.s24,
              )
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  color: context.colors.textPrimary,
                  size: AppSizes.s24,
                ),
              ),
      ),
    );
  }
}
