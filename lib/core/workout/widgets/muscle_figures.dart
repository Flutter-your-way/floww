import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class MuscleFigures extends StatelessWidget {
  const MuscleFigures({
    super.key,
    this.height = AppSizes.s108,
    this.spacing = AppSpacing.md,
    this.labelled = false,
  });

  final double height;
  final double spacing;
  final bool labelled;

  @override
  Widget build(BuildContext context) {
    final front = _MuscleFigure(
      asset: AppImages.muscleFront,
      label: labelled ? 'FRONT' : null,
      height: height,
    );
    final back = _MuscleFigure(
      asset: AppImages.muscleBack,
      label: labelled ? 'BACK' : null,
      height: height,
    );

    if (!labelled) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          front,
          SizedBox(width: spacing),
          back,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: front),
        SizedBox(width: spacing),
        Expanded(child: back),
      ],
    );
  }
}

class _MuscleFigure extends StatelessWidget {
  const _MuscleFigure({required this.asset, required this.height, this.label});

  final String asset;
  final double height;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    final figure = SvgPicture.asset(
      asset,
      height: height,
      theme: SvgTheme(currentColor: context.colors.primary),
    );

    if (label == null) return figure;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.captionSemiBold.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        figure,
      ],
    );
  }
}
