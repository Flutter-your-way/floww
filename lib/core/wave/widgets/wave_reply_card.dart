import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/wave/widgets/wave_reply_frame.dart';
import 'package:floww/core/wave/widgets/wave_streaming_text.dart';

class WaveReplyCard extends StatelessWidget {
  const WaveReplyCard({
    super.key,
    required this.text,
    this.reveal = false,
    this.onRevealed,
    this.footer,
  });

  final String text;
  final bool reveal;
  final VoidCallback? onRevealed;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return WaveReplyFrame(
      footer: footer,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: AppShapes.decoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
            bottomRight: Radius.circular(AppRadius.xl),
            bottomLeft: Radius.circular(AppSizes.s6),
          ),
          side: BorderSide(color: colors.borderMedium, width: AppSizes.s1),
        ),
        child: WaveStreamingText(
          text: text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
          ),
          animate: reveal,
          onRevealed: onRevealed,
        ),
      ),
    );
  }
}
