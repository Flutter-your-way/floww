import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';

class MuscleThumbnail extends StatelessWidget {
  const MuscleThumbnail({
    super.key,
    required this.group,
    required this.color,
    required this.template,
    this.focus,
  });

  final MuscleGroup group;
  final Color color;
  final MuscleMapTemplate template;
  final Rect? focus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: AppSizes.s40,
      height: AppSizes.s40,
      padding: focus == null
          ? EdgeInsets.symmetric(vertical: AppSpacing.xs)
          : EdgeInsets.all(AppSpacing.xs),
      clipBehavior: Clip.antiAlias,
      decoration: AppShapes.decoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
      ),
      child: SvgPicture.string(
        template.paint({group: color}, focus: focus),
        fit: BoxFit.contain,
      ),
    );
  }
}
