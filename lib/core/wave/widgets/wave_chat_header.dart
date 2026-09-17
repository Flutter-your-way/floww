import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/core/wave/widgets/wave_avatar_badge.dart';

class WaveChatHeader extends StatelessWidget {
  const WaveChatHeader({
    super.key,
    required this.title,
    required this.status,
    this.onClose,
  });

  final String title;
  final String status;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          const WaveAvatarBadge(),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: context.textTheme.titleLarge),
                SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Container(
                      width: AppSizes.s6,
                      height: AppSizes.s6,
                      decoration: AppShapes.decoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          CircularHeaderButton(
            icon: Icons.close_rounded,
            size: AppSizes.s32,
            iconSize: AppSizes.s16,
            backgroundColor: context.colors.backgroundElevated,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
