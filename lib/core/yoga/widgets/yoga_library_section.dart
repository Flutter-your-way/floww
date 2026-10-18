import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/core/yoga/models/yoga_course_view_data.dart';
import 'package:floww/core/yoga/widgets/yoga_family_section.dart';
import 'package:floww/core/yoga/widgets/yoga_timeline_card.dart';

class YogaLibrarySection extends StatelessWidget {
  const YogaLibrarySection({
    super.key,
    required this.families,
    required this.suryaSteps,
    required this.suryaIntro,
    required this.onOpenPose,
    required this.onOpenCourse,
  });

  final List<YogaFamilyItem> families;
  final List<YogaTimelineItem> suryaSteps;
  final String suryaIntro;
  final ValueChanged<String> onOpenPose;
  final VoidCallback onOpenCourse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PillButton(
          variant: PillButtonVariant.outline,
          label: 'Course, safety & 4-week path',
          icon: Icons.self_improvement,
          onPressed: onOpenCourse,
        ),
        SizedBox(height: AppSpacing.xl2),
        const SectionLabel(label: 'Surya Namaskar · gentle version'),
        SizedBox(height: AppSpacing.md),
        Text(
          suryaIntro,
          style: AppTypography.bodySmallRegularTight.copyWith(
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        YogaTimelineCard(items: suryaSteps),
        for (final family in families) ...[
          SizedBox(height: AppSpacing.xl3),
          YogaFamilySection(family: family, onOpen: onOpenPose),
        ],
      ],
    );
  }
}
