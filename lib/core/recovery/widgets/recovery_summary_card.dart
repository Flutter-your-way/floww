import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/recovery/models/muscle_recovery_status.dart';
import 'package:floww/core/recovery/widgets/muscle_status_palette.dart';

class RecoverySummaryCard extends StatelessWidget {
  const RecoverySummaryCard({super.key, required this.countOf});

  final int Function(MuscleRecoveryStatus status) countOf;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.glow,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl2),
      child: Row(
        children: [
          for (final status in MuscleRecoveryStatus.values) ...[
            if (status != MuscleRecoveryStatus.values.first)
              Container(
                width: AppSizes.s1,
                height: AppSizes.s48,
                color: context.colors.borderSubtle,
              ),
            Expanded(
              child: _SummaryTile(status: status, count: countOf(status)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.status, required this.count});

  final MuscleRecoveryStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: AppTypography.heading1.copyWith(
            color: status.highlightColor(colors),
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          status.summaryLabel,
          style: AppTypography.bodyLargeMedium.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
