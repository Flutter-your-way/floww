import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/config/widgets/text_field/compact_text_field.dart';
import 'package:floww/core/nutrition/models/custom_food.dart';
import 'package:floww/core/nutrition/services/custom_food_service.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class CreateFoodSheet extends StatefulWidget {
  const CreateFoodSheet({super.key});

  static const String invalidMessage =
      'Add a name and the calories per serving.';

  static Future<CustomFood?> show(BuildContext context) {
    return showAppFloatingSheet<CustomFood>(
      context: context,
      builder: (_) => const CreateFoodSheet(),
    );
  }

  @override
  State<CreateFoodSheet> createState() => _CreateFoodSheetState();
}

class _CreateFoodSheetState extends State<CreateFoodSheet> {
  final CustomFoodService _service = CustomFoodService();

  String _name = '';
  String _serving = '';
  String _weight = '';
  String _calories = '';
  String _protein = '';
  String _carbs = '';
  String _fat = '';
  String _fiber = '';
  String _sugar = '';
  String _sodium = '';
  String _water = '';

  String? _errorMessage;
  bool _isSaving = false;

  static double _valueOf(String text) => double.tryParse(text.trim()) ?? 0;

  Future<void> _save() async {
    if (_isSaving) return;

    final draft = CustomFoodDraft(
      name: _name,
      serving: _serving,
      weightG: _valueOf(_weight),
      calories: _valueOf(_calories),
      proteinG: _valueOf(_protein),
      carbsG: _valueOf(_carbs),
      fatG: _valueOf(_fat),
      fiberG: _valueOf(_fiber),
      sugarG: _valueOf(_sugar),
      sodiumMg: _valueOf(_sodium),
      waterMl: _valueOf(_water),
    );

    if (!draft.isValid) {
      setState(() => _errorMessage = CreateFoodSheet.invalidMessage);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final food = await _service.create(draft);
      NavigationService.instance.pop(food);
    } on CustomFoodException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: AppSheetPanel(
        title: 'Create Food',
        onClose: () => NavigationService.instance.pop(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            CompactTextField(
              hintText: 'Food name',
              textCapitalization: TextCapitalization.words,
              onChanged: (value) => _name = value,
            ),
            SizedBox(height: AppSpacing.lg),
            CompactTextField(
              hintText: 'Serving, e.g. 1 bowl (150g)',
              onChanged: (value) => _serving = value,
            ),
            SizedBox(height: AppSpacing.lg),
            _MacroRow(
              left: _MacroField(
                hint: 'Calories',
                onChanged: (value) => _calories = value,
              ),
              right: _MacroField(
                hint: 'Weight (g)',
                onChanged: (value) => _weight = value,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            _MacroRow(
              left: _MacroField(
                hint: 'Protein (g)',
                onChanged: (value) => _protein = value,
              ),
              right: _MacroField(
                hint: 'Carbs (g)',
                onChanged: (value) => _carbs = value,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            _MacroRow(
              left: _MacroField(
                hint: 'Fat (g)',
                onChanged: (value) => _fat = value,
              ),
              right: _MacroField(
                hint: 'Fiber (g)',
                onChanged: (value) => _fiber = value,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            _MacroRow(
              left: _MacroField(
                hint: 'Sugar (g)',
                onChanged: (value) => _sugar = value,
              ),
              right: _MacroField(
                hint: 'Sodium (mg)',
                onChanged: (value) => _sodium = value,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            _MacroField(
              hint: 'Water (ml)',
              onChanged: (value) => _water = value,
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: AppSpacing.md),
              Text(
                _errorMessage!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.destructiveBorder,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.xl),
            PillButton(
              label: _isSaving ? 'Saving...' : 'Save Food',
              height: AppSizes.s48,
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        SizedBox(width: AppSpacing.lg),
        Expanded(child: right),
      ],
    );
  }
}

class _MacroField extends StatelessWidget {
  const _MacroField({required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return CompactTextField(
      hintText: hint,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: onChanged,
    );
  }
}
