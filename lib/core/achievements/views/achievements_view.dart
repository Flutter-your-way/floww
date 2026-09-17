import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/config/widgets/tabs/app_chip_tabs.dart';
import 'package:floww/core/achievements/models/achievement_category.dart';
import 'package:floww/core/achievements/view_models/achievements_view_model.dart';
import 'package:floww/core/achievements/widgets/achievement_xp_card.dart';
import 'package:floww/core/achievements/widgets/achievements_grid.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class AchievementsView extends StatelessWidget {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AchievementsViewModel>();

    return InnerPageScaffold(
      title: 'Achievements',
      onBack: () => NavigationService.instance.pop(),
      children: [
        AchievementXpCard(
          totalXp: viewModel.totalXp,
          unlockedLabel: viewModel.unlockedLabel,
        ),
        SizedBox(height: AppSpacing.xl2),
        _CategoryFilters(viewModel: viewModel),
        SizedBox(height: AppSpacing.xl2),
        AchievementsGrid(achievements: viewModel.filteredAchievements),
      ],
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.viewModel});

  final AchievementsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: AppChipTabs<AchievementCategory?>(
        items: viewModel.filters,
        selected: viewModel.filter,
        isExpanded: false,
        labelOf: viewModel.labelOf,
        onSelected: viewModel.setFilter,
      ),
    );
  }
}
