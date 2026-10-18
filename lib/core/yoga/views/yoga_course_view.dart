import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/yoga/view_models/yoga_course_view_model.dart';
import 'package:floww/core/yoga/views/yoga_pose_lesson_sheet.dart';
import 'package:floww/config/widgets/cards/app_bullet_card.dart';
import 'package:floww/core/yoga/widgets/yoga_course_hero_card.dart';
import 'package:floww/core/yoga/widgets/yoga_family_section.dart';
import 'package:floww/core/yoga/widgets/yoga_timeline_card.dart';
import 'package:floww/core/yoga/widgets/yoga_week_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class YogaCourseView extends StatelessWidget {
  const YogaCourseView({super.key});

  void _startClass() {
    HapticManager.medium();
    NavigationService.instance.push(
      AppRouter.todaysWorkout,
      arguments: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YogaCourseViewModel>(
      builder: (context, viewModel, child) {
        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
          footer: viewModel.hasActiveCourse
              ? PillButton(
                  variant: PillButtonVariant.primary,
                  label: viewModel.startLabel,
                  onPressed: _startClass,
                )
              : null,
          children: [
            if (viewModel.isLoading)
              const AppSectionLoader()
            else
              _CourseContent(viewModel: viewModel),
          ],
        );
      },
    );
  }
}

class _CourseContent extends StatelessWidget {
  const _CourseContent({required this.viewModel});

  final YogaCourseViewModel viewModel;

  void _openPose(BuildContext context, String id) =>
      YogaPoseLessonSheet.show(
        context: context,
        postureId: id,
        profile: viewModel.profile,
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YogaCourseHeroCard(
          brand: viewModel.brand,
          title: viewModel.heading,
          subtitle: viewModel.subtitle,
          motto: viewModel.motto,
          pillars: viewModel.pillars,
        ),
        if (!viewModel.hasActiveCourse) ...[
          SizedBox(height: AppSpacing.lg),
          TipCard.note(title: viewModel.inactiveMessage),
        ],
        SizedBox(height: AppSpacing.xl),
        AppBulletCard(
          title: 'Learning goals',
          icon: Icons.flag_outlined,
          items: viewModel.learningGoals,
        ),
        SizedBox(height: AppSpacing.lg),
        AppBulletCard(
          title: 'Safety essentials',
          icon: Icons.health_and_safety_outlined,
          items: viewModel.safetyEssentials,
          footnote: viewModel.disclaimer,
        ),
        for (final note in viewModel.cautionNotes) ...[
          SizedBox(height: AppSpacing.lg),
          TipCard.inline(
            title: 'For you',
            message: note,
            icon: Icons.tune_rounded,
          ),
        ],
        SizedBox(height: AppSpacing.xl3),
        const SectionLabel(label: 'Your 4-week path'),
        SizedBox(height: AppSpacing.lg),
        for (final week in viewModel.weeks) ...[
          YogaWeekCard(week: week),
          SizedBox(height: AppSpacing.lg),
        ],
        SizedBox(height: AppSpacing.xl),
        SectionLabel(label: viewModel.classTitle),
        SizedBox(height: AppSpacing.lg),
        YogaTimelineCard(items: viewModel.classTimeline),
        SizedBox(height: AppSpacing.lg),
        TipCard.inline(
          title: 'Teaching note',
          message: viewModel.teachingNote,
          icon: Icons.schedule_rounded,
        ),
        SizedBox(height: AppSpacing.xl3),
        const SectionLabel(label: 'Surya Namaskar'),
        SizedBox(height: AppSpacing.lg),
        Text(
          viewModel.suryaIntro,
          style: AppTypography.bodyMediumRegular.copyWith(
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        YogaTimelineCard(items: viewModel.suryaSteps),
        SizedBox(height: AppSpacing.lg),
        AppBulletCard(
          title: 'Pacing',
          icon: Icons.air_rounded,
          items: viewModel.suryaPacing,
        ),
        for (final family in viewModel.library) ...[
          SizedBox(height: AppSpacing.xl3),
          YogaFamilySection(
            family: family,
            onOpen: (id) => _openPose(context, id),
          ),
        ],
        SizedBox(height: AppSpacing.xl3),
        Text(
          viewModel.publicationNote,
          style: AppTypography.bodySmallItalic.copyWith(
            color: colors.textTertiary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          viewModel.brandLong,
          textAlign: TextAlign.center,
          style: AppTypography.captionSemiBold.copyWith(
            color: colors.textTertiary,
          ),
        ),
      ],
    );
  }
}
