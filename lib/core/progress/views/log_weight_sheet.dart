import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/config/widgets/text_field/compact_text_field.dart';
import 'package:floww/core/progress/view_models/progress_view_model.dart';

class LogWeightSheet extends StatefulWidget {
  const LogWeightSheet({super.key, required this.viewModel});

  static Future<void> show({
    required BuildContext context,
    required ProgressViewModel viewModel,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => LogWeightSheet(viewModel: viewModel),
    );
  }

  final ProgressViewModel viewModel;

  @override
  State<LogWeightSheet> createState() => _LogWeightSheetState();
}

class _LogWeightSheetState extends State<LogWeightSheet> {
  String _weight = '';
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final error = await widget.viewModel.logWeight(_weight);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isSaving = false;
        _errorMessage = error;
      });
      return;
    }
    await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final canSave = !_isSaving && viewModel.canLogWeight(_weight);
    final errorMessage = _errorMessage;

    return AppFloatingSheet(
      child: AppSheetPanel(
        title: viewModel.logWeightTitle,
        onClose: () => Navigator.of(context).maybePop(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CompactTextField(
              hintText: viewModel.logWeightHint,
              icon: Icons.monitor_weight_outlined,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: (value) => setState(() => _weight = value),
              onSubmitted: (value) => _save(),
            ),
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
        footer: PillButton(
          height: AppSizes.s44,
          icon: Icons.check_rounded,
          label: viewModel.saveWeightLabel,
          isLoading: _isSaving,
          onPressed: canSave ? _save : null,
        ),
      ),
    );
  }
}
