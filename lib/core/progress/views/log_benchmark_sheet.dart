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
import 'package:floww/core/progress/view_models/strength_level_view_model.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';

class LogBenchmarkSheet extends StatefulWidget {
  const LogBenchmarkSheet({
    super.key,
    required this.viewModel,
    required this.group,
  });

  static Future<void> show({
    required BuildContext context,
    required StrengthLevelViewModel viewModel,
    required MuscleGroup group,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => LogBenchmarkSheet(viewModel: viewModel, group: group),
    );
  }

  final StrengthLevelViewModel viewModel;
  final MuscleGroup group;

  @override
  State<LogBenchmarkSheet> createState() => _LogBenchmarkSheetState();
}

class _LogBenchmarkSheetState extends State<LogBenchmarkSheet> {
  late String _exercise = widget.viewModel.defaultExerciseOf(widget.group);
  String _weight = '';
  String _reps = '';
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final error = await widget.viewModel.logBenchmark(
      widget.group,
      exercise: _exercise,
      weight: _weight,
      reps: _reps,
    );
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
    final canSave =
        !_isSaving && viewModel.canLogBenchmark(_exercise, _weight, _reps);
    final errorMessage = _errorMessage;

    return AppFloatingSheet(
      child: AppSheetPanel(
        title: viewModel.benchmarkTitleOf(widget.group),
        subtitle: viewModel.benchmarkSubtitle,
        titleStyle: AppTypography.heading3SemiBold,
        onClose: () => Navigator.of(context).maybePop(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CompactTextField(
              hintText: viewModel.exerciseHint,
              initialText: _exercise,
              icon: Icons.fitness_center_rounded,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) => setState(() => _exercise = value),
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: CompactTextField(
                    hintText: viewModel.weightHint,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (value) => setState(() => _weight = value),
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: CompactTextField(
                    hintText: viewModel.repsHint,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => setState(() => _reps = value),
                    onSubmitted: (value) => _save(),
                  ),
                ),
              ],
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
              label: viewModel.saveBenchmarkLabel,
              labelStyle: AppTypography.heading4SemiBold,
              onPressed: canSave ? _save : null,
            ),
          ),
        ),
      ),
    );
  }
}
