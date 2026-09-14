import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/home/providers/home_provider.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';

class MuscleRecoveryCard extends StatelessWidget {
  const MuscleRecoveryCard({super.key, required this.data, this.onTap});

  final MuscleRecoveryData data;
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
                  asset: AppImages.muscleFront,
                ),
              ),
              Expanded(
                child: _MuscleDiagram(
                  label: 'BACK',
                  asset: AppImages.muscleBack,
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
  const _MuscleDiagram({required this.label, required this.asset});

  final String label;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        SvgPicture.asset(asset, height: AppSizes.s128),
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
