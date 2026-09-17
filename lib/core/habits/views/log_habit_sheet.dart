import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_header.dart';
import 'package:floww/core/habits/view_models/habit_details_view_model.dart';
import 'package:floww/core/habits/widgets/habit_metric_selector.dart';
import 'package:floww/core/habits/widgets/habit_text_field.dart';

class LogHabitSheet extends StatefulWidget {
  const LogHabitSheet({super.key});

  static Future<void> show({
    required BuildContext context,
    required HabitDetailsViewModel viewModel,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const LogHabitSheet(),
      ),
    );
  }

  @override
  State<LogHabitSheet> createState() => _LogHabitSheetState();
}

class _LogHabitSheetState extends State<LogHabitSheet> {
  late final HabitDetailsViewModel _viewModel;
  late final TextEditingController _value;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<HabitDetailsViewModel>();
    _value = TextEditingController(text: _viewModel.initialLogValue);
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  double? get _loggedValue => double.tryParse(_value.text.trim());

  bool get _canSubmit {
    final value = _loggedValue;
    return value != null && value >= 0;
  }

  Future<void> _submit() async {
    final value = _loggedValue;
    if (!_canSubmit || value == null) return;
    HapticManager.success();
    await _viewModel.logProgress(value);
    if (mounted) await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSheetHeader(
                title: _viewModel.logSheetTitle,
                subtitle: _viewModel.logSheetSubtitle,
              ),
              SizedBox(height: AppSpacing.xl2),
              AppSheetFieldLabel(label: _viewModel.logValueLabel),
              SizedBox(height: AppSpacing.lg),
              HabitTextField(
                controller: _value,
                hint: _viewModel.logValueHint,
                isNumeric: true,
                onChanged: (value) => setState(() {}),
                trailing: HabitMetricSelector(label: _viewModel.logUnitLabel),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                _viewModel.todayProgressLabel,
                style: AppTypography.bodySmallRegularTight.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.xl2),
              PillButton(
                label: _viewModel.logSubmitLabel,
                icon: Icons.check_rounded,
                onPressed: _canSubmit ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
