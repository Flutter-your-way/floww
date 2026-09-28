import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/wave/models/wave_chat_day.dart';

class WaveDayRow extends StatelessWidget {
  const WaveDayRow({
    super.key,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final WaveChatDay day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: AppShapes.decoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: isSelected ? colors.borderGlow : colors.borderSubtle,
            width: AppSizes.s1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          day.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: isSelected
                                ? colors.primary
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Text(
                        day.timeLabel,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.textDim,
                        ),
                      ),
                    ],
                  ),
                  if (day.preview.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      day.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.textSubtle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Icon(
              Icons.chevron_right_rounded,
              size: AppSizes.s18,
              color: colors.textDim,
            ),
          ],
        ),
      ),
    );
  }
}
