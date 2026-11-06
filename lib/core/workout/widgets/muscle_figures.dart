import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/recovery/models/muscle_body_side.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/services/muscle_map_data.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/recovery/services/muscle_targeting.dart';
import 'package:floww/core/recovery/widgets/muscle_emphasis_palette.dart';

class MuscleFigures extends StatelessWidget {
  const MuscleFigures({
    super.key,
    required this.targets,
    required this.templateOf,
    this.height = AppSizes.s108,
    this.spacing = AppSpacing.md,
    this.labelled = false,
  });

  final MuscleTargets targets;
  final MuscleMapTemplate? Function(MuscleBodySide side) templateOf;
  final double height;
  final double spacing;
  final bool labelled;

  @override
  Widget build(BuildContext context) {
    final palette = targets.paletteOf(context.colors);
    final front = _MuscleFigure(
      side: MuscleBodySide.front,
      template: templateOf(MuscleBodySide.front),
      palette: palette,
      label: labelled ? 'FRONT' : null,
      height: height,
    );
    final back = _MuscleFigure(
      side: MuscleBodySide.back,
      template: templateOf(MuscleBodySide.back),
      palette: palette,
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
  const _MuscleFigure({
    required this.side,
    required this.template,
    required this.palette,
    required this.height,
    this.label,
  });

  final MuscleBodySide side;
  final MuscleMapTemplate? template;
  final Map<MuscleGroup, Color> palette;
  final double height;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    final template = this.template;
    final viewBox = MuscleMapData.viewBoxes[side]!;
    final width = height * viewBox.width / viewBox.height;
    final figure = template == null
        ? SizedBox(width: width, height: height)
        : SvgPicture.string(
            template.paint(palette),
            width: width,
            height: height,
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
