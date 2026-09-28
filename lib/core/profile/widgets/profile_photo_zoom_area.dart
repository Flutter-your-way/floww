import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/images/cached_avatar_image.dart';
import 'package:floww/config/widgets/placeholders/app_spinner.dart';

class ProfilePhotoZoomArea extends StatelessWidget {
  const ProfilePhotoZoomArea({super.key, this.imageUrl, this.imageBytes});

  static const double _minScale = 1.0;
  static const double _maxScale = 5.0;
  static const String _emptyMessage = 'This photo could not be loaded.';

  final String? imageUrl;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    final imageUrl = this.imageUrl;
    final imageBytes = this.imageBytes;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InteractiveViewer(
        minScale: _minScale,
        maxScale: _maxScale,
        child: switch ((imageBytes, imageUrl)) {
          (final Uint8List bytes, _) => Image.memory(
            bytes,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) =>
                const _ProfilePhotoEmpty(message: _emptyMessage),
          ),
          (_, final String url) => CachedAvatarImage(
            url: url,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            placeholder: const _ProfilePhotoLoader(),
            error: const _ProfilePhotoEmpty(message: _emptyMessage),
          ),
          _ => const _ProfilePhotoEmpty(message: _emptyMessage),
        },
      ),
    );
  }
}

class _ProfilePhotoLoader extends StatelessWidget {
  const _ProfilePhotoLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(child: AppSpinner());
  }
}

class _ProfilePhotoEmpty extends StatelessWidget {
  const _ProfilePhotoEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl2,
          vertical: AppSpacing.xl,
        ),
        decoration: AppShapes.decoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmallMediumTight.copyWith(
            color: colors.textSubtle,
          ),
        ),
      ),
    );
  }
}
