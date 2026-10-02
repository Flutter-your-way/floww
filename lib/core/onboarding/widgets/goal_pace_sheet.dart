import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/navigation/services/navigation_service.dart';

import '../providers/onboarding_provider.dart';
import 'goal_pace_panel.dart';

class GoalPaceSheet extends StatelessWidget {
  const GoalPaceSheet({
    super.key,
    required this.questionId,
    required this.option,
  });

  static Future<void> show(
    BuildContext context, {
    required String questionId,
    required String option,
  }) {
    final provider = context.read<OnboardingProvider>();
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider<OnboardingProvider>.value(
        value: provider,
        child: GoalPaceSheet(questionId: questionId, option: option),
      ),
    );
  }

  final String questionId;
  final String option;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final projection = provider.goalPaceProjectionFor(questionId, option);
    if (projection == null) return const SizedBox.shrink();

    return AppFloatingSheet(
      child: AppSheetPanel(
        title: option,
        titleStyle: AppTypography.heading4SemiBold,
        icon: projection.config.icon,
        onClose: () => NavigationService.instance.pop(),
        body: GoalPacePanel(
          projection: projection,
          onPaceChanged: (pace) =>
              provider.setGoalPace(projection.config, pace),
        ),
        footer: CustomButton(
          text: 'Understood',
          onPressed: () => NavigationService.instance.pop(),
        ),
      ),
    );
  }
}
