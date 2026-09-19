import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/sheets/app_confirm_sheet.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';
import 'package:floww/core/progress/view_models/progress_view_model.dart';
import 'package:floww/core/progress/widgets/weight_history_row.dart';

class UnlogWeightSheet extends StatefulWidget {
  const UnlogWeightSheet({super.key, required this.viewModel});

  static Future<void> show({
    required BuildContext context,
    required ProgressViewModel viewModel,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => UnlogWeightSheet(viewModel: viewModel),
    );
  }

  final ProgressViewModel viewModel;

  @override
  State<UnlogWeightSheet> createState() => _UnlogWeightSheetState();
}

class _UnlogWeightSheetState extends State<UnlogWeightSheet> {
  String? _removingId;
  String? _errorMessage;

  Future<void> _remove(WeightHistoryItem item) async {
    if (_removingId != null) return;
    final viewModel = widget.viewModel;
    HapticManager.light();
    final choice = await AppConfirmSheet.show(
      context,
      title: viewModel.unlogWeightConfirmTitle,
      message: viewModel.unlogWeightConfirmMessage(item),
      confirmLabel: viewModel.unlogWeightConfirmLabel,
      alternateLabel: viewModel.unlogWeightCancelLabel,
      isDestructive: true,
    );
    if (choice != AppConfirmChoice.confirm || !mounted) return;

    setState(() {
      _removingId = item.id;
      _errorMessage = null;
    });
    final error = await viewModel.unlogWeight(item.id);
    if (!mounted) return;
    setState(() {
      _removingId = null;
      _errorMessage = error;
    });
    if (error == null && viewModel.weightHistory.isEmpty) {
      await Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return AppFloatingSheet(
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          final items = viewModel.weightHistory;
          final errorMessage = _errorMessage;

          return AppSheetPanel(
            title: viewModel.unlogWeightTitle,
            subtitle: viewModel.unlogWeightSubtitle,
            titleStyle: AppTypography.heading3SemiBold,
            onClose: () => Navigator.of(context).maybePop(),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (items.isEmpty)
                  Text(
                    viewModel.unlogWeightEmptyMessage,
                    style: AppTypography.bodySmallRegularTight.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  )
                else
                  for (var index = 0; index < items.length; index += 1) ...[
                    if (index > 0) SizedBox(height: AppSpacing.md),
                    WeightHistoryRow(
                      item: items[index],
                      isBusy: _removingId == items[index].id,
                      onRemove: _removingId == null
                          ? () => _remove(items[index])
                          : null,
                    ),
                  ],
                if (errorMessage != null) ...[
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    errorMessage,
                    style: AppTypography.bodySmallRegularTight.copyWith(
                      color: context.colors.destructive,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
