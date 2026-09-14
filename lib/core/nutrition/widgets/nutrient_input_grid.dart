import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/nutrition/models/nutrient_input.dart';
import 'package:floww/config/theme/app_shapes.dart';

class NutrientInputGrid extends StatelessWidget {
  const NutrientInputGrid({
    super.key,
    required this.inputs,
    required this.onChanged,
    this.highlighted = false,
  });

  final List<NutrientInput> inputs;
  final void Function(FoodNutrient nutrient, String value) onChanged;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < inputs.length; i += 2) ...[
          if (i > 0) SizedBox(height: AppSizes.s10),
          Row(
            children: [
              Expanded(child: _tile(inputs[i])),
              SizedBox(width: AppSizes.s10),
              Expanded(
                child: i + 1 < inputs.length
                    ? _tile(inputs[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _tile(NutrientInput input) => _NutrientInputTile(
    key: ValueKey(input.nutrient),
    input: input,
    highlighted: highlighted,
    onChanged: (value) => onChanged(input.nutrient, value),
  );
}

class _NutrientInputTile extends StatefulWidget {
  const _NutrientInputTile({
    super.key,
    required this.input,
    required this.highlighted,
    required this.onChanged,
  });

  final NutrientInput input;
  final bool highlighted;
  final ValueChanged<String> onChanged;

  @override
  State<_NutrientInputTile> createState() => _NutrientInputTileState();
}

class _NutrientInputTileState extends State<_NutrientInputTile> {
  static final _amountPattern = RegExp(r'^\d{0,5}(\.\d?)?$');
  static final _amountFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) =>
        _amountPattern.hasMatch(newValue.text) ? newValue : oldValue,
  );

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final captionStyle = context.textTheme.bodySmall?.copyWith(
      color: colors.textMuted,
      fontWeight: FontWeight.w400,
    );
    final valueStyle = context.textTheme.headlineSmall?.copyWith(
      color: widget.highlighted ? colors.primary : colors.textPrimary,
      fontWeight: FontWeight.w700,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focusNode.requestFocus,
      child: Container(
        height: AppSizes.s72,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: AppShapes.decoration(
          color: colors.backgroundPrimary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: _focusNode.hasFocus
                ? colors.borderAccent
                : colors.borderSubtle,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.input.nutrient.label, style: captionStyle),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.input.text,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    onTapOutside: (_) => _focusNode.unfocus(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [_amountFormatter],
                    textInputAction: TextInputAction.done,
                    cursorColor: colors.primary,
                    style: valueStyle,
                    decoration: InputDecoration.collapsed(
                      hintText: '0',
                      hintStyle: valueStyle?.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                ),
                Text(widget.input.nutrient.unit, style: captionStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
