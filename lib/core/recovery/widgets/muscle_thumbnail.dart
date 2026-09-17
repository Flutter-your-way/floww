import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/recovery/models/muscle_recovery_item.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/recovery/widgets/muscle_status_palette.dart';

class MuscleThumbnail extends StatelessWidget {
  const MuscleThumbnail({super.key, required this.item, required this.template});

  final MuscleRecoveryItem item;
  final MuscleMapTemplate template;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: AppSizes.s48,
      height: AppSizes.s48,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: AppShapes.decoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
      ),
      child: SvgPicture.string(
        template.paint({item.group: item.status.mapColor(colors)}),
        fit: BoxFit.contain,
      ),
    );
  }
}
