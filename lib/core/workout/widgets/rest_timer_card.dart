import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/entities/exercise_video_entity.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/images/exercise_video_surface.dart';

class RestTimerCard extends StatelessWidget {
  const RestTimerCard({
    super.key,
    required this.secondsLabel,
    required this.onSkip,
    required this.onAdjust,
    required this.canShorten,
    this.nextUpLabel,
    this.title = 'REST',
    this.skipLabel = 'Skip Rest',
    this.video,
    this.imageUrl,
    this.isVideoLoading = false,
  });

  static const double _aspectRatio = 1;
  static const double _videoAspectRatio = 4 / 5;

  final String secondsLabel;
  final VoidCallback onSkip;
  final ValueChanged<int> onAdjust;
  final bool canShorten;
  final String? nextUpLabel;
  final String title;
  final String skipLabel;
  final ExerciseVideo? video;
  final String? imageUrl;
  final bool isVideoLoading;

  bool get _hasMedia => video != null || imageUrl != null || isVideoLoading;

  @override
  Widget build(BuildContext context) {
    final content = _TimerContent(
      secondsLabel: secondsLabel,
      onSkip: onSkip,
      onAdjust: onAdjust,
      canShorten: canShorten,
      nextUpLabel: nextUpLabel,
      title: title,
      skipLabel: skipLabel,
    );
    final padding = EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.xl4,
    );

    if (!_hasMedia) {
      return AspectRatio(
        aspectRatio: _aspectRatio,
        child: AppCard(
          variant: AppCardVariant.sunken,
          padding: padding,
          child: content,
        ),
      );
    }

    return AppCard(
      variant: AppCardVariant.sunken,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: _videoAspectRatio,
              child: ExerciseVideoSurface(
                imageUrl: imageUrl,
                video: video,
                isLoading: isVideoLoading,
                fallbackIcon: Icons.fitness_center,
                fallbackIconSize: AppSizes.s64,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: _MediaTimerPanel(
                secondsLabel: secondsLabel,
                onSkip: onSkip,
                onAdjust: onAdjust,
                canShorten: canShorten,
                nextUpLabel: nextUpLabel,
                title: title,
                skipLabel: skipLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaTimerPanel extends StatelessWidget {
  const _MediaTimerPanel({
    required this.secondsLabel,
    required this.onSkip,
    required this.onAdjust,
    required this.canShorten,
    required this.title,
    required this.skipLabel,
    this.nextUpLabel,
  });

  static const double _adjustButtonSize = AppSizes.s40;

  final String secondsLabel;
  final VoidCallback onSkip;
  final ValueChanged<int> onAdjust;
  final bool canShorten;
  final String? nextUpLabel;
  final String title;
  final String skipLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final nextUpLabel = this.nextUpLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircularHeaderButton(
              icon: Icons.remove_rounded,
              size: _adjustButtonSize,
              iconColor: colors.textSecondary,
              backgroundColor: colors.surfaceTranslucent,
              borderColor: colors.borderMedium,
              onPressed: canShorten ? () => onAdjust(-1) : null,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    title,
                    style: AppTypography.bodySmallMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: secondsLabel,
                          style: AppTypography.heading1.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: ' sec',
                          style: AppTypography.bodyLargeMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CircularHeaderButton(
              icon: Icons.add_rounded,
              size: _adjustButtonSize,
              iconColor: colors.textSecondary,
              backgroundColor: colors.surfaceTranslucent,
              borderColor: colors.borderMedium,
              onPressed: () => onAdjust(1),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: nextUpLabel == null
                  ? const SizedBox.shrink()
                  : Text(
                      nextUpLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmallMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
            ),
            SizedBox(width: AppSpacing.lg),
            PillButton(
              label: skipLabel,
              height: AppSizes.s44,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
              onPressed: onSkip,
            ),
          ],
        ),
      ],
    );
  }
}

class _TimerContent extends StatelessWidget {
  const _TimerContent({
    required this.secondsLabel,
    required this.onSkip,
    required this.onAdjust,
    required this.canShorten,
    required this.title,
    required this.skipLabel,
    this.nextUpLabel,
  });

  static const double _adjustButtonSize = AppSizes.s44;

  final String secondsLabel;
  final VoidCallback onSkip;
  final ValueChanged<int> onAdjust;
  final bool canShorten;
  final String? nextUpLabel;
  final String title;
  final String skipLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final nextUpLabel = this.nextUpLabel;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppTypography.labelLargeMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularHeaderButton(
              icon: Icons.remove_rounded,
              size: _adjustButtonSize,
              iconColor: colors.textSecondary,
              backgroundColor: colors.surfaceTranslucent,
              borderColor: colors.borderMedium,
              onPressed: canShorten ? () => onAdjust(-1) : null,
            ),
            SizedBox(width: AppSpacing.xl3),
            Text(
              secondsLabel,
              style: AppTypography.displayNumeric.copyWith(
                color: colors.textPrimary,
              ),
            ),
            SizedBox(width: AppSpacing.xl3),
            CircularHeaderButton(
              icon: Icons.add_rounded,
              size: _adjustButtonSize,
              iconColor: colors.textSecondary,
              backgroundColor: colors.surfaceTranslucent,
              borderColor: colors.borderMedium,
              onPressed: () => onAdjust(1),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'seconds',
          style: AppTypography.labelLargeMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        if (nextUpLabel != null) ...[
          SizedBox(height: AppSpacing.xl),
          Text(
            nextUpLabel,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmallMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
        SizedBox(height: AppSpacing.xl3),
        PillButton(label: skipLabel, width: AppSizes.s160, onPressed: onSkip),
      ],
    );
  }
}
