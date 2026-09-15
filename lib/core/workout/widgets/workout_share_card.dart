import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/effects/dashed_border.dart';
import 'package:floww/core/workout/models/workout_completion_view_data.dart';
import 'package:floww/core/workout/widgets/share_stat_tile.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';

class WorkoutShareCard extends StatelessWidget {
  const WorkoutShareCard({super.key, required this.card, this.onAddPhoto});

  static const double _mediaAspectRatio = 2.4;
  static const int _statColumns = 2;

  final WorkoutShareCardItem card;
  final VoidCallback? onAddPhoto;

  @override
  Widget build(BuildContext context) {
    final caption = card.caption;
    final headline = card.headline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ShareCardHeader(card: card),
        SizedBox(height: AppSpacing.xl),
        AspectRatio(
          aspectRatio: _mediaAspectRatio,
          child: card.hasPhotoSlot
              ? _SharePhotoSlot(card: card, onTap: onAddPhoto)
              : const _ShareHeroMedia(),
        ),
        if (caption != null) ...[
          SizedBox(height: AppSpacing.xl),
          Text(
            caption,
            style: AppTypography.bodyLargeMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
        if (headline != null) ...[
          SizedBox(height: AppSpacing.xs),
          Text(
            headline,
            style: AppTypography.heading3Bold.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
        SizedBox(height: AppSpacing.xl),
        _ShareStatsGrid(stats: card.stats, columns: _statColumns),
        SizedBox(height: AppSpacing.xl),
        _ShareTagsRow(tags: card.tags),
        SizedBox(height: AppSpacing.xl),
        _ShareCardFooter(card: card),
      ],
    );
  }
}

class _ShareCardHeader extends StatelessWidget {
  const _ShareCardHeader({required this.card});

  static const double _closeSlot = AppSizes.s56;

  final WorkoutShareCardItem card;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final modeLabel = card.modeLabel;

    return Row(
      children: [
        Container(
          width: AppSizes.s32,
          height: AppSizes.s32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.star_rounded,
            size: AppSizes.s20,
            color: colors.backgroundPrimary,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Text(
          card.brandLabel,
          style: AppTypography.heading4.copyWith(color: colors.textPrimary),
        ),
        SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            card.sessionLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyLargeMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        if (modeLabel != null) ...[
          SizedBox(width: AppSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: AppShapes.decoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              side: BorderSide(color: colors.borderAccent, width: AppSizes.s1),
            ),
            child: Text(
              modeLabel,
              style: AppTypography.captionSemiBold.copyWith(
                color: colors.primary,
              ),
            ),
          ),
        ],
        SizedBox(width: _closeSlot),
      ],
    );
  }
}

class _ShareHeroMedia extends StatelessWidget {
  const _ShareHeroMedia();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      alignment: Alignment.center,
      decoration: AppShapes.decoration(
        gradient: context.gradients.shareSheen,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderAccent, width: AppSizes.s1),
      ),
      child: Icon(
        Icons.fitness_center_rounded,
        size: AppSizes.s56,
        color: colors.primary,
      ),
    );
  }
}

class _SharePhotoSlot extends StatelessWidget {
  const _SharePhotoSlot({required this.card, this.onTap});

  final WorkoutShareCardItem card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final photoBytes = card.photoBytes;

    if (photoBytes != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Image.memory(
            photoBytes,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DashedBorder(
        color: colors.borderMedium,
        radius: AppRadius.lg,
        child: Container(
          alignment: Alignment.center,
          decoration: AppShapes.decoration(
            color: colors.backgroundSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.s48,
                height: AppSizes.s48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.backgroundElevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: AppSizes.s24,
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text.rich(
                TextSpan(
                  text: card.photoHint,
                  children: [
                    TextSpan(
                      text: card.photoHintSuffix,
                      style: AppTypography.bodyLargeMedium.copyWith(
                        color: colors.textFaint,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: AppTypography.bodyLargeMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareStatsGrid extends StatelessWidget {
  const _ShareStatsGrid({required this.stats, required this.columns});

  final List<ShareStatItem> stats;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final rowCount = (stats.length / columns).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var row = 0; row < rowCount; row++) ...[
          if (row > 0) SizedBox(height: AppSpacing.lg),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var column = 0; column < columns; column++) ...[
                  if (column > 0) SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: _ShareStatSlot(
                      stat: _statAt(row * columns + column),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  ShareStatItem? _statAt(int index) =>
      index < stats.length ? stats[index] : null;
}

class _ShareStatSlot extends StatelessWidget {
  const _ShareStatSlot({required this.stat});

  final ShareStatItem? stat;

  @override
  Widget build(BuildContext context) {
    final stat = this.stat;
    if (stat == null) return const SizedBox.shrink();
    return ShareStatTile(stat: stat);
  }
}

class _ShareTagsRow extends StatelessWidget {
  const _ShareTagsRow({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [for (final tag in tags) WorkoutChip(label: tag)],
    );
  }
}

class _ShareCardFooter extends StatelessWidget {
  const _ShareCardFooter({required this.card});

  final WorkoutShareCardItem card;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.bodySmallMedium.copyWith(
      color: context.colors.textFaint,
    );

    return Row(
      children: [
        Text(card.siteLabel, style: style),
        const Spacer(),
        Text(card.handleLabel, style: style),
      ],
    );
  }
}
