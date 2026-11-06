import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/cards/app_empty_state_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/view_models/food_log_history_view_model.dart';
import 'package:floww/core/nutrition/views/log_food_sheet.dart';
import 'package:floww/core/nutrition/widgets/food_log_history_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class FoodLogHistoryView extends StatelessWidget {
  const FoodLogHistoryView({super.key});

  static const String pageTitle = 'Food Log History';

  void _relog(
    BuildContext context,
    FoodLogHistoryViewModel viewModel,
    FoodLogHistoryItem item,
  ) {
    HapticManager.light();
    LogFoodSheet.show(
      context,
      date: viewModel.today,
      meal: item.meal,
      query: item.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodLogHistoryViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;
        final groups = viewModel.groups;

        return InnerPageScaffold(
          title: pageTitle,
          onBack: () => NavigationService.instance.pop(),
          children: [
            if (viewModel.isLoading) const AppSectionLoader(),
            if (errorMessage != null) ...[
              Text(
                errorMessage,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.destructive,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
            ],
            if (viewModel.isEmpty)
              AppEmptyStateCard(
                title: viewModel.emptyTitle,
                message: viewModel.emptyMessage,
                icon: Icons.history_rounded,
              ),
            for (final group in groups) ...[
              FoodLogHistoryCard(
                group: group,
                canDelete: viewModel.canDelete,
                onDelete: viewModel.delete,
                onTap: (item) => _relog(context, viewModel, item),
              ),
              SizedBox(height: AppSpacing.lg),
            ],
            if (groups.isNotEmpty)
              Text(
                viewModel.footnote,
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
          ],
        );
      },
    );
  }
}
