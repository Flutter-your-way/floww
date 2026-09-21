import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/profile/widgets/profile_avatar_image.dart';

class ProfileAvatarCard extends StatelessWidget {
  const ProfileAvatarCard({
    super.key,
    required this.title,
    required this.hint,
    required this.actionLabel,
    required this.initial,
    this.imageUrl,
    this.imageBytes,
    this.errorMessage,
    this.isBusy = false,
    this.onTap,
  });

  static const double _avatarSize = AppSizes.s96;

  final String title;
  final String hint;
  final String actionLabel;
  final String initial;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? errorMessage;
  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final errorMessage = this.errorMessage;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.heading4SemiBold.copyWith(
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xl2),
          PressScale(
            onTap: isBusy ? null : onTap,
            child: _ProfileAvatarPreview(
              initial: initial,
              imageUrl: imageUrl,
              imageBytes: imageBytes,
              size: _avatarSize,
              isBusy: isBusy,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            actionLabel,
            style: AppTypography.labelLargeSemiBold.copyWith(
              color: colors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: colors.textSubtle,
            ),
          ),
          if (errorMessage != null) ...[
            SizedBox(height: AppSpacing.lg),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmallMediumTight.copyWith(
                color: colors.destructive,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileAvatarPreview extends StatelessWidget {
  const _ProfileAvatarPreview({
    required this.initial,
    required this.size,
    required this.isBusy,
    this.imageUrl,
    this.imageBytes,
  });

  static const double _badgeSize = AppSizes.s32;
  static const double _badgeOverhang = AppSizes.s8;

  final String initial;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double size;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: size,
      width: size + _badgeOverhang,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ProfileAvatarImage(
            initial: initial,
            imageUrl: imageUrl,
            imageBytes: imageBytes,
            size: size,
            radius: AppRadius.xl,
            initialStyle: AppTypography.heading1,
          ),
          if (isBusy)
            SizedBox(
              height: size,
              width: size,
              child: DecoratedBox(
                decoration: AppShapes.decoration(
                  color: colors.scrim,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Center(
                  child: SizedBox(
                    height: AppSizes.s20,
                    width: AppSizes.s20,
                    child: CircularProgressIndicator(
                      strokeWidth: AppSizes.s2,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: _badgeSize,
              width: _badgeSize,
              alignment: Alignment.center,
              decoration: AppShapes.decoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
                side: BorderSide(
                  color: colors.backgroundSecondary,
                  width: AppSizes.s2,
                ),
                shadows: [
                  BoxShadow(
                    color: colors.primary.withValues(
                      alpha: AppOpacity.buttonGlow,
                    ),
                    blurRadius: AppSizes.s12,
                  ),
                ],
              ),
              child: Icon(
                Icons.photo_camera_rounded,
                size: AppSizes.s16,
                color: colors.backgroundPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
