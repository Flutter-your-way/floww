import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';

class EditNotesSheet extends StatefulWidget {
  const EditNotesSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.submitLabel,
    required this.initialNotes,
    required this.onSave,
  });

  final String title;
  final String subtitle;
  final String hint;
  final String submitLabel;
  final String initialNotes;
  final ValueChanged<String> onSave;

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String hint,
    required String submitLabel,
    required String initialNotes,
    required ValueChanged<String> onSave,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => EditNotesSheet(
        title: title,
        subtitle: subtitle,
        hint: hint,
        submitLabel: submitLabel,
        initialNotes: initialNotes,
        onSave: onSave,
      ),
    );
  }

  @override
  State<EditNotesSheet> createState() => _EditNotesSheetState();
}

class _EditNotesSheetState extends State<EditNotesSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    HapticManager.success();
    widget.onSave(_controller.text);
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
              _SheetHeader(title: widget.title, subtitle: widget.subtitle),
              SizedBox(height: AppSpacing.xl2),
              _NotesField(controller: _controller, hint: widget.hint),
              SizedBox(height: AppSpacing.xl2),
              PillButton(
                label: widget.submitLabel,
                icon: Icons.check_rounded,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: context.textTheme.displaySmall),
              SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.md),
        CircularHeaderButton(
          icon: Icons.close_rounded,
          size: AppSizes.s40,
          iconSize: AppSizes.s20,
          backgroundColor: context.colors.backgroundPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller, required this.hint});

  static const int _minLines = 4;
  static const int _maxLines = 8;

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppShapes.decoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        minLines: _minLines,
        maxLines: _maxLines,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        style: context.textTheme.bodyLarge,
        cursorColor: colors.primary,
        onTapOutside: (event) => primaryFocus?.unfocus(),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: context.textTheme.bodyLarge?.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
