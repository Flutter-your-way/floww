import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/nutrition/view_models/diet_plan_view_model.dart';
import 'package:floww/core/nutrition/widgets/diet_plan_widgets.dart';
import 'package:floww/core/nutrition/widgets/nutrition_empty_state_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class DietPlanView extends StatelessWidget {
  const DietPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DietPlanViewModel>(
      builder: (context, viewModel, child) {
        return InnerPageScaffold(
          title: '30-Day WAVE Diet Plan',
          onBack: () => NavigationService.instance.pop(),
          children: [
            if (viewModel.isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl5),
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                  ),
                ),
              )
            else if (!viewModel.hasPlan)
              NutritionEmptyStateCard(
                title: 'No diet plan yet',
                message: viewModel.emptyMessage,
              )
            else ...[
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: context.colors.textSecondary,
                    size: AppSizes.s16,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      viewModel.createdLabel,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              DietPlanProgressCard(
                progressLabel: viewModel.progressLabel,
                percentLabel: viewModel.percentLabel,
                progress: viewModel.progress,
                startLabel: viewModel.startLabel,
                endLabel: viewModel.endLabel,
              ),
              for (final day in viewModel.days) ...[
                SizedBox(height: AppSpacing.md),
                DietPlanDayCard(
                  day: day,
                  onTap: () => viewModel.toggleDay(day.dayNumber),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}
