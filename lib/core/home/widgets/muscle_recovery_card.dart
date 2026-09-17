import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/models/muscle_recovery_status.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/recovery/widgets/muscle_status_palette.dart';

class MuscleRecoveryCard extends StatelessWidget {
  const MuscleRecoveryCard({
    super.key,
    required this.data,
    required this.frontTemplate,
    required this.backTemplate,
    this.onTap,
  });

  final MuscleRecoveryData data;
  final MuscleMapTemplate? frontTemplate;
  final MuscleMapTemplate? backTemplate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: 'Muscle Recovery',
            showChevron: true,
            onTap: onTap,
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _MuscleDiagram(
                  label: 'FRONT',
                  template: frontTemplate,
                  statuses: data.statuses,
                ),
              ),
              Expanded(
                child: _MuscleDiagram(
                  label: 'BACK',
                  template: backTemplate,
                  statuses: data.statuses,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Container(height: 1, color: context.colors.borderSubtle),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _RecoveryStat(
                label: 'Days Since Last Workout',
                value: '${data.daysSinceLastWorkout}',
              ),
              _RecoveryStat(
                label: 'In Recovery',
                value: '${data.inRecoveryCount}',
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _RecoveryStat(
                label: 'Ready Muscles',
                value: '${data.readyMusclesCount}',
              ),
              _RecoveryStat(
                label: 'Fatigued Muscles',
                value: '${data.fatiguedMusclesCount}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MuscleDiagram extends StatelessWidget {
  const _MuscleDiagram({
    required this.label,
    required this.template,
    required this.statuses,
  });

  final String label;
  final MuscleMapTemplate? template;
  final Map<MuscleGroup, MuscleRecoveryStatus> statuses;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final template = this.template;

    return Column(
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: AppSizes.s128,
          child: template == null
              ? const SizedBox.shrink()
              : SvgPicture.string(
                  template.paint({
                    for (final entry in statuses.entries)
                      entry.key: entry.value.mapColor(colors),
                  }),
                  fit: BoxFit.contain,
                ),
        ),
      ],
    );
  }
}

class _RecoveryStat extends StatelessWidget {
  const _RecoveryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(value, style: context.textTheme.titleLarge),
        ],
      ),
    );
  }
}
