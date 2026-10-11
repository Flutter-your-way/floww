import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/settings/widgets/wave_memory_row.dart';
import 'package:floww/core/wave/models/wave_memory_note.dart';

class WaveMemorySectionCard extends StatelessWidget {
  const WaveMemorySectionCard({
    super.key,
    required this.category,
    required this.notes,
    required this.onDelete,
  });

  final WaveMemoryCategory category;
  final List<WaveMemoryNote> notes;
  final ValueChanged<WaveMemoryNote> onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: category.label,
            icon: category.icon,
            iconColor: colors.primary,
            titleStyle: AppTypography.heading4,
          ),
          for (final note in notes) ...[
            Divider(
              height: AppSpacing.xl2,
              thickness: AppSizes.s1,
              color: colors.borderSubtle,
            ),
            WaveMemoryRow(text: note.text, onDelete: () => onDelete(note)),
          ],
        ],
      ),
    );
  }
}
