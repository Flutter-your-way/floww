import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/recovery/models/muscle_recovery_item.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/recovery/widgets/muscle_status_palette.dart';
import 'package:floww/core/recovery/widgets/muscle_thumbnail.dart';

class MuscleRecoveryRow extends StatelessWidget {
  const MuscleRecoveryRow({
    super.key,
    required this.item,
    required this.subtitle,
    required this.template,
  });

  final MuscleRecoveryItem item;
  final String subtitle;
  final MuscleMapTemplate template;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        MuscleThumbnail(item: item, template: template),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.group.label,
                style: AppTypography.bodyLargeSemiBold.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: AppTypography.bodyMediumRegular.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Text(
          '${item.percent}%',
          style: AppTypography.bodyXLargeBold.copyWith(
            color: item.status.valueColor(colors),
          ),
        ),
      ],
    );
  }
}
