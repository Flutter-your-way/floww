import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/tabs/app_chip_tabs.dart';
import 'package:floww/core/nutrition/models/portion_unit.dart';
import 'package:floww/core/nutrition/view_models/portion_selection.dart';
import 'package:floww/core/nutrition/widgets/quantity_stepper.dart';

class PortionPicker extends StatelessWidget {
  const PortionPicker({
    super.key,
    required this.portion,
    required this.onUnitSelected,
    required this.onAmountChanged,
    required this.onPresetSelected,
    required this.onIncrement,
    required this.onDecrement,
  });

  final PortionSelection portion;
  final ValueChanged<PortionUnit> onUnitSelected;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<double> onPresetSelected;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (portion.showsUnits) ...[
          AppChipTabs<PortionUnit>(
            items: portion.units,
            selected: portion.unit,
            labelOf: (unit) => unit.label,
            onSelected: onUnitSelected,
          ),
          SizedBox(height: AppSpacing.xl),
        ],
        QuantityStepper(
          valueText: portion.amountText,
          unitLabel: portion.unitLabel,
          onChanged: onAmountChanged,
          onDecrement: portion.canDecrement ? onDecrement : null,
          onIncrement: portion.canIncrement ? onIncrement : null,
        ),
        SizedBox(height: AppSpacing.lg),
        AppChipTabs<double>(
          items: portion.presets,
          selected: portion.amount,
          labelOf: portion.presetLabelOf,
          onSelected: onPresetSelected,
        ),
      ],
    );
  }
}
