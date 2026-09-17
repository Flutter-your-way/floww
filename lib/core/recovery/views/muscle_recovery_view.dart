import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/core/recovery/view_models/muscle_recovery_view_model.dart';
import 'package:floww/core/recovery/views/muscle_recovery_list_sheet.dart';
import 'package:floww/core/recovery/widgets/muscle_body_map.dart';
import 'package:floww/core/recovery/widgets/muscle_side_switch.dart';
import 'package:floww/core/recovery/widgets/recovery_summary_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class MuscleRecoveryView extends StatelessWidget {
  const MuscleRecoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MuscleRecoveryViewModel>();
    final template = viewModel.template;
    final horizontalPadding = context.sizes.screenHorizontalPadding;

    return Scaffold(
      backgroundColor: context.colors.backgroundPrimary,
      body: AppBackground(
        mode: AppBackgroundMode.flow,
        isInner: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              CustomHeader(
                title: 'Muscle Recovery',
                onBackPressed: () => NavigationService.instance.pop(),
                onMorePressed: () => MuscleRecoveryListSheet.show(
                  context: context,
                  viewModel: viewModel,
                ),
                moreIcon: Icons.format_list_bulleted_rounded,
              ),
              Expanded(
                child: template == null
                    ? const AppSectionLoader()
                    : MuscleBodyMap(
                        template: template,
                        viewBox: viewModel.viewBox,
                        statuses: viewModel.statuses,
                        selected: viewModel.selected,
                        selectionAnchor: viewModel.selectionAnchor,
                        onTapAt: viewModel.selectAt,
                      ),
              ),
              SizedBox(height: AppSpacing.xl2),
              MuscleSideSwitch(
                selected: viewModel.side,
                onSelected: viewModel.selectSide,
              ),
              SizedBox(height: AppSpacing.xl),
              _LastWorkoutLabel(label: viewModel.lastWorkoutLabel),
              SizedBox(height: AppSpacing.xl2),
              RecoverySummaryCard(countOf: viewModel.countOf),
              SizedBox(height: AppSpacing.xl2),
            ],
          ),
        ),
      ),
    );
  }
}

class _LastWorkoutLabel extends StatelessWidget {
  const _LastWorkoutLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: AppSizes.s20,
          color: colors.textSecondary,
        ),
        SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: AppTypography.bodyLargeMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
