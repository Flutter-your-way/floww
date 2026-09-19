import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_header.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/view_models/habit_details_view_model.dart';
import 'package:floww/core/habits/view_models/habit_labels.dart';
import 'package:floww/core/habits/views/habit_option_sheet.dart';
import 'package:floww/core/habits/widgets/habit_metric_selector.dart';
import 'package:floww/core/habits/widgets/habit_text_field.dart';

class EditHabitSheet extends StatefulWidget {
  const EditHabitSheet({super.key});

  static Future<void> show({
    required BuildContext context,
    required HabitDetailsViewModel viewModel,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const EditHabitSheet(),
      ),
    );
  }

  @override
  State<EditHabitSheet> createState() => _EditHabitSheetState();
}

class _EditHabitSheetState extends State<EditHabitSheet> {
  late final HabitDetailsViewModel _viewModel;
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _target;
  late HabitMetric _metric;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<HabitDetailsViewModel>();
    _name = TextEditingController(text: _viewModel.initialName);
    _description = TextEditingController(text: _viewModel.initialDescription);
    _target = TextEditingController(text: _viewModel.initialTarget);
    _metric = _viewModel.initialMetric;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _target.dispose();
    super.dispose();
  }

  double? get _targetValue => double.tryParse(_target.text.trim());

  bool get _canSubmit {
    final target = _targetValue;
    return _name.text.trim().isNotEmpty && target != null && target > 0;
  }

  void _selectMetric(String id) {
    final metric = HabitMetric.values.firstWhere(
      (metric) => metric.name == id,
      orElse: () => _metric,
    );
    if (metric == _metric) return;
    setState(() => _metric = metric);
  }

  void _openMetrics() {
    HapticManager.light();
    HabitOptionSheet.show(
      context: context,
      title: _viewModel.targetLabel,
      subtitle: _viewModel.metricSheetSubtitle,
      items: [
        for (final metric in HabitMetric.values)
          HabitOptionItem(id: metric.name, label: HabitLabels.unit(metric)),
      ],
      selectedId: _metric.name,
      onSelect: _selectMetric,
    );
  }

  void _submit() {
    final target = _targetValue;
    if (!_canSubmit || target == null) return;
    HapticManager.success();
    final description = _description.text.trim();
    _viewModel.saveHabit(
      HabitDraft(
        title: _name.text.trim(),
        target: target,
        metric: _metric,
        description: description.isEmpty ? null : description,
      ),
    );
    Navigator.of(context).maybePop();
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
                title: _viewModel.editSheetTitle,
                subtitle: _viewModel.editSheetSubtitle,
              ),
              SizedBox(height: AppSpacing.xl2),
              AppSheetFieldLabel(label: _viewModel.nameLabel),
              SizedBox(height: AppSpacing.lg),
              HabitTextField(
                controller: _name,
                hint: _viewModel.nameHint,
                onChanged: (value) => setState(() {}),
              ),
              SizedBox(height: AppSpacing.xl2),
              AppSheetFieldLabel(label: _viewModel.descriptionLabel),
              SizedBox(height: AppSpacing.lg),
              HabitTextField(
                controller: _description,
                hint: _viewModel.descriptionHint,
                onChanged: (value) => setState(() {}),
              ),
              SizedBox(height: AppSpacing.xl2),
              AppSheetFieldLabel(label: _viewModel.targetLabel),
              SizedBox(height: AppSpacing.lg),
              HabitTextField(
                controller: _target,
                hint: _viewModel.targetHint,
                isNumeric: true,
                onChanged: (value) => setState(() {}),
                trailing: HabitMetricSelector(
                  label: HabitLabels.unit(_metric),
                  onPressed: _openMetrics,
                ),
              ),
              SizedBox(height: AppSpacing.xl2),
              Align(
                child: IntrinsicWidth(
                  child: PillButton(
                    label: _viewModel.submitLabel,
                    icon: Icons.check_rounded,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
                    onPressed: _canSubmit ? _submit : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
