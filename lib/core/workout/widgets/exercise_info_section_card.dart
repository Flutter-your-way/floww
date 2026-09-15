import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/models/today_workout.dart';

class ExerciseInfoSectionCard extends StatelessWidget {
  const ExerciseInfoSectionCard({
    super.key,
    required this.section,
    this.onToggle,
  });

  final ExerciseInfoSectionItem section;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isExpanded = section.isExpanded;

    return AppCard(
      variant: isExpanded
          ? AppCardVariant.accentOutline
          : AppCardVariant.subtle,
      radius: AppRadius.lg,
      padding: EdgeInsets.zero,
      transitionDuration: AppMotion.expand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
              child: Row(
                children: [
                  Icon(
                    section.icon,
                    size: AppSizes.s20,
                    color: isExpanded ? colors.primary : colors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      section.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLargeSemiBoldTight.copyWith(
                        color: isExpanded ? colors.primary : colors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Icon(
                    isExpanded ? Icons.arrow_upward : Icons.arrow_downward,
                    size: AppSizes.s20,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Container(height: AppSizes.s1, color: colors.borderSubtle),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
              child: _SectionBody(section: section),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.section});

  final ExerciseInfoSectionItem section;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final emptyMessage = section.emptyMessage;

    if (section.items.isEmpty) {
      return Text(
        emptyMessage ?? '',
        style: AppTypography.bodyLargeMedium.copyWith(color: colors.textFaint),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < section.items.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.lg),
          _SectionRow(item: section.items[i], tone: section.tone),
        ],
      ],
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.item, required this.tone});

  final ExerciseInfoItem item;
  final ExerciseInfoTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = item.label;
    final isNegative = tone == ExerciseInfoTone.negative;
    final markColor = isNegative ? colors.destructiveBorder : colors.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isNegative ? Icons.close : Icons.check,
          size: AppSizes.s20,
          color: markColor,
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppTypography.bodyLargeMedium.copyWith(
                color: colors.textSubtle,
              ),
              children: [
                if (label != null)
                  TextSpan(
                    text: '$label: ',
                    style: AppTypography.bodyLargeBold.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                TextSpan(text: item.text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
