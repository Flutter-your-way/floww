import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';

class WaveComposer extends StatefulWidget {
  const WaveComposer({
    super.key,
    required this.controller,
    required this.hintText,
    required this.canSend,
    required this.onSubmit,
    this.onVoiceInput,
  });

  static const int maxLines = 4;

  final TextEditingController controller;
  final String hintText;
  final bool canSend;
  final VoidCallback onSubmit;
  final VoidCallback? onVoiceInput;

  @override
  State<WaveComposer> createState() => _WaveComposerState();
}

class _WaveComposerState extends State<WaveComposer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedSize(
      duration: AppMotion.composerGrow,
      curve: AppMotion.composerGrowCurve,
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: AppShapes.decoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: AppSizes.s36),
                child: Align(
                  alignment: Alignment.centerLeft,
                  heightFactor: 1,
                  child: RawScrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thumbColor: colors.textSubtle,
                    thickness: AppSizes.s4,
                    radius: Radius.circular(AppRadius.full),
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                    child: Padding(
                      padding: EdgeInsets.only(right: AppSpacing.lg),
                      child: TextField(
                        controller: widget.controller,
                        scrollController: _scrollController,
                        onTapOutside: (_) => primaryFocus?.unfocus(),
                        minLines: 1,
                        maxLines: WaveComposer.maxLines,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: colors.primary,
                        style: context.textTheme.bodyMedium,
                        scrollPadding: EdgeInsets.zero,
                        decoration: InputDecoration.collapsed(
                          hintText: widget.hintText,
                          hintStyle: context.textTheme.bodyMedium?.copyWith(
                            color: colors.textDim,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            CircularHeaderButton(
              icon: Icons.mic_none_rounded,
              size: AppSizes.s36,
              iconSize: AppSizes.s18,
              iconColor: colors.textSubtle,
              backgroundColor: colors.backgroundElevated,
              onPressed: widget.onVoiceInput,
            ),
            SizedBox(width: AppSpacing.md),
            CircularHeaderButton(
              icon: Icons.send_rounded,
              size: AppSizes.s36,
              iconSize: AppSizes.s18,
              iconColor: widget.canSend ? colors.primary : colors.textSubtle,
              backgroundColor: colors.backgroundElevated,
              onPressed: widget.canSend ? widget.onSubmit : null,
            ),
          ],
        ),
      ),
    );
  }
}
