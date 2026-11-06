import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class MacroSegmentBar extends StatelessWidget {
  const MacroSegmentBar({super.key, this.hasData = true});

  final bool hasData;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.s12,
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: AppShapes.decoration(
        color: context.colors.glassSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _MacroSegment(filled: hasData)),
          SizedBox(width: AppSpacing.xxs),
          Expanded(child: _MacroSegment(filled: hasData)),
          SizedBox(width: AppSpacing.xxs),
          Expanded(child: _MacroSegment(filled: hasData)),
        ],
      ),
    );
  }
}

class _MacroSegment extends StatelessWidget {
  const _MacroSegment({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppShapes.decoration(
        gradient: filled ? context.gradients.progressFill : null,
        color: filled ? null : context.colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }
}
