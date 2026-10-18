import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/core/yoga/models/yoga_course_view_data.dart';
import 'package:floww/core/yoga/widgets/yoga_posture_row.dart';

class YogaFamilySection extends StatelessWidget {
  const YogaFamilySection({
    super.key,
    required this.family,
    required this.onOpen,
  });

  final YogaFamilyItem family;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(label: family.title),
        SizedBox(height: AppSpacing.md),
        Text(
          family.intro,
          style: AppTypography.bodySmallRegularTight.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        for (final posture in family.postures) ...[
          SizedBox(height: AppSpacing.md),
          YogaPostureRow(posture: posture, onTap: () => onOpen(posture.id)),
        ],
      ],
    );
  }
}
