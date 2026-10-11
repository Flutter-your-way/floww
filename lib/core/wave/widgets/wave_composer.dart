import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';

class WaveComposer extends StatefulWidget {
  const WaveComposer({
    super.key,
    required this.controller,
    required this.hintText,
    required this.canSend,
    required this.onSubmit,
    this.onVoiceInput,
    this.meter,
  });

  static const int maxLines = 4;

  final TextEditingController controller;
  final String hintText;
  final bool canSend;
  final VoidCallback onSubmit;
  final VoidCallback? onVoiceInput;
  final Widget? meter;

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
    final hasText = widget.controller.text.trim().isNotEmpty;
    final showSend = hasText || widget.onVoiceInput == null;

    return AnimatedSize(
      duration: AppMotion.composerGrow,
      curve: AppMotion.composerGrowCurve,
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: AppShapes.decoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(
            color: widget.canSend ? colors.borderAccent : colors.borderSubtle,
            width: AppSizes.s1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: AppSizes.s40),
                child: Align(
                  alignment: Alignment.centerLeft,
                  heightFactor: 1,
                  child: RawScrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thumbColor: colors.textSubtle,
                    thickness: AppSizes.s4,
                    radius: Radius.circular(AppRadius.full),
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.md,
                        bottom: AppSpacing.md,
                        right: AppSpacing.lg,
                      ),
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
            if (widget.meter != null) ...[
              SizedBox(
                height: AppSizes.s40,
                child: Center(child: widget.meter),
              ),
              SizedBox(width: AppSpacing.sm),
            ] else
              SizedBox(width: AppSpacing.md),
            AnimatedSwitcher(
              duration: AppMotion.expand,
              switchInCurve: AppMotion.pop,
              switchOutCurve: AppMotion.collapseCurve,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: showSend
                  ? _WaveComposerAction(
                      key: const ValueKey(Icons.arrow_upward_rounded),
                      icon: Icons.arrow_upward_rounded,
                      filled: widget.canSend,
                      onTap: widget.canSend ? widget.onSubmit : null,
                    )
                  : _WaveComposerAction(
                      key: const ValueKey(Icons.mic_rounded),
                      icon: Icons.mic_rounded,
                      filled: false,
                      onTap: widget.onVoiceInput,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveComposerAction extends StatelessWidget {
  const _WaveComposerAction({
    super.key,
    required this.icon,
    required this.filled,
    this.onTap,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onTap != null;

    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.expand,
        curve: AppMotion.expandCurve,
        width: AppSizes.s40,
        height: AppSizes.s40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: filled ? context.gradients.primary : null,
          color: filled ? null : colors.tint,
        ),
        child: Icon(
          icon,
          size: AppSizes.s20,
          color: filled
              ? context.scheme.onPrimary
              : enabled
              ? colors.primary
              : colors.textSubtle,
        ),
      ),
    );
  }
}
