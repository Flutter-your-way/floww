import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/progress/view_models/progress_view_model.dart';
import 'package:floww/core/progress/widgets/weight_input_field.dart';

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
  final TextEditingController _controller = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final error = await widget.viewModel.logWeight(_controller.text);
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
    final canSave = !_isSaving && viewModel.canLogWeight(_controller.text);
    final errorMessage = _errorMessage;

    return AppFloatingSheet(
      child: AppSheetPanel(
        title: viewModel.logWeightTitle,
        titleStyle: AppTypography.heading3SemiBold,
        onClose: () => Navigator.of(context).maybePop(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WeightInputField(
              controller: _controller,
              hint: viewModel.logWeightHint,
              onChanged: (value) => setState(() {}),
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
        footer: Center(
          child: IntrinsicWidth(
            child: PillButton(
              height: AppSizes.s52,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl4),
              icon: Icons.check_rounded,
              label: viewModel.saveWeightLabel,
              labelStyle: AppTypography.heading4SemiBold,
              onPressed: canSave ? _save : null,
            ),
          ),
        ),
      ),
    );
  }
}
