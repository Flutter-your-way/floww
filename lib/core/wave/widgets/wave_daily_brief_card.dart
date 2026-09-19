import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/stats/app_stat_column.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/widgets/wave_card.dart';

class WaveDailyBriefCard extends StatelessWidget {
  const WaveDailyBriefCard({
    super.key,
    required this.brief,
    required this.onStartDay,
  });

  final WaveDailyBrief brief;
  final VoidCallback onStartDay;

  @override
  Widget build(BuildContext context) {
    return WaveCard(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          WaveSectionLabel(label: brief.greeting.toUpperCase()),
          SizedBox(height: AppSpacing.xs),
          Text(brief.userName, style: context.textTheme.headlineSmall),
        ],
      ),
      sections: [
        _BriefStatGrid(brief: brief),
        WaveCardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const WaveSectionLabel(label: "TODAY'S FOCUS"),
              for (final item in brief.focusItems) ...[
                SizedBox(height: AppSpacing.md),
                _FocusItem(label: item),
              ],
            ],
          ),
        ),
        WaveCardSection(
          child: PillButton(
            variant: PillButtonVariant.accent,
            icon: Icons.play_arrow_rounded,
            label: 'Start My Day',
            height: AppSizes.s48,
            labelStyle: AppTypography.bodyLargeBold,
            onPressed: onStartDay,
          ),
        ),
      ],
    );
  }
}

class _BriefStatGrid extends StatelessWidget {
  const _BriefStatGrid({required this.brief});

  final WaveDailyBrief brief;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _BriefStatCell(
                  label: 'FLOW SCORE',
                  value: Text(
                    '${brief.flowScore}',
                    style: AppTypography.bodyXXLargeBold.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
              const WaveCardVerticalDivider(),
              Expanded(
                child: _BriefStatCell(
                  label: "TODAY'S MODE",
                  value: AppStatValue(
                    value: brief.modeLabel,
                    leadingIcon: Icons.bolt,
                    valueColor: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const WaveCardDivider(),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _BriefStatCell(
                  label: 'WORKOUT',
                  value: Text(
                    brief.workoutTitle,
                    style: AppTypography.heading4,
                  ),
                  detail: brief.workoutDetail,
                ),
              ),
              const WaveCardVerticalDivider(),
              Expanded(
                child: _BriefStatCell(
                  label: 'CALORIES',
                  value: Text(
                    NumberFormatter.grouped(brief.calories),
                    style: AppTypography.heading4,
                  ),
                  detail: brief.proteinDetail,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BriefStatCell extends StatelessWidget {
  const _BriefStatCell({
    required this.label,
    required this.value,
    this.detail,
  });

  final String label;
  final Widget value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final detail = this.detail;

    return WaveCardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          WaveSectionLabel(label: label),
          SizedBox(height: AppSpacing.md),
          value,
          if (detail != null) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              detail,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textDim,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FocusItem extends StatelessWidget {
  const _FocusItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: Container(
            width: AppSizes.s6,
            height: AppSizes.s6,
            decoration: AppShapes.decoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(child: Text(label, style: context.textTheme.bodyMedium)),
      ],
    );
  }
}
