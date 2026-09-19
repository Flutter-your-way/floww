import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class MacroSegmentBar extends StatelessWidget {
  const MacroSegmentBar({super.key});

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
          Expanded(
            child: _MacroSegment(gradient: context.gradients.macroProtein),
          ),
          SizedBox(width: AppSpacing.xxs),
          Expanded(child: _MacroSegment(gradient: context.gradients.macroCarbs)),
          SizedBox(width: AppSpacing.xxs),
          Expanded(child: _MacroSegment(gradient: context.gradients.macroFats)),
        ],
      ),
    );
  }
}

class _MacroSegment extends StatelessWidget {
  const _MacroSegment({required this.gradient});

  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppShapes.decoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }
}
