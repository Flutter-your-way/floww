import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class WaveCard extends StatelessWidget {
  const WaveCard({
    super.key,
    required this.sections,
    this.header,
    this.headerColor,
    this.borderColor,
  });

  final Widget? header;
  final Color? headerColor;
  final Color? borderColor;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    final header = this.header;
    final radius = BorderRadius.circular(AppRadius.lg);

    return Container(
      decoration: AppShapes.decoration(
        color: context.colors.backgroundSecondary,
        borderRadius: radius,
        side: BorderSide(
          color: borderColor ?? context.colors.borderSubtle,
          width: AppSizes.s1,
        ),
      ),
      child: SmoothClipRRect(
        smoothness: AppShapes.smoothness,
        borderRadius: radius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (header != null)
              ColoredBox(
                color: headerColor ?? context.colors.tint,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  child: header,
                ),
              ),
            for (var index = 0; index < sections.length; index++) ...[
              if (index > 0 || header != null) const WaveCardDivider(),
              sections[index],
            ],
          ],
        ),
      ),
    );
  }
}

class WaveCardSection extends StatelessWidget {
  const WaveCardSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: child,
    );
  }
}

class WaveCardDivider extends StatelessWidget {
  const WaveCardDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.s1,
      color: context.colors.borderSubtle,
    );
  }
}

class WaveCardVerticalDivider extends StatelessWidget {
  const WaveCardVerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.s1,
      color: context.colors.borderSubtle,
    );
  }
}

class WaveSectionLabel extends StatelessWidget {
  const WaveSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.textTheme.labelMedium?.copyWith(
        color: context.colors.textDim,
      ),
    );
  }
}
