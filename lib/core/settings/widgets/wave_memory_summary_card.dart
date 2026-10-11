import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/core/settings/view_models/wave_memory_view_model.dart';
import 'package:floww/core/settings/widgets/wave_memory_row.dart';
import 'package:floww/core/wave/models/wave_summary_item.dart';

class WaveMemorySummaryCard extends StatelessWidget {
  const WaveMemorySummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.groups,
    required this.toggleLabel,
    required this.canToggle,
    required this.onToggle,
    required this.onDelete,
    required this.onClear,
  });

  final String title;
  final String subtitle;
  final List<WaveSummaryGroup> groups;
  final String toggleLabel;
  final bool canToggle;
  final VoidCallback onToggle;
  final ValueChanged<WaveSummaryItem> onDelete;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            icon: Icons.history_edu_outlined,
            iconColor: colors.primary,
            titleStyle: AppTypography.heading4,
            trailing: CircularHeaderButton(
              icon: Icons.delete_outline_rounded,
              size: AppSizes.s32,
              iconSize: AppSizes.s16,
              iconColor: colors.textSubtle,
              backgroundColor: colors.backgroundElevated,
              onPressed: onClear,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.bodyMediumMedium.copyWith(
              color: colors.textSubtle,
            ),
          ),
          for (final group in groups) ...[
            SizedBox(height: AppSpacing.xl2),
            SectionLabel(label: group.section.label),
            for (final item in group.items) ...[
              Divider(
                height: AppSpacing.xl2,
                thickness: AppSizes.s1,
                color: colors.borderSubtle,
              ),
              WaveMemoryRow(text: item.text, onDelete: () => onDelete(item)),
            ],
          ],
          if (canToggle) ...[
            SizedBox(height: AppSpacing.xl2),
            PillButton(
              variant: PillButtonVariant.neutral,
              height: AppSizes.s40,
              label: toggleLabel,
              labelStyle: AppTypography.bodyMediumSemiBold,
              onPressed: onToggle,
            ),
          ],
        ],
      ),
    );
  }
}
