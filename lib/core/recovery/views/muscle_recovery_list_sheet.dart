import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/config/widgets/tabs/app_chip_tabs.dart';
import 'package:floww/core/recovery/models/muscle_recovery_status.dart';
import 'package:floww/core/recovery/view_models/muscle_recovery_view_model.dart';
import 'package:floww/core/recovery/widgets/muscle_recovery_row.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class MuscleRecoveryListSheet extends StatelessWidget {
  const MuscleRecoveryListSheet({super.key});

  static const double _maxHeightFactor = 0.82;
  static const List<MuscleRecoveryStatus?> _filters = [
    null,
    MuscleRecoveryStatus.ready,
    MuscleRecoveryStatus.recovering,
    MuscleRecoveryStatus.fatigued,
  ];

  static Future<void> show({
    required BuildContext context,
    required MuscleRecoveryViewModel viewModel,
  }) {
    final theme = Theme.of(context);

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: context.colors.scrim,
      builder: (_) => Theme(
        data: theme,
        child: ChangeNotifierProvider<MuscleRecoveryViewModel>.value(
          value: viewModel,
          child: const MuscleRecoveryListSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MuscleRecoveryViewModel>();
    final colors = context.colors;
    final items = viewModel.filteredItems;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: AppShapes.decoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: AppSheetPanel(
          title: 'Muscle Recovery',
          titleStyle: context.textTheme.headlineSmall,
          onClose: () => NavigationService.instance.pop(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppChipTabs<MuscleRecoveryStatus?>(
                items: _filters,
                selected: viewModel.filter,
                isExpanded: false,
                labelOf: (status) => status?.label ?? 'All',
                onSelected: viewModel.setFilter,
              ),
              SizedBox(height: AppSpacing.xl2),
              Row(
                children: [
                  const Expanded(child: SectionLabel(label: 'Muscles')),
                  const SectionLabel(label: 'Recovery Level'),
                ],
              ),
              for (var i = 0; i < items.length; i++) ...[
                SizedBox(height: AppSpacing.xl),
                MuscleRecoveryRow(
                  item: items[i],
                  subtitle: viewModel.subtitleOf(items[i]),
                  template: viewModel.templateOf(items[i].group.primarySide)!,
                ),
                if (i < items.length - 1) ...[
                  SizedBox(height: AppSpacing.xl),
                  Container(height: AppSizes.s1, color: colors.borderSubtle),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
